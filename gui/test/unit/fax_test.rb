require 'test_helper'

class FaxTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Fax.new.valid?
  end
end
