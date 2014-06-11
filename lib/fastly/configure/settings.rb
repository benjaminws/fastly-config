class Fastly
  module Configure
    class Settings
      attr_accessor :path_to_file
      attr_accessor :document

      attr_accessor :service
      attr_accessor :domains
      attr_accessor :settings
      attr_accessor :backends
      attr_accessor :conditions
      attr_accessor :cache_settings
      attr_accessor :request_settings
      attr_accessor :headers
      attr_accessor :general_settings
      attr_accessor :response_objects
      attr_accessor :gzips
      attr_accessor :directors
      attr_accessor :vcl

      def initialize(path_to_file)
        @path_to_file = path_to_file
      end

      def load
        if File.exists?(@path_to_file)
          @document = YAML.load_file(path_to_file)
          @document.keys.each do |key|
            send(:"#{key}=", @document[key])
          end
        else
          raise 'Settings file not found!'
        end
      end

      def self.from_file(path_to_file)
        new(path_to_file).load
      end
    end
  end
end
