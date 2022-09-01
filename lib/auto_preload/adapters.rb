# frozen_string_literal: true

module AutoPreload
  module Adapters
    extend ActiveSupport::Autoload

    autoload :ActiveRecord
    autoload :Serializer
  end
end
