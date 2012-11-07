require 'rumonade/monad'

module Rumonade
  # TODO: Document use of Hash as a Monad
  module HashExtensions
    module ClassMethods
      def unit(value)
        raise ArgumentError, "argument not a 2-element Array for Hash.unit" unless (value.is_a?(Array) && value.size == 2)
        Hash[*value]
      end

      def empty
        {}
      end
    end

    module InstanceMethods
      def bind(lam = nil, &blk)
        inject(self.class.empty) { |hsh, elt| hsh.merge((lam || blk).call(elt).to_hash) }
      end
    end
  end
end

Hash.send(:extend, Rumonade::HashExtensions::ClassMethods)
Hash.send(:include, Rumonade::HashExtensions::InstanceMethods)
Hash.send(:include, Rumonade::Monad)
