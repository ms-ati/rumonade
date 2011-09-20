module Rumonade
  # Mix-in for common monad functionality dependent on implementation of monadic methods unit and bind
  #
  # Notes:
  # * classes should include this module AFTER defining the monadic methods unit and bind
  #
  module Monad
    METHODS_TO_REPLACE = [:flat_map, :flatten] # :nodoc:

    def self.included(base) # :nodoc:
      base.class_eval do
        # optimization: replace flat_map with an alias for bind, as they are identical
        alias_method :flat_map_with_monad, :bind

        # force only a few methods to be aliased to monad versions; others can stay with native or Enumerable versions
        METHODS_TO_REPLACE.each do |method_name|
          alias_method "#{method_name}_without_monad".to_sym, method_name if public_instance_methods.include? method_name
          alias_method method_name, "#{method_name}_with_monad".to_sym
        end
      end
    end

    include Enumerable

    # Applies the given procedure to each element in this monad
    def each(lam = nil, &blk)
      bind { |v| (lam || blk).call(v) }; nil
    end

    # Returns a monad whose elements are the results of applying the given function to each element in this monad
    def map(lam = nil, &blk)
      bind { |v| self.class.unit((lam || blk).call(v)) }
    end

    # Returns the results of applying the given function to each element in this monad
    def flat_map_with_monad(lam = nil, &blk)
      bind(lam || blk)
    end

    # Returns a monad whose elements are the ultimate (non-monadic) values contained in all nested monads
    #
    #    [1] == [[Some(Some(1)), Some(Some(None))], [None]].flatten
    #    => true
    #
    def flatten_with_monad
      bind { |x| x.is_a?(Monad) ? x.flatten_with_monad : self.class.unit(x) }
    end

    # Returns a monad whose elements are all those elements of this monad for which the given predicate returned true
    def select(lam = nil, &blk)
      bind { |x| (lam || blk).call(x) ? self.class.unit(x) : self.class.empty }
    end
    alias_method :find_all, :select

    # Returns a monad whose elements are the values contained in the first level of nested monads
    #
    # This method is equivalent to the Scala flatten call (single-level flattening), whereas #flatten is in keeping
    # with the native Ruby flatten calls (multiple-level flattening).
    #
    def shallow_flatten
      bind { |x| x.is_a?(Monad) ? x : self.class.unit(x) }
    end
  end
end
