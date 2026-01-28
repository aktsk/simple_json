# frozen_string_literal: true

lengths = @comments.map { |comment| comment.body.length }
avg_length = lengths.empty? ? 0.0 : (lengths.sum.to_f / lengths.size).round(2)

{
  meta: {
    total_comments: @comments.size,
    longest_comment_length: lengths.max || 0,
    average_comment_length: avg_length,
    tags: %w[bench simple json],
    flags: {
      has_many: @comments.size > 500,
      empty: @comments.empty?
    }
  },
  comments: @comments.each_with_index.map do |comment, index|
    partial!('benchmarks/_comment_simple_json', comment: comment, position: index + 1)
  end
}
