# frozen_string_literal: true

{
  title: @post.title,
  user: partial!('users/_user', user: @post.user),
  comments: @post.comments.map do |comment|
              partial!('simple_json_migration/posts_without_partial/_comment', comment: comment)
            end
}
