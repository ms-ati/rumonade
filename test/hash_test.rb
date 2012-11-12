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
    assert_equal({ "FOO" => 2, "BAR" => 4 }, { "Foo" => 1, "Bar" => 2 }.flat_map { |p| { p[0].upcase => p[1] * 2 } })
  end

  # Special case: because Hash#map is built into Ruby, must preserve existing behavior
  def test_map_still_behaves_normally_returning_array_of_arrays
   assert_equal([["FOO", 2], ["BAR", 4]], { "Foo" => 1, "Bar" => 2 }.map { |p| [p[0].upcase, p[1] * 2] })
  end

  # We add Hash#map_with_monad to return a Hash, as one might expect Hash#map to do
  def test_map_with_monad_behaves_correctly_returning_hash
    assert_equal({ "FOO" => 2, "BAR" => 4 }, { "Foo" => 1, "Bar" => 2 }.map_with_monad { |p| [p[0].upcase, p[1] * 2] })
  end

  # Special case: because Hash#flatten is built into Ruby, must preserver existing behavior
  def test_flatten_still_behaves_normaly_returning_array_of_alternating_keys_and_values
   assert_equal ["Foo", 1, "Bar", 2], { "Foo" => 1, "Bar" => 2 }.flatten
  end

  def test_shallow_flatten_raises_type_error
    assert_raise(TypeError) { { "Foo" => "Bar" }.shallow_flatten }
  end
end