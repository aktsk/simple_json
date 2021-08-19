# frozen_string_literal: true

module SimpleJson
  class SimpleJsonTemplate
    def initialize(path)
      @path = path
      @source = File.read(path)
    end

    def renderer
      @renderer ||= eval(code, TOPLEVEL_BINDING, @path) # rubocop:disable Security/Eval
    end

    def code
      @code ||= lambda_stringify(@source)
    end

    private

    def lambda_stringify(source)
      return source if source.match?(/^(?:\s*(?:#.*?)?\n)*\s*->/)

      "-> { #{source} }"
    end
  end
end
