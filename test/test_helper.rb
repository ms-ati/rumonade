$:.unshift(File.dirname(File.dirname(File.expand_path(__FILE__))) + '/lib')
require "rubygems"
require "test/unit"
require "rumonade"

# see http://stackoverflow.com/questions/2709361/monad-equivalent-in-ruby
module MonadAxiomTestHelpers
  def assert_monad_axiom_1(monad_class, value, f)
    assert_equal f[value], monad_class.unit(value).bind(f)
  end

  def assert_monad_axiom_2(monad)
    assert_equal monad, monad.bind(lambda { |v| monad.class.unit(v) })
  end

  def assert_monad_axiom_3(monad, f, g)
    assert_equal monad.bind(f).bind(g), monad.bind { |x| f[x].bind(g) }
  end
end
