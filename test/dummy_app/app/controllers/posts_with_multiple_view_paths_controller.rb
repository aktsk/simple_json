# frozen_string_literal: true

class PostsWithMultipleViewPathsController < ApplicationController
  def show(id)
    @post = Post.find id
  end
end
