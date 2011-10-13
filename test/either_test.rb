require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class EitherTest < Test::Unit::TestCase
  include Rumonade
  include MonadAxiomTestHelpers

  def test_when_either_constructor_raises
    assert_raise(TypeError) { Either.new }
  end

  def test_when_left_or_right_returns_new_left_or_right
    assert_equal Left.new("error"), Left("error")
    assert_equal Right.new(42), Right(42)
  end

  def test_predicates_for_left_and_right
    assert Left("error").left?
    assert !Right(42).left?
    assert Right(42).right?
    assert !Left("error").right?
  end

  def test_swap_for_left_and_right
    assert_equal Left(42), Right(42).swap
    assert_equal Right("error"), Left("error").swap
  end

  def test_fold_for_left_and_right
    times_two = lambda { |v| v * 2 }
    times_ten = lambda { |v| v * 10 }
    assert_equal "errorerror", Left("error").fold(times_two, times_ten)
    assert_equal 420, Right(42).fold(times_two, times_ten)
  end

  def test_projections_for_left_and_right
    assert_equal LeftProjection.new(Left("error")), Left("error").left
    assert_equal RightProjection.new(Left("error")), Left("error").right
    assert_equal LeftProjection.new(Right(42)), Right(42).left
    assert_equal RightProjection.new(Right(42)), Right(42).right

    assert_not_equal LeftProjection.new(Left("error")), Left("error").right
    assert_not_equal RightProjection.new(Left("error")), Left("error").left
    assert_not_equal LeftProjection.new(Right(42)), Right(42).right
    assert_not_equal RightProjection.new(Right(42)), Right(42).left
  end
end
