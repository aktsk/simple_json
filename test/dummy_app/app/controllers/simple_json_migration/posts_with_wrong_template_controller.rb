# frozen_string_literal: true

module SimpleJsonMigration
  class PostsWithWrongTemplateController < ApplicationController
    include SimpleJson::Migratable

    def show(id)
      @post = Post.find id
    end
  end
end
