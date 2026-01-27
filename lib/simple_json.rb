# frozen_string_literal: true

require 'simple_json/version'

require 'simple_json/simple_json_renderable'
require 'simple_json/simple_json_renderer'
require 'simple_json/simple_json_template'

require 'simple_json/migratable'
require 'simple_json/simple_json_renderer_for_migration'

module SimpleJson
  @config = {
    template_cache_enabled: false,
    template_paths: ['app/views'],
    cache_key_prefix: 'simple_json/views',
    default_json_module: ActiveSupport::JSON
  }

  class << self
    attr_accessor :config

    def enable_template_cache
      config[:template_cache_enabled] = true
    end

    def disable_template_cache
      config[:template_cache_enabled] = false
      SimpleJsonRenderer.clear_renderers
    end

    def template_cache_enabled?
      config[:template_cache_enabled]
    end

    def template_paths
      config[:template_paths]
    end

    def template_paths=(template_paths)
      config[:template_paths] = template_paths
    end

    def cache_key_prefix
      config[:cache_key_prefix]
    end

    def cache_key_prefix=(cache_key_prefix)
      config[:cache_key_prefix] = cache_key_prefix
    end

    def json_module
      @json_module ||= config[:default_json_module]
    end

    attr_writer :json_module
  end
end
