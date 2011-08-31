require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class OptionTest < Test::Unit::TestCase
  include Rumonade

  def test_when_option_with_nil_returns_none_singleton
    assert_same None, Option(nil)
    assert_same NoneClass.instance, None
  end

  def test_when_option_with_value_returns_some
    assert_equal Some.new(42), Some(42)
    assert_equal Some(42), Option(42)
    assert_not_equal None, Some(nil)
  end

end