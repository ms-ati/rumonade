require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class LazyIdentityTest < Test::Unit::TestCase
  include Rumonade
  include MonadAxiomTestHelpers

  def test_monad_axioms
    f = lambda { |lazy| v = lazy.call * 2; LazyIdentity.new { v } }
    g = lambda { |lazy| v = lazy.call + 5; LazyIdentity.new { v } }
    lazy_value = lambda { 42 } # returns 42 when called
    assert_monad_axiom_1(LazyIdentity, lazy_value, f)
    assert_monad_axiom_2(LazyIdentity.new(lazy_value))
    assert_monad_axiom_3(LazyIdentity.new(lazy_value), f, g)
  end

end