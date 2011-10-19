require "delegate"

module Rumonade

  # A partial function is a unary function where the domain does not necessarily include all values.
  # The function {#defined_at?} allows to test dynamically if a value is in the domain of the function.
  #
  # NOTE: This is only here to mimic the Scala library just enough to allow a close translation of the exception
  # handling functionality. It's not because I'm the sort that just loves pure functional idioms so damn much for
  # their own sake. Just FYI.
  class PartialFunction < DelegateClass(Proc)
    def initialize(defined_at_proc, call_proc)
      super(call_proc)
      @defined_at_proc = defined_at_proc
    end

    # Checks if a value is contained in the function's domain.
    # @param x the value to test
    # @return [Boolean] Returns +true+, iff +x+ is in the domain of this function, +false+ otherwise.
    def defined_at?(x)
      @defined_at_proc.call(x)
    end

    # Composes this partial function with a fallback partial function which
    # gets applied where this partial function is not defined.
    # @param [PartialFunction] other the fallback function
    # @return [PartialFunction] a partial function which has as domain the union of the domains
    #         of this partial function and +other+. The resulting partial function takes +x+ to +self.call(x)+
    #         where +self+ is defined, and to +other.call(x)+ where it is not.
    def or_else(other)
      PartialFunction.new(lambda { |x| self.defined_at?(x) || other.defined_at?(x) },
                          lambda { |x| if self.defined_at?(x) then self.call(x) else other.call(x) end })
    end

    # Composes this partial function with a transformation function that
    # gets applied to results of this partial function.
    # @param  [Proc] func the transformation function
    # @return [PartialFunction] a partial function with the same domain as this partial function, which maps
    #         arguments +x+ to +func.call(self.call(x))+.
    def and_then(func)
      PartialFunction.new(@defined_at_proc, lambda { |x| func.call(self.call(x)) })
    end
  end

  # Classes representing the components of exception handling.
  # Each class is independently composable.  Some example usages:
  #
  #   require "rumonade"
  #   require "uri"
  #
  #   s = "http://"
  #   x1 = catching(URI::InvalidURIError).opt { URI.parse(s) }
  #   x2 = catching(URI::InvalidURIError, NoMethodError).either { URI.parse(s) }
  #
  module ErrorHandling

    # Should re-raise exceptions like +Interrupt+ and +NoMemoryError+ by default.
    # @param [Exception] ex the exception to consider re-raising
    # @return [Boolean] Returns +true+ if a subclass of +StandardError+, otherwise +false+.
    def should_reraise?(ex)
      case ex
        when StandardError; false
        else true
      end
    end
  end
end