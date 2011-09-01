# Adapted from http://stackoverflow.com/questions/2709361/monad-equivalent-in-ruby
class LazyIdentity
  def initialize(lam = nil, &blk)
    @lazy = lam || blk
    @lazy.is_a?(Proc) || raise(ArgumentError, "not a Proc")
    @lazy.arity.zero? || raise(ArgumentError, "arity must be 0, was #{@lazy.arity}")
  end

  attr_reader :lazy

  def force
    @lazy[]
  end

  def self.unit(lam = nil, &blk)
    LazyIdentity.new(lam || blk)
  end

  def bind(lam = nil, &blk)
    f = lam || blk
    f[@lazy]
  end

  def ==(other)
    other.is_a?(LazyIdentity) && other.force == force
  end
end
