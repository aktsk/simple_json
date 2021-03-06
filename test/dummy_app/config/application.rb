# frozen_string_literal: true

require_relative 'boot'

require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'rails/test_unit/railtie'

Bundler.require(*Rails.groups)
require 'simple_json'

module Dummy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.hosts.clear if Rails::VERSION::MAJOR >= 6
  end
end
