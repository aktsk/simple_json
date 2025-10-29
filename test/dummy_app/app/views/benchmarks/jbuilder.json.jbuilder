# frozen_string_literal: true

lengths = @comments.map { |comment| comment.body.length }
avg_length = lengths.empty? ? 0.0 : (lengths.sum.to_f / lengths.size).round(2)

json.meta do
  json.total_comments @comments.size
  json.longest_comment_length lengths.max || 0
  json.average_comment_length avg_length
  json.tags %w[bench simple json]
  json.flags do
    json.has_many @comments.size > 500
    json.empty @comments.empty?
  end
end

json.comments do
  json.partial! 'comment_jbuilder', collection: @comments, as: 'comment'
end
