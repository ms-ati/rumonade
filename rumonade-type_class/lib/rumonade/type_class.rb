class TypeClass
  module Finders
  end

  class << self
    def [](klass)
      all[self][klass] || if klass.superclass && klass.superclass != Object
                            self[klass.superclass]
                          else
                            raise("No type class instance found for #{self}[#{klass}]")
                          end
    end

    def []=(klass, impl)
      all[self][klass] = impl.new
      type_class = self
      Finders.module_eval do
        define_method(type_class.to_s.to_sym) do |object|
          type_class[object.class].proxy(object)
        end
        module_function type_class.to_s.to_sym
      end
    end

    def all
      @all ||= Hash.new({})
    end

    def inherited(subclass)
      puts "inherited: #{subclass} from #{self}"
      # Finders.module_eval do
      #   define_method(subclass.to_s.to_sym) do |object|
      #     subclass[object.class].proxy(object)
      #   end
      #   module_function subclass.to_s.to_sym
      # end
    end
  end

  def proxy(object)
    if self.class.const_defined? :SyntaxProxy
      self.class::SyntaxProxy.new(self, object)
    else
      object
    end
  end

  class BaseSyntaxProxy
    def initialize(impl, object)
      @impl = impl
      @object = object
    end
  end
end

class Semigroup < TypeClass
  def append(a, b)
  end
end

class SemigroupPlus < Semigroup
  def append(a, b)
    a + b
  end
end

class SemigroupTimes < Semigroup
  def append(a, b)
    a * b
  end

  class SyntaxProxy < TypeClass::BaseSyntaxProxy
    def append(other)
      @impl.append(@object, other)
    end

    def ||()
  end
end


Semigroup[String] = SemigroupPlus
Semigroup[Numeric] = SemigroupTimes

#puts TypeClass[String]
puts Semigroup[String]

puts Semigroup[String].append('hello', 'world')

include TypeClass::Finders
puts Semigroup('a') + Semigroup('b')
puts Semigroup(2) + Semigroup(3)
#puts SemigroupPlus('a')
#exit