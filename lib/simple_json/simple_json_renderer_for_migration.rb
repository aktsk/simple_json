# frozen_string_literal: true

module SimpleJson
  class SimpleJsonRendererForMigration < SimpleJsonRenderer
    @templates_loaded = false

    def partial!(template_name, **params)
      if renderer(template_name)
        render(template_name, **params)
      else
        warn_template_not_exist(template_name)

        if @controller.respond_to?(:helpers)
          result = @controller.helpers.render(template_name.gsub('/_', '/'), params)
        else
          @controller_helper_proxy ||= @controller.view_context
          result = @controller_helper_proxy.render(template_name.gsub('/_', '/'), params)
        end

        if result.is_a?(String)
          SimpleJson.json_module.decode result
        else
          result
        end
      end
    end

    private

    def warn_template_not_exist(template_name)
      @template_not_exist_warning ||= {}
      return if @template_not_exist_warning[template_name]

      warn "simple_json template '#{template_name}' not exist!"
      @template_not_exist_warning[template_name] = true
    end
  end
end
