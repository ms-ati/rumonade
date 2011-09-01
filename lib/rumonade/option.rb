require 'singleton'

module Rumonade
  module Option
    def self.unit(value)
      Rumonade.Option(value)
    end

    def bind(lam = nil, &blk)
      f = lam || blk
      empty? ? self : f[value]
    end

    def self.included(mod)
      mod.send(:define_method, :unit) { |value| Rumonade::Option.unit(value) }
    end
  end

  class Some
    include Option

    def initialize(value)
      @value = value
    end

    attr_reader :value

    def self.unit(value)
      Option.unit(value)
    end

    def empty?
      false
    end

    def ==(other)
      other.is_a?(Some) && other.value.eql?(value)
    end
  end

  class NoneClass
    include Option
    include Singleton

    def empty?
      true
    end

    def ==(other)
      other.equal?(self.class.instance)
    end
  end

  def Option(value)
    value.nil? ? None : Some(value)
  end

  def Some(value)
    Some.new(value)
  end

  None = NoneClass.instance

  module_function :Option, :Some
  public :Option, :Some
end
