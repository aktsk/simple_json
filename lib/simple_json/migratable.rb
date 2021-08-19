# frozen_string_literal: true

module SimpleJson
  # The module for migration from jbuilder to simple json.
  # Using this will render view twice, and may cause http response headers change.
  #
  # DO NOT INCLUDE THIS IN PRODUCTION!
  #
  #   class XXXController < ActionController::Base
  #     include SimpleJson::SimpleJsonRenderable
  #     include SimpleJson::Migratable
  #
  #     ...
  #   end
  module Migratable
    class DifferentViewOutput < RuntimeError; end

    extend ActiveSupport::Concern

    def render_json_template(template_name, **options)
      fix_current_time do
        json = simple_renderer.render(template_name)
        result = SimpleJson.json_module.encode(json)
        result_super = render_to_body(options.merge({ skip_simple_json: true }))

        raise DifferentViewOutput if result != result_super

        result
      end
    end

    def simple_renderer
      @simple_renderer ||= SimpleJsonRendererForMigration.new(self).tap do |r|
        r.extend(_helpers) if respond_to?(:_helpers)
      end
    end

    private

    def fix_current_time
      return yield if Time.method_defined? :__current

      begin
        time = Time.current
        singleton_class = Time.singleton_class
        singleton_class.alias_method :__current, :current
        Time.define_singleton_method(:current) do
          time
        end
        yield
      ensure
        # alternative code for active support under 5.1 for
        # `singleton_class.silence_redefinition_of_method :current`
        singleton_class.alias_method :current, :current
        singleton_class.alias_method :current, :__current
        singleton_class.undef_method :__current
      end
    end
  end
end
