# frozen_string_literal: true

require "active_support"
require "active_record"

module AutoPreload
  extend ActiveSupport::Autoload

  autoload :ActiveRecord
  autoload :Adapters
  autoload :Resolver
  autoload :Config

  def self.configure
    yield(config)
  end

  def self.config
    @config ||= Config.new
  end
end

ActiveRecord::Base.include AutoPreload::ActiveRecord
