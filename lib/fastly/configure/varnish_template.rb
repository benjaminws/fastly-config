class Fastly
  module Configure
    class VarnishTemplate
      def initialize(settings)
        @backends = settings["backends"]
        @conditions = settings["conditions"]
        @cache_settings = settings["cache_settings"]
        @request_settings = settings["request_settings"]
        @headers = settings["headers"]
        @settings = settings["settings"]
        @response_objects = settings["response_objects"]
        @gzips = settings["gzips"]
        @directors = settings["directors"]
      end

      def create_vcl(template_path, output_path, do_full_vcl)
        @do_full_vcl = do_full_vcl
        erb_template_file = File.open(template_path, 'r').read
        template = ERB.new(erb_template_file)
        File.open(output_path, "w+") { |file| file.write(template.result(binding)) }
      end
    end
  end
end

