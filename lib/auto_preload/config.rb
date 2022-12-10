# frozen_string_literal: true

module AutoPreload
  # This class handles the gem configurations.
  class Config
    # @return [AutoPreload::Adapters::ActiveRecord, AutoPreload::Adapters::Serializer] The adapter to use.
    attr_writer :adapter

    # @return [AutoPreload::Adapters::ActiveRecord, AutoPreload::Adapters::Serializer] The adapter to use.
    def adapter
      @adapter ||= AutoPreload::Adapters::ActiveRecord.new
    end
  end
end
