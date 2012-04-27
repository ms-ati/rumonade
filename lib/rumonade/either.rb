require 'rumonade/monad'

module Rumonade
  # Represents a value of one of two possible types (a disjoint union).
  # The data constructors {Rumonade::Left} and {Rumonade::Right} represent the two possible values.
  # The +Either+ type is often used as an alternative to {Rumonade::Option} where {Rumonade::Left} represents
  # failure (by convention) and {Rumonade::Right} is akin to {Rumonade::Some}.
  # @abstract
  class Either
    def initialize
      raise(TypeError, "class Either is abstract; cannot be instantiated") if self.class == Either
    end
    private :initialize

    # @return [Boolean] Returns +true+ if this is a {Rumonade::Left}, +false+ otherwise.
    def left?
      is_a?(Left)
    end

    # @return [Boolean] Returns +true+ if this is a {Rumonade::Right}, +false+ otherwise.
    def right?
      is_a?(Right)
    end

    # @return [Boolean] If this is a Left, then return the left value in Right or vice versa.
    def swap
      if left? then Right(left_value) else Left(right_value) end
    end

    # @param [Proc] function_of_left_value the function to apply if this is a Left
    # @param [Proc] function_of_right_value the function to apply if this is a Right
    # @return Returns the results of applying the function
    def fold(function_of_left_value, function_of_right_value)
      if left? then function_of_left_value.call(left_value) else function_of_right_value.call(right_value) end
    end

    # @return [LeftProjection] Projects this Either as a Left.
    def left
      LeftProjection.new(self)
    end

    # @return [RightProjection] Projects this Either as a Right.
    def right
      RightProjection.new(self)
    end

    # @param [Either] other the either to combine with
    # @return [Either] Returns a +Left+ with all Left values (if any), otherwise a +Right+ with all Right values
    def +(other)
      if [self, other].any?(&:left?)
        Left([self, other].map { |either| either.left.to_opt }.flatten)
      else
        Right([self, other].map { |either| either.right.to_opt }.flatten)
      end
    end
  end

  # The left side of the disjoint union, as opposed to the Right side.
  class Left < Either
    # @param left_value the value to store in a +Left+, usually representing a failure result
    def initialize(left_value)
      @left_value = left_value
    end

    # @return Returns the left value
    attr_reader :left_value

    # @return [Boolean] Returns +true+ if other is a +Left+ with an equal left value
    def ==(other)
      other.is_a?(Left) && other.left_value == self.left_value
    end

    # @return [String] Returns a +String+ representation of this object.
    def to_s
      "Left(#{left_value})"
    end
  end

  # The right side of the disjoint union, as opposed to the Left side.
  class Right < Either
    # @param right_value the value to store in a +Right+, usually representing a success result
    def initialize(right_value)
      @right_value = right_value
    end

    # @return Returns the right value
    attr_reader :right_value

    # @return [Boolean] Returns +true+ if other is a +Right+ with an equal right value
    def ==(other)
      other.is_a?(Right) && other.right_value == self.right_value
    end

    # @return [String] Returns a +String+ representation of this object.
    def to_s
      "Right(#{right_value})"
    end
  end

  # @param (see Left#initialize)
  # @return [Left]
  def Left(left_value)
    Left.new(left_value)
  end

  # @param (see Right#initialize)
  # @return [Right]
  def Right(right_value)
    Right.new(right_value)
  end

  class Either
    # Projects an Either into a Left.
    class LeftProjection
      class << self
        # @return [LeftProjection] Returns a +LeftProjection+ of the +Left+ of the given value
        def unit(value)
          self.new(Left(value))
        end

        # @return [LeftProjection] Returns the empty +LeftProjection+
        def empty
          self.new(Right(nil))
        end
      end

      # @param either_value [Object] the Either value to project
      def initialize(either_value)
        @either_value = either_value
      end

      # @return Returns the Either value
      attr_reader :either_value

      # @return [Boolean] Returns +true+ if other is a +LeftProjection+ with an equal +Either+ value
      def ==(other)
        other.is_a?(LeftProjection) && other.either_value == self.either_value
      end

      # Binds the given function across +Left+.
      def bind(lam = nil, &blk)
        if !either_value.left? then either_value else (lam || blk).call(either_value.left_value) end
      end

      include Monad

      # @return [Boolean] Returns +false+ if +Right+ or returns the result of the application of the given function to the +Left+ value.
      def any?(lam = nil, &blk)
        either_value.left? && bind(lam || blk)
      end

      # @return [Option] Returns +None+ if this is a +Right+ or if the given predicate does not hold for the +left+ value, otherwise, returns a +Some+ of +Left+.
      def select(lam = nil, &blk)
        Some(self).select { |lp| lp.any?(lam || blk) }.map { |lp| lp.either_value }
      end

      # @return [Boolean] Returns +true+ if +Right+ or returns the result of the application of the given function to the +Left+ value.
      def all?(lam = nil, &blk)
        !either_value.left? || bind(lam || blk)
      end

      # Returns the value from this +Left+ or raises +NoSuchElementException+ if this is a +Right+.
      def get
        if either_value.left? then either_value.left_value else raise NoSuchElementError end
      end

      # Returns the value from this +Left+ or the given argument if this is a +Right+.
      def get_or_else(val_or_lam = nil, &blk)
        v_or_f = val_or_lam || blk
        if either_value.left? then either_value.left_value else (v_or_f.respond_to?(:call) ? v_or_f.call : v_or_f) end
      end

      # @return [Option] Returns a +Some+ containing the +Left+ value if it exists or a +None+ if this is a +Right+.
      def to_opt
        Option(get_or_else(nil))
      end

      # @return [Either] Maps the function argument through +Left+.
      def map(lam = nil, &blk)
        bind { |v| Left((lam || blk).call(v)) }
      end

      # @return [String] Returns a +String+ representation of this object.
      def to_s
        "LeftProjection(#{either_value})"
      end
    end

    # Projects an Either into a Right.
    class RightProjection
      class << self
        # @return [RightProjection] Returns a +RightProjection+ of the +Right+ of the given value
        def unit(value)
          self.new(Right(value))
        end

        # @return [RightProjection] Returns the empty +RightProjection+
        def empty
          self.new(Left(nil))
        end
      end

      # @param either_value [Object] the Either value to project
      def initialize(either_value)
        @either_value = either_value
      end

      # @return Returns the Either value
      attr_reader :either_value

      # @return [Boolean] Returns +true+ if other is a +RightProjection+ with an equal +Either+ value
      def ==(other)
        other.is_a?(RightProjection) && other.either_value == self.either_value
      end

      # Binds the given function across +Right+.
      def bind(lam = nil, &blk)
        if !either_value.right? then either_value else (lam || blk).call(either_value.right_value) end
      end

      include Monad

      # @return [Boolean] Returns +false+ if +Left+ or returns the result of the application of the given function to the +Right+ value.
      def any?(lam = nil, &blk)
        either_value.right? && bind(lam || blk)
      end

      # @return [Option] Returns +None+ if this is a +Left+ or if the given predicate does not hold for the +Right+ value, otherwise, returns a +Some+ of +Right+.
      def select(lam = nil, &blk)
        Some(self).select { |lp| lp.any?(lam || blk) }.map { |lp| lp.either_value }
      end

      # @return [Boolean] Returns +true+ if +Left+ or returns the result of the application of the given function to the +Right+ value.
      def all?(lam = nil, &blk)
        !either_value.right? || bind(lam || blk)
      end

      # Returns the value from this +Right+ or raises +NoSuchElementException+ if this is a +Left+.
      def get
        if either_value.right? then either_value.right_value else raise NoSuchElementError end
      end

      # Returns the value from this +Right+ or the given argument if this is a +Left+.
      def get_or_else(val_or_lam = nil, &blk)
        v_or_f = val_or_lam || blk
        if either_value.right? then either_value.right_value else (v_or_f.respond_to?(:call) ? v_or_f.call : v_or_f) end
      end

      # @return [Option] Returns a +Some+ containing the +Right+ value if it exists or a +None+ if this is a +Left+.
      def to_opt
        Option(get_or_else(nil))
      end

      # @return [Either] Maps the function argument through +Right+.
      def map(lam = nil, &blk)
        bind { |v| Right((lam || blk).call(v)) }
      end

      # @return [String] Returns a +String+ representation of this object.
      def to_s
        "RightProjection(#{either_value})"
      end
    end
  end
end