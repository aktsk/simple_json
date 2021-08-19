# frozen_string_literal: true

json.title @post.title
json.user json.partial!('users/user', user: @post.user)
json.comments @post.comments do |comment|
  json.partial!('comments/comment', comment: comment)
end
