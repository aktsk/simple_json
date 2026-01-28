# frozen_string_literal: true

length = comment.body.length
likes = comment.id * 3
dislikes = comment.id % 4
rating = (likes.to_f / (dislikes.zero? ? 1 : dislikes)).round(2)
position = comment_counter + 1

json.id comment.id
json.body comment.body

json.metrics do
  json.length length
  json.readability (length / 5.0).round(2)
  json.engagement do
    json.likes likes
    json.dislikes dislikes
    json.rating rating
  end
end

json.author do
  json.name "user-#{comment.id}"
  json.active comment.id.odd?
  json.badges ((comment.id % 3).zero? ? %w[insightful] : [])
  json.contact do
    json.email "user#{comment.id}@example.com"
    json.url "https://example.com/users/#{comment.id}"
  end
  json.settings do
    json.theme(comment.id.even? ? 'dark' : 'light')
    json.timezone "UTC+#{(comment.id % 5) - 2}"
  end
end

json.tags ['bench', "comment-#{comment.id}", (comment.id.even? ? 'even' : nil)].compact

json.flags do
  json.pinned position == 1
  json.hidden (comment.id % 5).zero?
end

json.metadata do
  json.position position
  attachments = (comment.id % 4).zero? ? [{ filename: "attachment-#{comment.id}.txt", size: comment.id * 128 }] : []
  json.attachments attachments
  json.history [
    { version: 1, updated_by: "user-#{comment.id}", updated_at: '2024-01-01T00:00:00Z' },
    { version: 2, updated_by: "user-#{comment.id}", updated_at: '2024-01-02T00:00:00Z' }
  ]
end

json.links do
  json.self "/comments/#{comment.id}"
  json.post "/posts/#{comment.post&.id || 1}"
end

json.extras do
  json.mood %w[happy neutral excited][comment.id % 3]
  json.score comment.id * position
end
