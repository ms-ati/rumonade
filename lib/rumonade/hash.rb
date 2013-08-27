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
      # Preserve native +map+ and +flatten+ methods for compatibility
      METHODS_TO_REPLACE_WITH_MONAD = Monad::DEFAULT_METHODS_TO_REPLACE_WITH_MONAD - [:map, :flatten]

      def bind(lam = nil, &blk)
        inject(self.class.empty) { |hsh, elt| hsh.merge((lam || blk).call(elt)) }
      end

      # @return [Option] a Some containing the value associated with +key+, or None if not present
      def get(key)
        Option(self[key])
      end
    end

    module InstanceOverrides
      def can_flatten_in_monad?
        false
      end
    end
  end
end

Hash.send(:extend, Rumonade::HashExtensions::ClassMethods)
Hash.send(:include, Rumonade::HashExtensions::InstanceMethods)
Hash.send(:include, Rumonade::Monad)
Hash.send(:include, Rumonade::HashExtensions::InstanceOverrides)
