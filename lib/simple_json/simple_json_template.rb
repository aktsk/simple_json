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

    private

    def code
      @code ||= lambda_stringify(@source)
    end

    def lambda_stringify(source)
      return source if source.match?(/^(?:\s*(?:#.*?)?\n)*\s*->/)

      "-> { #{source} }"
    end

    def method_string_from_lambda(source, method_name)
      pattern = %r{
        \A(?<prefix>(?:\s*\#.*\n|\s+)*)
        ->\s*
        (?:\((?<params_p>.*?)\)|(?<params_n>[^\{ ]*?))
        \s*(?:\{(?<body>.*)\}|do(?<body>.*)end)
        (?<suffix>(?:\s*\#.*|\s+)*)\z
      }mx

      match = source.match(pattern)
      raise :parse_error unless match

      params = (match[:params_p] || match[:params_n] || "").strip
      arg_part = params.empty? ? "" : "(#{params})"

      "#{match[:prefix]}def #{method_name}#{arg_part};#{match[:body]};end#{match[:suffix]}"
    end

    def to_method_string(method_name)
      method_string_from_lambda(code, method_name)
    end
  end
end
