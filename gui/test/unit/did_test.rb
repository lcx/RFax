require 'test_helper'

class DidTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Did.new.valid?
  end
end
