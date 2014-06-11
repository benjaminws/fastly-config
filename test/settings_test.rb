require 'test_helper'

class Fastly
  module Configure
    describe Settings do
      let(:path_to_file) { './test/fixtures/dev-images.yml' }
      let(:parsed_yaml)  { YAML.load_file(path_to_file) }

      describe '#load' do
        it 'should fail unless file exists' do
          assert_raises(RuntimeError) { Settings.new('fake/path').load }
        end
      end

      describe '.from_file' do
        let(:settings) { Settings.from_file(path_to_file) }

        it 'should parse YAML and load settings from file' do
          assert_equal Settings.new(path_to_file).load, settings
        end
      end

      describe 'attributes' do
        let(:settings) { Settings.new(path_to_file) }

        before do
          settings.load
        end

        it 'should have a bunch of attributes set' do
          assert_equal parsed_yaml['service'], settings.service
          assert_equal parsed_yaml['general_settings'], settings.general_settings
          assert_equal parsed_yaml['domains'], settings.domains
        end
      end
    end
  end
end
