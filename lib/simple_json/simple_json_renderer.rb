# frozen_string_literal: true

module SimpleJson
  class SimpleJsonRenderer
    class TemplateNotFound < RuntimeError; end

    attr_reader :controller

    @templates_loaded = false

    class << self
      def templates_loaded?
        @templates_loaded
      end

      def load_all_templates!
        @renderers = {}

        SimpleJson.template_paths.each do |path|
          template_files = Rails.root.glob("#{path}/**/*.simple_json.rb")
          template_files.each do |file_path|
            template_path = file_path.relative_path_from(Rails.root.join(path)).to_path.delete_suffix('.simple_json.rb')
            define_template_method(template_path, file_path.to_path)
          end
        end
        @templates_loaded = true
      end

      def load_template(template_path)
        if SimpleJson.template_cache_enabled?
          load_all_templates! unless templates_loaded?
          render_methods[template_path]
        else
          load_template_from_file(template_path)
        end
      end

      def load_template_from_file(template_path)
        SimpleJson.template_paths.each do |path|
          file_path = Rails.root.join("#{path}/#{template_path}.simple_json.rb").to_path

          return define_template_method(template_path, file_path) if File.exist?(file_path)
        end

        nil
      end

      def define_template_method(template_path, file_path)
        template = SimpleJsonTemplate.new(file_path)
        code_hash = template.code.hash

        render_methods[template_path] = render_methods_cache.fetch(code_hash) do
          @template_num ||= 0
          @template_num += 1
          method_name = :"template_#{@template_num}"
          template.define_to_class(self, method_name)
          render_methods_cache[code_hash] = method_name
        end
      end

      def render_methods
        @render_methods ||= {}
      end

      def render_methods_cache
        @render_methods_cache ||= {}
      end

      def clear_renderers
        @render_methods = {}
        @templates_loaded = false
      end
    end

    def initialize(controller)
      @controller = controller
      @_assigns = controller.view_assigns.each { |key, value| instance_variable_set("@#{key}", value) }
    end

    def renderer(template_path)
      renderers[template_path] || self.class.load_template(template_path).tap do |renderer|
        renderers[template_path] = renderer
      end
    end

    def renderers
      @renderers ||= {}
    end

    def render(template_name, **params)
      method_name = renderer(template_name)
      if !params.empty?
        send(method_name, **params)
      else
        send(method_name)
      end
    end

    def partial!(template_name, **params)
      raise TemplateNotFound, "#{template_name} not found" unless renderer(template_name)

      render(template_name, **params)
    end

    def cache!(key, **options, &block)
      if controller.perform_caching
        key = Array.wrap(key).unshift(SimpleJson.cache_key_prefix)
        Rails.cache.fetch(key, options, &block)
      else
        yield
      end
    end

    def cache_if!(condition, *args, **options, &block)
      condition ? cache!(*args, **options, &block) : yield
    end

    if ENV['NEWRELIC_MONITOR_MODE'] == 'true' && defined?(::NewRelic::Agent)
      include ::NewRelic::Agent::MethodTracer

      def render_with_tracing(template_name, params)
        self.class.trace_execution_scoped("View/#{template_name}.simple_json.rb/Rendering") do
          render_without_tracing(template_name, params)
        end
      end

      alias render_without_tracing render
      alias render render_with_tracing
    end
  end
end
