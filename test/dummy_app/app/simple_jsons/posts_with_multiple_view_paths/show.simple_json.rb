# frozen_string_literal: true

{
  title: @post.title,
  user: partial!('users/_user', user: @post.user),
  comments: @post.comments.map { |comment| partial!('posts_with_multiple_view_paths/_comment', comment: comment) }
}
