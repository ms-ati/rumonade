require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class ErrorHandlingTest < Test::Unit::TestCase
  include Rumonade
  include Rumonade::ErrorHandling

  def test_partial_function_constructor_delegates_call_and_defined_at_to_given_procs
    pf = PartialFunction.new(lambda { |x| x < 1000 }, lambda { |x| x * 10 })
    assert pf.defined_at?(999)
    assert !pf.defined_at?(1000)
    assert_equal 420, pf.call(42)
  end

  def test_partial_function_or_else_returns_a_partial_function_with_union_of_defined_at_predicates
    pf = PartialFunction.new(lambda { |x| x < 1000 }, lambda { |x| x * 10 })
      .or_else(PartialFunction.new(lambda { |x| x > 5000 }, lambda { |x| x / 5 }))
    assert pf.defined_at?(999)
    assert !pf.defined_at?(1000)
    assert !pf.defined_at?(5000)
    assert pf.defined_at?(5001)
  end

  def test_partial_function_or_else_returns_a_partial_function_with_fallback_when_outside_defined_at
    pf = PartialFunction.new(lambda { |x| x < 1000 }, lambda { |x| x * 10 })
      .or_else(PartialFunction.new(lambda { |x| x > 5000 }, lambda { |x| x / 5 }))
    assert_equal 9990, pf.call(999)
    assert_equal 1001, pf.call(5005)
  end

  def test_partial_function_and_then_returns_a_partial_function_with_func_called_on_result_of_pf_call
    pf = PartialFunction.new(lambda { |x| x < 1000 }, lambda { |x| x * 10 })
      .and_then(lambda { |x| x / 5 })
    assert_equal 1800, pf.call(900)
  end

  def test_should_reraise_returns_true_if_not_subclass_of_standard_error
    assert should_reraise?(NoMemoryError.new)
    assert !should_reraise?(ZeroDivisionError.new)
  end
end