require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "eagerly loads articles with rumonade option" do
    assert_equal Some(articles(:article_one)), User.eager_all[0].first_article
    assert_equal None, User.eager_all[1].first_article
  end
end
