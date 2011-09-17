module Rumonade
  # TODO: Document this
  module Monad
    METHODS_TO_REPLACE = [:flat_map, :flatten]

    def self.included(base)
      base.class_eval do
        alias_method :flat_map_with_monad, :bind

        # force only a few methods to be aliased to monad versions; others can stay with native or Enumerable versions
        METHODS_TO_REPLACE.each do |method_name|
          alias_method "#{method_name}_without_monad".to_sym, method_name if public_instance_methods.include? method_name
          alias_method method_name, "#{method_name}_with_monad".to_sym
        end
      end
    end

    include Enumerable

    def map(lam = nil, &blk)
      bind { |v| (lam || blk).call(v) }
    end

    def each(lam = nil, &blk)
      map(lam || blk); nil
    end

    def shallow_flatten
      bind { |x| x.is_a?(Monad) ? x : self.class.unit(x) }
    end

    def flatten_with_monad
      bind { |x| x.is_a?(Monad) ? x.flatten_with_monad : self.class.unit(x) }
    end
  end
end
