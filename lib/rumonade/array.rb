require 'rumonade/monad'

module Rumonade
  # TODO: Document use of Array as a Monad
  module ArrayExtensions
    module ClassMethods
      def unit(value)
        [value]
      end

      def empty
        []
      end
    end

    module InstanceMethods
      def bind(lam = nil, &blk)
        inject(self.class.empty) { |arr, elt| arr + (lam || blk).call(elt).to_a }
      end
    end
  end
end

Array.send(:extend, Rumonade::ArrayExtensions::ClassMethods)
Array.send(:include, Rumonade::ArrayExtensions::InstanceMethods)
Array.send(:include, Rumonade::Monad)
