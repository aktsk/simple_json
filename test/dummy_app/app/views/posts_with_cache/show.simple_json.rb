# frozen_string_literal: true

cache!(['posts', @post.id]) do
  {
    title: @post.title,
    user: partial!('users/_user', user: @post.user),
    comments: @post.comments.map { |comment| partial!('comments/_comment', comment: comment) }
  }
end
