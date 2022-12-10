# frozen_string_literal: true

module AutoPreload
  # This module contains the adapters used to parse JSON::API include strings.
  module Adapters
    extend ActiveSupport::Autoload

    autoload :ActiveRecord
    autoload :Serializer
  end
end
