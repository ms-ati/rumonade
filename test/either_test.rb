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
    assert_equal Either::LeftProjection.new(Left("error")), Left("error").left
    assert_equal Either::RightProjection.new(Left("error")), Left("error").right
    assert_equal Either::LeftProjection.new(Right(42)), Right(42).left
    assert_equal Either::RightProjection.new(Right(42)), Right(42).right

    assert_not_equal Either::LeftProjection.new(Left("error")), Left("error").right
    assert_not_equal Either::RightProjection.new(Left("error")), Left("error").left
    assert_not_equal Either::LeftProjection.new(Right(42)), Right(42).right
    assert_not_equal Either::RightProjection.new(Right(42)), Right(42).left
  end

  def test_flat_map_for_left_and_right_projections_returns_eithers
    assert_equal Left("42"), Right(42).right.flat_map { |n| Left(n.to_s) }
    assert_equal Right(42), Right(42).left.flat_map { |n| Left(n.to_s) }
    assert_equal Right("ERROR"), Left("error").left.flat_map { |n| Right(n.upcase) }
    assert_equal Left("error"), Left("error").right.flat_map { |n| Right(n.upcase) }
  end

  def test_any_predicate_for_left_and_right_projections_returns_true_if_correct_type_and_block_returns_true
    assert Left("error").left.any? { |s| s == "error" }
    assert !Left("error").left.any? { |s| s != "error" }
    assert !Left("error").right.any? { |s| s == "error" }

    assert Right(42).right.any? { |n| n == 42 }
    assert !Right(42).right.any? { |n| n != 42 }
    assert !Right(42).left.any? { |n| n == 42 }
  end

  def test_select_for_left_and_right_projects_returns_option_of_either_if_correct_type_and_block_returns_true
    assert_equal Some(Left("error")), Left("error").left.select { |s| s == "error" }
    assert_equal None, Left("error").left.select { |s| s != "error" }
    assert_equal None, Left("error").right.select { |s| s == "error" }

    assert_equal Some(Right(42)), Right(42).right.select { |n| n == 42 }
    assert_equal None, Right(42).right.select { |n| n != 42 }
    assert_equal None, Right(42).left.select { |n| n == 42 }    
  end
  
  def test_all_predicate_for_left_and_right_projections_returns_true_if_correct_type_and_block_returns_true
    assert Left("error").left.all? { |s| s == "error" }
    assert !Left("error").left.all? { |s| s != "error" }
    assert Left("error").right.all? { |s| s == "error" }

    assert Right(42).right.all? { |n| n == 42 }
    assert !Right(42).right.all? { |n| n != 42 }
    assert Right(42).left.all? { |n| n == 42 }
  end  

  def test_each_for_left_and_right_projections_executes_block_if_correct_type
    def side_effect_occurred_on_each(projection)
      side_effect_occurred = false
      projection.each { |s| side_effect_occurred = true }
      side_effect_occurred
    end

    assert side_effect_occurred_on_each(Left("error").left)
    assert !side_effect_occurred_on_each(Left("error").right)

    assert side_effect_occurred_on_each(Right(42).right)
    assert !side_effect_occurred_on_each(Right(42).left)
  end

  def test_unit_for_left_and_right_projections
    assert_equal Left("error").left, Either::LeftProjection.unit("error")
    assert_equal Right(42).right, Either::RightProjection.unit(42)
  end

  def test_empty_for_left_and_right_projections
    assert_equal Right(nil).left, Either::LeftProjection.empty
    assert_equal Left(nil).right, Either::RightProjection.empty
  end

  def test_monad_axioms_for_left_and_right_projections
    assert_monad_axiom_1(Either::LeftProjection, "error", lambda { |x| Left(x * 2).left })
    assert_monad_axiom_2(Left("error").left)
    assert_monad_axiom_3(Left("error").left, lambda { |x| Left(x * 2).left }, lambda { |x| Left(x * 5).left })

    assert_monad_axiom_1(Either::RightProjection, 42, lambda { |x| Right(x * 2).right })
    assert_monad_axiom_2(Right(42).right)
    assert_monad_axiom_3(Right(42).right, lambda { |x| Right(x * 2).right }, lambda { |x| Right(x * 5).right })
  end

  def test_get_for_left_and_right_projections_returns_value_if_correct_type_or_raises
    assert_equal "error", Left("error").left.get
    assert_raises(NoSuchElementError) { Left("error").right.get }
    assert_equal 42, Right(42).right.get
    assert_raises(NoSuchElementError) { Right(42).left.get }
  end

  def test_get_or_else_for_left_and_right_projections_returns_value_if_correct_type_or_returns_value_or_executes_block
    assert_equal "error", Left("error").left.get_or_else(:other_value)
    assert_equal :other_value, Left("error").right.get_or_else(:other_value)
    assert_equal :value_of_block, Left("error").right.get_or_else(lambda { :value_of_block })

    assert_equal 42, Right(42).right.get_or_else(:other_value)
    assert_equal :other_value, Right(42).left.get_or_else(:other_value)
    assert_equal :value_of_block, Right(42).left.get_or_else(lambda { :value_of_block })
  end

  def test_to_opt_for_left_and_right_projections_returns_Some_if_correct_type_or_None
    assert_equal Some("error"), Left("error").left.to_opt
    assert_equal None, Left("error").right.to_opt
    assert_equal Some(42), Right(42).right.to_opt
    assert_equal None, Right(42).left.to_opt
  end

  def test_to_a_for_left_and_right_projections_returns_single_element_Array_if_correct_type_or_zero_element_Array
    assert_equal ["error"], Left("error").left.to_a
    assert_equal [], Left("error").right.to_a
    assert_equal [42], Right(42).right.to_a
    assert_equal [], Right(42).left.to_a
  end

  def test_map_for_left_and_right_projections_returns_same_projection_type_of_new_value_if_correct_type
    assert_equal Left(:ERROR), Left("error").left.map { |s| s.upcase.to_sym }
    assert_equal Left("error"), Left("error").right.map { |s| s.upcase.to_sym }
    assert_equal Right(420), Right(42).right.map { |s| s * 10 }
    assert_equal Right(42), Right(42).left.map { |s| s * 10 }
  end

  def test_to_s_for_left_and_right_and_their_projections
    assert_equal "Left(error)", Left("error").to_s
    assert_equal "Right(42)", Right(42).to_s
    assert_equal "RightProjection(Left(error))", Left("error").right.to_s
    assert_equal "LeftProjection(Right(42))", Right(42).left.to_s
  end

  def test_plus_concatenates_left_and_right_using_plus_operator
    assert_equal Left("badworse"), Left("bad") + Right(1) + Left("worse") + Right(2)
    assert_equal Left(["bad", "worse"]), Left(["bad"]) + Right(1) + Left(["worse"]) + Right(2)
    assert_equal Right(3), Right(1) + Right(2)
  end

  def test_concat_concatenates_left_and_right_with_custom_concatenation_function
    multiply = lambda { |a, b| a * b }
    assert_equal Left(33), Left(3).concat(Left(11), :concat_left => multiply)
    assert_equal Left(14), Left(3).concat(Left(11), :concat_right => multiply)
    assert_equal Right(44), Right(4).concat(Right(11), :concat_right => multiply)
    assert_equal Right(15), Right(4).concat(Right(11), :concat_left => multiply)
  end
end
