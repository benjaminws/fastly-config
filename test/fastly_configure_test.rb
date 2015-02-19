require 'test_helper'

class Fastly
  describe Configure do
    it 'should have a version' do
      assert_match(/^(\d+\\.)?(\d+\\.)?(\\*|\d+)/, Fastly::Configure::VERSION)
    end
  end
end
