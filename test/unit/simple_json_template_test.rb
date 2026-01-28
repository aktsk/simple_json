# frozen_string_literal: true

require 'test_helper'

class SimpleJsonTemplateTest < Test::Unit::TestCase
  # -> { body } form
  test 'converts simple lambda with braces' do
    source = '-> { "hello" }'
    result = call_method(source, :foo)

    assert_equal 'def foo; "hello" ;end', result
  end

  # ->(params) { body } form (parenthesized parameters)
  test 'converts lambda with parenthesized parameters' do
    source = '->(a, b) { a + b }'
    result = call_method(source, :add)

    assert_equal 'def add(a, b); a + b ;end', result
  end

  # ->params { body } form (no parentheses, no space)
  test 'converts lambda with parameter without parentheses' do
    source = '->a { a * 2 }'
    result = call_method(source, :double)

    assert_equal 'def double(a); a * 2 ;end', result
  end

  # -> do body end form
  test 'converts lambda with do-end' do
    source = '-> do "hello" end'
    result = call_method(source, :foo)

    assert_equal 'def foo; "hello" ;end', result
  end

  # ->(params) do body end form
  test 'converts lambda with parameters and do-end' do
    source = '->(x) do x * 2 end'
    result = call_method(source, :double)

    assert_equal 'def double(x); x * 2 ;end', result
  end

  # Multiline body
  test 'converts multiline lambda body' do
    source = <<~RUBY
      -> {
        x = 1
        y = 2
        x + y
      }
    RUBY
    result = call_method(source, :calc)

    assert_match(/def calc;/, result)
    assert_match(/x = 1/, result)
    assert_match(/y = 2/, result)
    assert_match(/x \+ y/, result)
    assert_match(/;end/, result)
  end

  # Preserve prefix comments
  test 'preserves prefix comments' do
    source = <<~RUBY
      # This is a comment
      -> { "hello" }
    RUBY
    result = call_method(source, :foo)

    assert_match(/\A# This is a comment\n/, result)
    assert_match(/def foo;/, result)
  end

  # Preserve suffix comments
  test 'preserves suffix comments' do
    source = <<~RUBY
      -> { "hello" }
      # trailing comment
    RUBY
    result = call_method(source, :foo)

    assert_match(/;end\n# trailing comment/, result)
  end

  # Empty parameter list
  test 'converts lambda with empty parentheses' do
    source = '->() { "hello" }'
    result = call_method(source, :foo)

    assert_equal 'def foo; "hello" ;end', result
  end

  # Space before brace with no parameters
  test 'converts lambda with space before brace' do
    source = '->   { "hello" }'
    result = call_method(source, :foo)

    assert_equal 'def foo; "hello" ;end', result
  end

  # Multiline do-end form
  test 'converts multiline do-end lambda' do
    source = <<~RUBY
      -> do
        result = []
        result << 1
        result
      end
    RUBY
    result = call_method(source, :build)

    assert_match(/def build;/, result)
    assert_match(/result = \[\]/, result)
    assert_match(/;end/, result)
  end

  # --- Parameter types ---

  # Default argument
  test 'converts lambda with default parameter' do
    source = '->(a, b = 1) { a + b }'
    result = call_method(source, :add)

    assert_equal 'def add(a, b = 1); a + b ;end', result
  end

  # Keyword arguments
  test 'converts lambda with keyword parameters' do
    source = '->(a:, b: 1) { a + b }'
    result = call_method(source, :add)

    assert_equal 'def add(a:, b: 1); a + b ;end', result
  end

  # Variadic arguments
  test 'converts lambda with splat parameter' do
    source = '->(*args) { args }'
    result = call_method(source, :collect)

    assert_equal 'def collect(*args); args ;end', result
  end

  # Block parameter
  test 'converts lambda with block parameter' do
    source = '->(&block) { block.call }'
    result = call_method(source, :execute)

    assert_equal 'def execute(&block); block.call ;end', result
  end

  # Double splat
  test 'converts lambda with double splat parameter' do
    source = '->(**opts) { opts }'
    result = call_method(source, :options)

    assert_equal 'def options(**opts); opts ;end', result
  end

  # --- Body edge cases ---

  # Nested braces
  test 'converts lambda with nested braces in body' do
    source = '-> { { key: value } }'
    result = call_method(source, :hash)

    assert_equal 'def hash; { key: value } ;end', result
  end

  # Empty body (braces)
  test 'converts lambda with empty body' do
    source = '-> { }'
    result = call_method(source, :noop)

    assert_equal 'def noop; ;end', result
  end

  # Empty body (do-end)
  test 'converts do-end lambda with empty body' do
    source = '-> do end'
    result = call_method(source, :noop)

    assert_equal 'def noop; ;end', result
  end

  # do-end body contains end keyword
  test 'converts do-end lambda with nested end keyword' do
    source = '-> do if x then y end end'
    result = call_method(source, :conditional)

    assert_equal 'def conditional; if x then y end ;end', result
  end

  # Body string contains end
  test 'converts lambda with end string in body' do
    source = '-> { "end of string" }'
    result = call_method(source, :message)

    assert_equal 'def message; "end of string" ;end', result
  end

  # --- Prefix edge cases ---

  # Multiple prefix comments
  test 'preserves multiple prefix comments' do
    source = <<~RUBY
      # comment 1
      # comment 2
      -> { 1 }
    RUBY
    result = call_method(source, :foo)

    assert_match(/\A# comment 1\n# comment 2\n/, result)
    assert_match(/def foo;/, result)
  end

  # Blank line prefix
  test 'preserves blank line prefix' do
    source = "\n\n-> { 1 }"
    result = call_method(source, :foo)

    assert_match(/\A\n\ndef foo;/, result)
  end

  # --- Error cases ---

  # Non-lambda input
  test 'raises error for non-lambda input' do
    source = 'def foo; end'

    assert_raise(TypeError) do
      call_method(source, :foo)
    end
  end

  # Proc.new input
  test 'raises error for Proc.new input' do
    source = 'Proc.new { 1 }'

    assert_raise(TypeError) do
      call_method(source, :foo)
    end
  end

  private

  def call_method(source, method_name)
    SimpleJson::SimpleJsonTemplate.allocate.send(:method_string_from_lambda, source, method_name)
  end
end
