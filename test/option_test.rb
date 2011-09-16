require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class OptionTest < Test::Unit::TestCase
  include Rumonade
  include MonadAxiomTestHelpers

  def test_when_option_with_nil_returns_none_singleton
    assert_same None, Option.unit(nil)
    assert_same None, Option(nil)
    assert_same NoneClass.instance, None
  end

  def test_when_option_with_value_returns_some
    assert_equal Some(42), Option.unit(42)
    assert_equal Some(42), Option(42)
    assert_equal Some(42), Some.new(42)
    assert_not_equal None, Some(nil)
  end

  def test_when_option_constructor_raises
    assert_raise(TypeError) { Option.new }
  end

  def test_monad_axioms
    f = lambda { |x| Option(x && x * 2) }
    g = lambda { |x| Option(x && x * 5) }
    [nil, 42].each do |value|
      assert_monad_axiom_1(Option, value, f)
      assert_monad_axiom_2(Option(value))
      assert_monad_axiom_3(Option(value), f, g)
    end
  end

  def test_when_empty_returns_none
    assert_equal None, Option.empty
  end

  def test_when_value_on_some_returns_value_but_on_none_raises
    assert_equal "foo", Some("foo").value
    assert_raise(NoMethodError) { None.value }
  end

  def test_when_get_on_some_returns_value_but_on_none_raises
    assert_equal "foo", Some("foo").get
    assert_raise(NoSuchElementError) { None.get }
  end

  def test_when_get_or_else_on_some_returns_value_but_on_none_returns_value_or_executes_block_or_lambda
    assert_equal "foo", Some("foo").get_or_else("bar")
    assert_equal "bar", None.get_or_else("bar")
    assert_equal "blk", None.get_or_else { "blk" }
    assert_equal "lam", None.get_or_else(lambda { "lam"} )
  end

  def test_when_or_nil_on_some_returns_value_but_on_none_returns_nil
    assert_equal 123, Some(123).or_nil
    assert_nil None.or_nil
  end

  def test_flat_map_behaves_correctly
    assert_equal Some("FOO"), Some("foo").flat_map { |s| Some(s.upcase) }
    assert_equal None, None.flat_map { |s| Some(s.upcase) }
  end

  def test_map_behaves_correctly
    assert_equal "FOO", Some("foo").map { |s| s.upcase }
    assert_equal None, None.map { |s| s.upcase }
  end

  def test_shallow_flatten_behaves_correctly
    assert_equal Some(Some(1)), Some(Some(Some(1))).shallow_flatten
    assert_equal None, Some(None).shallow_flatten
    assert_equal Some(1), Some(1).shallow_flatten
  end

  def test_flatten_behaves_correctly
    assert_equal Some(1), Some(Some(Some(1))).flatten
    assert_equal None, Some(None).flatten
    assert_equal Some(1), Some(1).flatten
  end

  def test_to_s_behaves_correctly
    assert_equal "Some(1)", Some(1).to_s
    assert_equal "None", None.to_s
    assert_equal "Some(Some(None))", Some(Some(None)).to_s
  end

  def test_each_behaves_correctly
    vals = [None, Some(42)].inject([]) { |arr, opt| assert_nil(opt.each { |val| arr << val }); arr }
    assert_equal [42], vals
  end
end