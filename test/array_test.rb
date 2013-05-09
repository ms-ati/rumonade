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
    assert_equal [2, 4, 6], [1, 2, 3].flat_map { |i| [i * 2] }
  end

  def test_map_behaves_correctly
    assert_equal ["FOO", "BAR"], ["foo", "bar"].map { |s| s.upcase }
    assert_equal [2, 4, 6], [1, 2, 3].map { |i| i * 2 }
  end

  def test_shallow_flatten_behaves_correctly
    assert_equal [0, 1, [2], [[3]], [[[4]]]], [0, [1], [[2]], [[[3]]], [[[[4]]]]].shallow_flatten
    assert_equal [1], [None, Some(1)].shallow_flatten
    assert_equal [1, Some(2)], [None, Some(1), Some(Some(2))].shallow_flatten
    assert_equal [Some(Some(None))], [Some(Some(Some(None)))].shallow_flatten
    assert_equal [Some(1), Some(None), None], [Some(Some(1)), Some(Some(None)), [None]].shallow_flatten
  end

  def test_flatten_behaves_correctly
    assert_equal [0, 1, 2, 3, 4], [0, [1], [[2]], [[[3]]], [[[[4]]]]].flatten
    assert_equal [1, 2], [None, Some(1), Some(Some(2))].flatten
    assert_equal [], [Some(Some(Some(None)))].flatten
  end

  def test_flatten_with_argument_behaves_correctly
    assert_equal [0, 1, [2], [[3]], [[[4]]]], [0, [1], [[2]], [[[3]]], [[[[4]]]]].flatten(1)
    assert_equal [0, 1, 2, [3], [[4]]], [0, [1], [[2]], [[[3]]], [[[[4]]]]].flatten(2)
    assert_equal [0, 1, 2, 3, [4]], [0, [1], [[2]], [[[3]]], [[[[4]]]]].flatten(3)
    assert_equal [0, 1, 2, 3, 4], [0, [1], [[2]], [[[3]]], [[[[4]]]]].flatten(4)
    assert_equal [Some(Some(1)), Some(Some(None)), [None]], [Some(Some(1)), Some(Some(None)), [None]].flatten(0)
    assert_equal [Some(1), Some(None), None], [Some(Some(1)), Some(Some(None)), [None]].flatten(1)
    assert_equal [1, None], [Some(Some(1)), Some(Some(None)), [None]].flatten(2)
    assert_equal [1], [Some(Some(1)), Some(Some(None)), [None]].flatten(3)
  end
end