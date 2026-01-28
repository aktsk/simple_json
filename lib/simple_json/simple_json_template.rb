# frozen_string_literal: true

module SimpleJson
  class SimpleJsonTemplate
    def initialize(path)
      @path = path
      @source = File.read(path)
    end

    def define_to_class(klass, method_name)
      method_string = to_method_string(method_name)
      klass.class_eval(method_string, @path)

      method_name
    end

    def code
      @code ||= lambda_stringify(@source)
    end

    private

    def lambda_stringify(source)
      return source if source.match?(/^(?:\s*(?:#.*?)?\n)*\s*->/)

      "-> { #{source} }"
    end

    def method_string_from_lambda(source, method_name)
      replaced = source.sub(/\A(?<prefix>(?:[ \t]*(?:#.*?)?\n)*)(?<indent>[ \t]*)->\s*(?<args>\([^)]*\))?[ \t]*\{?[ \t]*(?<rest>[^\n]*)/) do
        header = "#{Regexp.last_match(:prefix)}#{Regexp.last_match(:indent)}def #{method_name}#{Regexp.last_match(:args)}"
        rest = Regexp.last_match(:rest)
        rest.strip.empty? ? header : "#{header}; #{rest.lstrip}"
      end
      return unless replaced != source

      brace_index = replaced.rindex('}')
      return replaced unless brace_index

      replaced[brace_index] = 'end'
      replaced
    end

    def to_method_string(method_name)
      method_string_from_lambda(code, method_name)
    end
  end
end
