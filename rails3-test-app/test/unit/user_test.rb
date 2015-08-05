require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "eagerly loads articles" do
    User.eager_all
  end
end
