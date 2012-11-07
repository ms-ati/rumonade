require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class HashTest < Test::Unit::TestCase
  include Rumonade
  include MonadAxiomTestHelpers

  def test_when_unit_with_2_elt_array_returns_hash
    assert_equal({ :k => :v }, Hash.unit([:k, :v]))
  end

  def test_when_unit_with_non_2_elt_array_raises
    assert_raise(ArgumentError) { Hash.unit([1]) }
    assert_raise(ArgumentError) { Hash.unit([1, 2, 3]) }
    assert_raise(ArgumentError) { Hash.unit([1, 2, 3, 4]) }
    assert_raise(ArgumentError) { Hash.unit("not an array at all") }
  end

  def test_when_empty_returns_empty_array
    assert_equal({}, Hash.empty)
  end

  def test_monad_axioms
    f = lambda { |p| Hash.unit([p[0].downcase, p[1] * 2]) }
    g = lambda { |p| Hash.unit([p[0].upcase, p[1] * 5]) }
    [["Foo", 1], ["Bar", 2]].each do |value|
      assert_monad_axiom_1(Hash, value, f)
      assert_monad_axiom_2(Hash.unit(value))
      assert_monad_axiom_3(Hash.unit(value), f, g)
    end
  end

  def test_flat_map_behaves_correctly
    assert_equal({ "FOO" => 2 }, { "Foo" => 1 }.flat_map { |p| { p[0].upcase => p[1] * 2 } })
  end

  # Special case: because Hash#map is built into Ruby, must preserve existing behavior
  #def test_map_still_behaves_normally_returning_array_of_arrays
  #  assert_equal([["FOO", 2], ["BAR", 4]], { "Foo" => 1, "Bar" => 2 }.map { |p| [p[0].upcase, p[1] * 2] })
  #end

  # Add Hash#fmap to return a Hash as one might expect the monadic Hash#map to do
  def test_fmap_behaves_like_monadic_map
    assert_equal({ "FOO" => 2, "BAR" => 4 }, { "Foo" => 1, "Bar" => 2 }.fmap { |p| [p[0].upcase, p[1] * 2] })
  end

  #def test_shallow_flatten_behaves_correctly
  #  assert_equal [0, 1, [2], [[3]], [[[4]]]], [0, [1], [[2]], [[[3]]], [[[[4]]]]].shallow_flatten
  #  assert_equal [1], [None, Some(1)].shallow_flatten
  #  assert_equal [1, Some(2)], [None, Some(1), Some(Some(2))].shallow_flatten
  #  assert_equal [Some(Some(None))], [Some(Some(Some(None)))].shallow_flatten
  #end
  #
  #def test_flatten_behaves_correctly
  #  assert_equal [0, 1, 2, 3, 4], [0, [1], [[2]], [[[3]]], [[[[4]]]]].flatten
  #  assert_equal [1, 2], [None, Some(1), Some(Some(2))].flatten
  #  assert_equal [], [Some(Some(Some(None)))].flatten
  #end
end