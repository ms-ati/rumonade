require 'singleton'
require 'rumonade/monad'

module Rumonade # :nodoc:
  # Represents optional values. Instances of Option are either an instance of Some or the object None.
  #
  # The most idiomatic way to use an Option instance is to treat it as a collection or monad
  # and use map, flat_map, select, or each:
  #
  #   name = Option(params[:name])
  #   upper = name.map(&:strip).select { |s| s.length != 0 }.map(&:upcase)
  #   puts upper.get_or_else("")
  #
  # Note that this is equivalent to
  #
  #   # TODO: IMPLEMENT FOR COMPREHENSIONS
  #   # see http://stackoverflow.com/questions/1052476/can-someone-explain-scalas-yield
  #   val upper = for {
  #     name    <- Option(params[:name])
  #     trimmed <- Some(name.strip)
  #     upper   <- Some(trimmed.upcase) if trimmed.length != 0
  #   } yield upper
  #   puts upper.get_or_else("")
  #
  # Because of how for comprehension works, if None is returned from params#[], the entire expression results in None
  # This allows for sophisticated chaining of Option values without having to check for the existence of a value.
  #
  # A less-idiomatic way to use Option values is via direct comparison:
  #
  #   name_opt = params[:name]
  #   case name_opt
  #     when Some
  #       puts name_opt.get.strip.upcase
  #     when None
  #       puts "No name value"
  #   end
  #
  # @abstract
  class Option
    class << self
      # @return [Option] Returns an +Option+ containing the given value
      def unit(value)
        Rumonade.Option(value)
      end

      # @return [Option] Returns the empty +Option+
      def empty
        None
      end
    end

    def initialize
      raise(TypeError, "class Option is abstract; cannot be instantiated") if self.class == Option
    end
    private :initialize

    # Returns None if None, or the result of executing the given block or lambda on the contents if Some
    def bind(lam = nil, &blk)
      empty? ? self : (lam || blk).call(value)
    end

    include Monad

    # @return [Boolean] Returns +true+ if +None+, +false+ if +Some+
    def empty?
      raise(NotImplementedError)
    end

    # Returns contents if Some, or raises NoSuchElementError if None
    def get
      if !empty? then value else raise NoSuchElementError end
    end

    # Returns contents if Some, or given value or result of given block or lambda if None
    def get_or_else(val_or_lam = nil, &blk)
      v_or_f = val_or_lam || blk
      if !empty? then value else (v_or_f.respond_to?(:call) ? v_or_f.call : v_or_f) end
    end

    # Returns contents if Some, or +nil+ if None
    def or_nil
      get_or_else(nil)
    end
  end

  # Represents an Option containing a value
  class Some < Option
    def initialize(value)
      @value = value
    end

    attr_reader :value # :nodoc:

    # @return (see Option#empty?)
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

  # Represents an Option which is empty, accessed via the constant None
  class NoneClass < Option
    include Singleton

    # @return (see Option#empty?)
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

  # Exception raised on attempts to access the value of None
  class NoSuchElementError < RuntimeError; end

  # Returns an Option wrapping the given value: Some if non-nil, None if nil
  def Option(value)
    value.nil? ? None : Some(value)
  end

  # @return [Some] Returns a +Some+ wrapping the given value, for convenience
  def Some(value)
    Some.new(value)
  end

  # The single global instance of NoneClass, representing the empty Option
  None = NoneClass.instance # :doc:

  module_function :Option, :Some
  public :Option, :Some
end
