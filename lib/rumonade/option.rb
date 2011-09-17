require 'singleton'
require 'rumonade/monad'

module Rumonade # :nodoc:
  # TODO: Document this
  class Option
    class << self
      def unit(value)
        Rumonade.Option(value)
      end

      def empty
        None
      end
    end

    def initialize
      raise(TypeError, "class Option is abstract; cannot be instantiated") if self.class == Option
    end

    def bind(lam = nil, &blk)
      f = lam || blk
      empty? ? self : f.call(value)
    end

    include Monad

    def empty?
      raise(NotImplementedError)
    end

    def get
      if !empty? then value else raise NoSuchElementError end
    end

    def get_or_else(val_or_lam = nil, &blk)
      v_or_f = val_or_lam || blk
      if !empty? then value else (v_or_f.respond_to?(:call) ? v_or_f.call : v_or_f) end
    end

    def or_nil
      get_or_else(nil)
    end
  end

  # TODO: Document this
  class Some < Option
    def initialize(value)
      @value = value
    end

    attr_reader :value

    def empty?
      false
    end

    def ==(other)
      other.is_a?(Some) && other.value == value
    end

    def to_s
      "Some(#{value.to_s})"
    end
  end

  # TODO: Document this
  class NoneClass < Option
    include Singleton

    def empty?
      true
    end

    def ==(other)
      other.equal?(self.class.instance)
    end

    def to_s
      "None"
    end
  end

  # TODO: Document this
  class NoSuchElementError < RuntimeError; end

  # TODO: Document this
  def Option(value)
    value.nil? ? None : Some(value)
  end

  # TODO: Document this
  def Some(value)
    Some.new(value)
  end

  # TODO: Document this
  None = NoneClass.instance

  module_function :Option, :Some
  public :Option, :Some
end
