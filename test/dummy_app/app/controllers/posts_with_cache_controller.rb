# frozen_string_literal: true

class PostsWithCacheController < ApplicationController
  self.perform_caching = true

  def show(id)
    @post = Post.find id
  end
end
