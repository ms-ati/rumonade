require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ArrayTest < Test::Unit::TestCase
  include Rumonade
  include MonadAxiomTestHelpers

  def test_when_unit_returns_1_elt_array
    assert_equal [1], Array.unit(1)
  end

  def test_when_empty_returns_empty_array
    assert_equal [], Array.empty
  end

  def test_monad_axioms
    f = lambda { |x| Array.unit(x && x * 2) }
    g = lambda { |x| Array.unit(x && x * 5) }
    [1, 42].each do |value|
      assert_monad_axiom_1(Array, value, f)
      assert_monad_axiom_2(Array.unit(value))
      assert_monad_axiom_3(Array.unit(value), f, g)
    end
  end

  def test_flat_map_behaves_correctly
    assert_equal ["FOO", "BAR"], ["foo", "bar"].flat_map { |s| [s.upcase] }
  end

  def test_map_behaves_correctly
    assert_equal ["FOO", "BAR"], ["foo", "bar"].map { |s| s.upcase }
  end

  def test_shallow_flatten_behaves_correctly
    assert_equal [0, 1, [2], [[3]]], [0, [1], [[2]], [[[3]]]].shallow_flatten
  end

  def test_flatten_behaves_correctly
    assert_equal [0, 1, 2, 3], [0, [1], [[2]], [[[3]]]].flatten
  end
end