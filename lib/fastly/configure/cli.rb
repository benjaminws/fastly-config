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
    end
  end
end
