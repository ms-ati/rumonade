# [Rumonade](https://rubygems.org/gems/rumonade)

[![Build Status](https://travis-ci.org/ms-ati/rumonade.png)](https://travis-ci.org/ms-ati/rumonade)
[![Dependency Status](https://gemnasium.com/ms-ati/rumonade.png)](https://gemnasium.com/ms-ati/rumonade)

*_Project_*: [github](http://github.com/ms-ati/rumonade)

*_Documentation_*: [rubydoc.info](http://rubydoc.info/gems/rumonade/frames)

## A [Ruby](http://www.ruby-lang.org) [Monad](http://en.wikipedia.org/wiki/Monad_\(functional_programming\)) Library, Inspired by [Scala](http://www.scala-lang.org)

Are you working in both the [Scala](http://www.scala-lang.org) and [Ruby](http://www.ruby-lang.org) worlds,
and finding that you miss some of the practical benefits of Scala's
[monads](http://james-iry.blogspot.com/2007/09/monads-are-elephants-part-1.html) in Ruby?
If so, then Rumonade is for you.

The goal of this library is to make the most common and useful Scala monadic idioms available in Ruby via the following classes:
* [Option](http://rubydoc.info/gems/rumonade/Rumonade/Option)
* [Array](http://rubydoc.info/gems/rumonade/Rumonade/ArrayExtensions)
* [Either](http://rubydoc.info/gems/rumonade/Rumonade/Either)
* [Hash](http://rubydoc.info/gems/rumonade/Rumonade/Hash)
* _more coming soon_

Syntactic support for scala-like [for-comprehensions](http://www.scala-lang.org/node/111) will be implemented
as a sequence of calls to `flat_map`, `select`, etc, modeling [Scala's
approach](http://stackoverflow.com/questions/3754089/scala-for-comprehension/3754568#3754568).

Support for an [all_catch](http://www.scala-lang.org/archives/downloads/distrib/files/nightly/docs/library/scala/util/control/Exception$.html)
idiom will be implemented to turn blocks which might throw exceptions into Option or Either
results. If this proves useful (and a good fit for Ruby), then more narrow functional catchers can be implemented as well.

## Usage Examples

### Option: handle _possibly_ _nil_ values in a _functional_ fashion:

```ruby
def format_date_in_march(time_or_date_or_nil)
  Option(time_or_date_or_nil).    # wraps possibly-nil value in an Option monad (Some or None)
    map(&:to_date).               # transforms a contained Time value into a Date value
    select {|d| d.month == 3}.    # filters out non-matching Date values (Some becomes None)
    map(&:to_s).                  # transforms a contained Date value into a String value
    map {|s| s.gsub('-', '')}.    # transforms a contained String value by removing '-'
    get_or_else("not in march!")  # returns the contained value, or the alternative if None
end

format_date_in_march(nil)                            # => "not in march!"
format_date_in_march(Time.parse('2009-01-01 01:02')) # => "not in march!"
format_date_in_march(Time.parse('2011-03-21 12:34')) # => "20110321"
```

Note:
* each step of the chained computations above are functionally isolated
* the value can notionally _start_ as nil, or _become_ nil during a computation, without effecting any other chained computations

---
### Either: handle failures (Left) and successes (Right) in a _functional_ fashion:

```ruby
def find_person(name)
  case name
    when /Jack/i, /John/i
      Right(name.capitalize)
    else
      Left("No such person: #{name.capitalize}")
  end
end

# success looks like this:
find_person("Jack")
# => Right("Jack")

# failure looks like this:
find_person("Jill")
# => Left("No such person: Jill")

# lift the contained values into Array, in order to combine them:
find_person("Joan").lift_to_a
# => Left(["No such person: Joan"])

# on the 'happy path', combine and transform successes into a single success result:
(find_person("Jack").lift_to_a + 
 find_person("John").lift_to_a).right.map { |*names| names.join(" and ") }
# => Right("Jack and John")

# but if there were errors, we still have a Left with all the errors inside:
(find_person("Jack").lift_to_a +
 find_person("John").lift_to_a +
 find_person("Jill").lift_to_a +
 find_person("Joan").lift_to_a).right.map { |*names| names.join(" and ") }
# => Left(["No such person: Jill", "No such person: Joan"])

# equivalent to the previous example, but shorter:
%w(Jack John Jill Joan).
  map { |nm| find_person(nm).lift_to_a }.inject(:+).
  right.map { |*names| names.join(" and ") }
# => Left(["No such person: Jill", "No such person: Joan"])
```

Also, see the `Either` class in action in the [Ruby version](https://gist.github.com/2553490) 
of [A Tale of Three Nightclubs](http://bugsquash.blogspot.com/2012/03/example-of-applicative-validation-in.html)
validation example in F#, and compare it to the [Scala version using scalaz](https://gist.github.com/970717).

---
### Hash: `flat_map` returns a Hash for each key/value pair; `get` returns an Option

```ruby
h = { "Foo" => 1, "Bar" => 2, "Baz" => 3 }

h = h.flat_map { |k, v| { k => v, k.upcase => v * 10 } }
# => {"Foo"=>1, "FOO"=>10, "Bar"=>2, "BAR"=>20, "Baz"=>3, "BAZ"=>30}

h = h.select { |k, v| k =~ /^b/i }
# => {"Bar"=>2, "BAR"=>20, "Baz"=>3, "BAZ"=>30}

h.get("Bar")
# => Some(2)

h.get("Foo")
# => None
```

## Approach

There have been [many](http://moonbase.rydia.net/mental/writings/programming/monads-in-ruby/00introduction.html)
[posts](http://pretheory.wordpress.com/2008/02/14/the-maybe-monad-in-ruby/)
[and](http://www.valuedlessons.com/2008/01/monads-in-ruby-with-nice-syntax.html)
[discussions](http://stackoverflow.com/questions/2709361/monad-equivalent-in-ruby)
about monads in Ruby, which have sparked a number of approaches.

Rumonade wants to be a practical drop-in Monad solution that will fit well into the Ruby world.

The priorities for Rumonade are:

1.  Practical usability in day-to-day Ruby
    *  <b>don't</b> mess up normal idioms of the language (e.g., `Hash#map`)
    *  <b>don't</b> slow down normal idioms of the language (e.g., `Array#map`)
2.  Rubyish-ness of usage
    *  Monad is a mix-in, requiring methods `self.unit` and `#bind` be implemented by target class
    *  Prefer blocks to lambda/Procs where possible, but allow both
3.  Equivalent idioms to Scala where possible

## Status

Option, Either, Array, and Hash are already usable.

<b><em>Supported Ruby versions</em></b>: MRI 1.9.2, MRI 1.9.3, JRuby in 1.9 mode, and Rubinius in 1.9 mode.

Please try it out, and let me know what you think! Suggestions are always welcome.
