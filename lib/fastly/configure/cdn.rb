require 'yaml'
require 'erb'

class Fastly
  module Configure
    class CDN
      def initialize(options)
        @settings = YAML.load_file(options[:settings_file])
        @cdn_options = options
        @file_service_name = @cdn_options[:service_name].gsub(/ /, "-").downcase
        @template = VarnishTemplate.new(@settings)
        @erb_path = File.join("vcl-templates", "#{@file_service_name}-template.vcl.erb")
      end

      def build
        if @cdn_options[:operation] == "fastly"
          configure_fastly
        elsif @cdn_options[:operation] == "vcl"
          create_vcl
        else
          raise "Invalid operation #{@cdn_options[:operation]}. (fastly|vcl)"
        end
      end

      def create_vcl
        full_vcl_path = File.join(@cdn_options[:output_directory], "#{@file_service_name}-full.vcl")
        @template.create_vcl(@erb_path, full_vcl_path, true)
      end

      def configure_fastly
        @upload_vcl_path = File.join(@cdn_options[:output_directory], "#{@file_service_name}-upload.vcl")
        @template.create_vcl(@erb_path, @upload_vcl_path, false)
        @fastly = Fastly.new(:api_key => @cdn_options[:api_key])

        # look for the service, creating if it doesn't exist
        begin
          @service = @fastly.search_services(:name => @settings["service"])
        rescue
          @service = @fastly.create_service(:name => @settings["service"])
        end

        @version = Fastly::Version.create_new(@service.fetcher, :service_id => @service.id)

        configure_domains
        configure_general_settings
        configure_backends
        configure_directors
        configure_conditions
        configure_cache_settings
        configure_request_settings
        configure_headers
        configure_gzips
        configure_response_objects
        configure_s3_logging
        upload_vcl

        if @version.validate
          success = @version.activate!
          if !success
      raise "Something went wrong trying to activate the new version."
          end
        else
          raise "Something is not right with the new version!"
        end
      end

      private

      def sym_hash_keys(hash)
        hash = hash.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      end

      def erb_path
        File.join("erb-templates", "#{@file_service_name}-template.vcl.erb")
      end

      def configure_domains
        if @settings["domains"].nil?
          raise "No domains specified in the configuration file!"
        end
        @settings["domains"].each do |domain|
          @fastly.create_domain(:service_id => @service.id, :version => @version.number, :name => domain)
        end
      end

      def normalize_general_settings(settings)
        new_settings = Hash.new
        new_settings["general.default_host"] = settings["default_host"]
        new_settings["general.default_ttl"] = settings["default_ttl"]
        new_settings
      end

      def configure_general_settings
        general_settings = @fastly.get_settings(@service.id, @version.number)
        @settings["settings"] = normalize_general_settings(@settings["settings"])
        general_settings.settings.merge!(@settings["settings"])
        @fastly.update_settings(general_settings)
      end

      def configure_backends
        if @settings["backends"].nil?
          raise "No backends specified in the configuration file!"
        end
        @settings["backends"].each do |backend_name, backend_options|
          backend_options[:service_id] = @service.id
          backend_options[:version] = @version.number
          backend_options[:name] = backend_name
          request_condition = backend_options.delete("request_condition")
          backend_options = sym_hash_keys(backend_options)
          backend = @fastly.create_backend(backend_options)
          unless request_condition.nil?
      backend.request_condition = request_condition
      backend.save!
          end
        end
      end

      def configure_directors
        @settings["directors"].each do |director_name, director_setting|
          director = @fastly.create_director(:service_id => @service.id, :version => @version.number, :name => director_name)
          director_setting["backends"].each do |backend_name|
      begin
        backend = @fastly.get_backend(@service.id, @version.number, backend_name)
        director.add_backend(backend)
      rescue
        puts "backend #{backend_name} did not get added successfully"
      end
          end unless director_setting["backends"].nil?
        end unless @settings["directors"].nil?
      end

      def configure_conditions
        @settings["conditions"].each do |condition_type, conditions|
          if conditions
            conditions.each do |condition_name, condition|
              condition[:service_id] = @service.id
              condition[:version] = @version.number
              condition[:type] = condition_type.upcase
              condition[:name] = condition_name
              condition = sym_hash_keys(condition)
              @fastly.create_condition(condition)
            end
          end
        end unless @settings["conditions"].nil?
      end

      def configure_cache_settings
        @settings["cache_settings"].each do |cache_name, cache_setting|
          cache_setting[:service_id] = @service.id
          cache_setting[:version] = @version.number
          cache_setting[:name] = cache_name
          cache_setting = sym_hash_keys(cache_setting)
          @fastly.create_cache_setting(cache_setting)
        end unless @settings["cache_settings"].nil?
      end

      def configure_request_settings
        @settings["request_settings"].each do |request_name, request_setting|
          request_setting[:service_id] = @service.id
          request_setting[:version] = @version.number
          request_setting[:name] = request_name
          request_setting = sym_hash_keys(request_setting)
          @fastly.create_request_setting(request_setting)
        end unless @settings["request_settings"].nil?
      end

      def configure_headers
        @settings["headers"].each do |header_name, header_setting|
          header_setting[:service_id] = @service.id
          header_setting[:version] = @version.number
          header_setting[:name] = header_name
          header_setting = sym_hash_keys(header_setting)
          request_cond = header_setting.delete(:request_condition)
          response_cond = header_setting.delete(:response_condition)
          cache_cond = header_setting.delete(:cache_condition)
          header = @fastly.create_header(header_setting)
          header.save!
          header.request_condition = request_cond unless request_cond.nil?
          header.response_condition = response_cond unless response_cond.nil?
          header.cache_condition = cache_cond unless response_cond.nil?
          header.save!
        end unless @settings["headers"].nil?
      end

      def configure_gzips
        @settings["gzips"].each do |gzip_name, gzip_setting|
          gzip_setting[:service_id] = @service.id
          gzip_setting[:version] = @version.number
          gzip_setting[:name] = gzip_name
          gzip_setting = sym_hash_keys(gzip_setting)
          @fastly.create_gzip(gzip_setting)
        end unless @settings["gzips"].nil?
      end

      def configure_response_objects
        @settings["response_objects"].each do |response_object_name, response_object_setting|
          response_object_setting[:service_id] = @service.id
          response_object_setting[:version] = @version.number
          response_object_setting[:name] = response_object_name
          response_object_setting = sym_hash_keys(response_object_setting)
          @fastly.create_response_object(response_object_setting)
        end unless @settings["response_objects"].nil?
      end

      def configure_s3_logging
        @settings["s3_logging"].each do |s3_name, s3_setting|
          s3_setting[:service_id] = @service.id
          s3_setting[:version] = @version.number
          s3_setting[:name] = s3_name
          s3_setting = sym_hash_keys(s3_setting)
          fastly.create_s3_logging(s3_setting)
        end unless @settings["s3_logging"].nil?
      end

      def upload_vcl
        @settings["vcl"].each do |vcl_name|
          @version.upload_main_vcl(vcl_name, File.read(@upload_vcl_path))
        end unless @settings["vcl"].nil?
      end
    end
  end
end
