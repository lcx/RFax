require 'test_helper'

class FaxChannelTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert FaxChannel.new.valid?
  end
end
