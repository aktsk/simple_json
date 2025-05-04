# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require File.expand_path('../test/dummy_app/config/environment.rb', __dir__)

Bundler.require
require 'action_args'
require 'debug'
require 'test/unit/rails/test_help'
