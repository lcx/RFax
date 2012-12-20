require 'test_helper'

class MailHeaderTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert MailHeader.new.valid?
  end
end
