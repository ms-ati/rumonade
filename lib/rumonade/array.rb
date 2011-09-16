require 'rumonade/monad'

module Rumonade
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
        f = lam || blk
        inject([]) { |arr, elt| arr + f.call(elt) }
      end

      include Monad
    end
  end
end

Array.send(:extend, Rumonade::ArrayExtensions::ClassMethods)
Array.send(:include, Rumonade::ArrayExtensions::InstanceMethods)
