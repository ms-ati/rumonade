require 'singleton'

module Rumonade
  module Option
  end

  class Some
    include Option

    def initialize(value)
      @value = value
    end

    attr_reader :value

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
end
