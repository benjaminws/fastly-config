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

      desc 'deploy [PATH TO YAML] [SERVICE NAME] [USER] [PASS] [OUTPUT DIRECTORY]',
        'Builds a new VCL and deploys Fastly service configuration'
      def deploy(path_to_yaml, service_name, user, password, output = './')
        settings = { settings_file: path_to_yaml,
                     service_name: service_name,
                     operation: 'fastly',
                     user: user,
                     pass: password,
                     output_directory: output }
        CDN.new(settings).build
      end
    end
  end
end
