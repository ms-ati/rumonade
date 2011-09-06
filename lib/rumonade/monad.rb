module Rumonade
  module Monad
    def flat_map(lam = nil, &blk)
      bind(lam || blk)
    end

    def map(lam = nil, &blk)
      f = lam || blk
      bind { |v| f.call(v) }
    end
  end
end
