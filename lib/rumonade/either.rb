require 'singleton'
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
      # @param either_value [Object] the Either value to project
      def initialize(either_value)
        @either_value = either_value
      end

      # @return Returns the Either value
      attr_reader :either_value

      def ==(other)
        other.is_a?(LeftProjection) && other.either_value == self.either_value
      end

      def bind(lam = nil, &blk)
        !either_value.left? ? either_value : (lam || blk).call(either_value.left_value)
      end
      alias_method :flat_map, :bind
    end

    # Projects an Either into a Right.
    class RightProjection
      # @param either_value [Object] the Either value to project
      def initialize(either_value)
        @either_value = either_value
      end

      # @return Returns the Either value
      attr_reader :either_value

      def ==(other)
        other.is_a?(RightProjection) && other.either_value == self.either_value
      end

      def bind(lam = nil, &blk)
        !either_value.right? ? either_value : (lam || blk).call(either_value.right_value)
      end
      alias_method :flat_map, :bind
    end
  end
end