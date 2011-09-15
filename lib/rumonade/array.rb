require 'rumonade/monad'

module Rumonade
  module ArrayMonadClassMethods
    def unit(value)
      [value]
    end

    def empty
      []
    end
  end

  module ArrayMonadInstanceMethods
    include Monad

    def bind(lam = nil, &blk)
      f = lam || blk
      inject([]) { |arr, elt| arr + f.call(elt) }
    end
  end
end

class Array
  extend Rumonade::ArrayMonadClassMethods
  include Rumonade::ArrayMonadInstanceMethods
end
