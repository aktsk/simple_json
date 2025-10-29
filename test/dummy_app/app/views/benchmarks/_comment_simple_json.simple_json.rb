# frozen_string_literal: true

->(comment:, position:) {
  length = comment.body.length
  likes = comment.id * 3
  dislikes = comment.id % 4
  rating = (likes.to_f / (dislikes.zero? ? 1 : dislikes)).round(2)

  {
    id: comment.id,
    body: comment.body,
    metrics: {
      length: length,
      readability: (length / 5.0).round(2),
      engagement: {
        likes: likes,
        dislikes: dislikes,
        rating: rating
      }
    },
    author: {
      name: "user-#{comment.id}",
      active: comment.id.odd?,
      badges: (comment.id % 3).zero? ? %w[insightful] : [],
      contact: {
        email: "user#{comment.id}@example.com",
        url: "https://example.com/users/#{comment.id}"
      },
      settings: {
        theme: comment.id.even? ? 'dark' : 'light',
        timezone: "UTC+#{(comment.id % 5) - 2}"
      }
    },
    tags: ['bench', "comment-#{comment.id}", (comment.id.even? ? 'even' : nil)].compact,
    flags: {
      pinned: position == 1,
      hidden: (comment.id % 5).zero?
    },
    metadata: {
      position: position,
      attachments: (comment.id % 4).zero? ? [{ filename: "attachment-#{comment.id}.txt", size: comment.id * 128 }] : [],
      history: [
        { version: 1, updated_by: "user-#{comment.id}", updated_at: '2024-01-01T00:00:00Z' },
        { version: 2, updated_by: "user-#{comment.id}", updated_at: '2024-01-02T00:00:00Z' }
      ]
    },
    links: {
      self: "/comments/#{comment.id}",
      post: "/posts/#{comment.post&.id || 1}"
    },
    extras: {
      mood: %w[happy neutral excited][comment.id % 3],
      score: comment.id * position
    }
  }
}
