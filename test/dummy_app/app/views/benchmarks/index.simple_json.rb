# frozen_string_literal: true

{
  comments: @comments.map { |comment| partial!('benchmarks/_comment_simple_json', comment: comment) }
}
