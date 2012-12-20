require 'test_helper'

class ServiceTypeTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert ServiceType.new.valid?
  end
end
