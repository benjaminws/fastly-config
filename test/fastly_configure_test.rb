require 'test_helper'

class Fastly
  describe Configure do
    it 'should have a version' do
      assert_equal '0.1.0', Fastly::Configure::VERSION
    end
  end
end
