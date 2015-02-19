require 'thor'
require 'fastly/configure'

class Fastly
  module Configure
    class CLI < Thor

      desc 'vcl [PATH TO YAML] [SERVICE NAME] [OUTPUT DIRECTORY]', 'Builds a new VCL'
      def vcl(path_to_yaml, service_name, output = './')
        settings = { settings_file: path_to_yaml,
                     service_name: service_name,
                     operation: 'vcl',
                     output_directory: output }
        CDN.new(settings).build
      end

      desc 'deploy [PATH TO YAML] [SERVICE NAME] [API_KEY] [OUTPUT DIRECTORY]',
        'Builds a new VCL and deploys Fastly service configuration'
      def deploy(path_to_yaml, service_name, api_key = nil, output = './')
        api_key = ENV['FASTLY_API_KEY'] || api_key

        settings = { settings_file: path_to_yaml,
                     service_name: service_name,
                     operation: 'fastly',
                     api_key: api_key,
                     output_directory: output }
        CDN.new(settings).build
      end
    end
  end
end
