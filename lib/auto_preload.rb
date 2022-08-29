# frozen_string_literal: true

require "active_support"
require "active_record"

module AutoPreload
  extend ActiveSupport::Autoload

  autoload :ActiveRecord
  autoload :Resolver
end

ActiveRecord::Base.include AutoPreload::ActiveRecord
