# frozen_string_literal: true

module SimpleJson
  # The module for overriding rendering with SimpleJson
  #
  #   class XXXController < ActionController::Base
  #     include SimpleJson::SimpleJsonRenderable
  #
  #     ...
  #   end
  module SimpleJsonRenderable
    extend ActiveSupport::Concern

    # monkey-patch for ActionController::ImplicitRender#default_render bypassing template search
    def default_render(*args)
      return super unless request.format.json?

      @simple_json_template = simple_renderer.renderer(template_name(action_name))
      if @simple_json_template
        render(*args)
      else
        super
      end
    end

    def render_to_body(options)
      return super unless request.format.json?
      return super if options[:skip_simple_json]
      # use super when any of [:body, :plain, :html] exist in options
      return super if self.class::RENDER_FORMATS_IN_PRIORITY.any? { |key| options.key? key }

      template_name = template_name(options[:template] || options[:action] || action_name)
      if options.key?(:json)
        process_options(options)
        @rendered_format = 'application/json; charset=utf-8'
        SimpleJson.json_module.encode(options[:json])
      elsif simple_renderer.renderer(template_name)
        process_options(options)
        @rendered_format = 'application/json; charset=utf-8'
        render_json_template(template_name, **options)
      else
        super
      end
    end

    def process_options(options)
      head options[:status] if options.key?(:status)
    end

    def rendered_format
      return @rendered_format if defined?(@rendered_format)

      super
    end

    def simple_renderer
      @simple_renderer ||= self.class.simple_json_renderer_class.new(self)
    end

    def render_json_template(template_name, **_options)
      json = simple_renderer.render(template_name)
      SimpleJson.json_module.encode(json)
    end

    included do
      if SimpleJson.template_cache_enabled? && !SimpleJsonRenderer.templates_loaded?
        SimpleJsonRenderer.load_all_templates!
      end

      def self.simple_json_renderer_class
        @simple_json_renderer_class ||= begin
          klass = Class.new(SimpleJsonRenderer)
          klass.include(_helpers) if method_defined?(:_helpers)
          klass
        end
      end
    end

    def template_path
      self.class.name.delete_suffix('Controller').underscore
    end

    def template_name(name)
      return name if name.include?('/')

      "#{template_path}/#{name}"
    end
  end
end
