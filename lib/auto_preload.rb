# frozen_string_literal: true

require "active_support"
require "active_record"

# Provides methods to run `preload`/`includes`/`eager_load` on your model
# from a JSON::API include string.
module AutoPreload
  extend ActiveSupport::Autoload

  autoload :ActiveRecord
  autoload :Adapters
  autoload :Resolver
  autoload :Config

  # @yield [AutoPreload::Config]
  # @return [AutoPreload::Config]
  def self.configure
    yield(config)
  end

  # @return [AutoPreload::Config]
  def self.config
    @config ||= Config.new
  end
end

# rubocop:disable Lint/SendWithMixinArgument
ActiveRecord::Base.send(:include, AutoPreload::ActiveRecord)
# rubocop:enable Lint/SendWithMixinArgument
