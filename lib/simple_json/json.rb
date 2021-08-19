# frozen_string_literal: true

require 'oj'

module SimpleJson
  module Json
    class Oj
      def self.encode(json)
        ::Oj.dump(json, mode: :rails)
      end

      def self.decode(json_string)
        ::Oj.load(json_string, mode: :rails)
      end
    end
  end
end
