# frozen_string_literal: true

module AutoPreload
  # Extensions to ActiveRecord::Base
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      # @param [String, Array<String>] inclusions
      # @param [Hash] options
      # @return [ActiveRecord::Relation]
      scope :auto_includes, lambda { |inclusions, options = {}|
        if inclusions.present?
          resolved = Resolver.new(options).resolve(self, inclusions)
          resolved.empty? ? self : includes(*resolved)
        else
          self
        end
      }
      # @param [String, Array<String>] inclusions
      # @param [Hash] options
      # @return [ActiveRecord::Relation]
      scope :auto_preload, lambda { |inclusions, options = {}|
        if inclusions.present?
          resolved = Resolver.new(options).resolve(self, inclusions)
          resolved.empty? ? self : preload(*resolved)
        else
          self
        end
      }
      # @param [String, Array<String>] inclusions
      # @param [Hash] options
      # @return [ActiveRecord::Relation]
      scope :auto_eager_load, lambda { |inclusions, options = {}|
        if inclusions.present?
          resolved = Resolver.new(options).resolve(self, inclusions)
          resolved.empty? ? self : eager_load(*resolved)
        else
          self
        end
      }

      # @return [nil, Array<Symbol>]
      class_attribute :auto_preloadable
    end
  end
end
