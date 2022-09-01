# frozen_string_literal: true

module AutoPreload
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      scope :auto_includes, lambda { |inclusions, options = {}|
        if inclusions.present?
          includes(*Resolver.new(options).resolve(self, inclusions))
        else
          self
        end
      }
      scope :auto_preload, lambda { |inclusions, options = {}|
        if inclusions.present?
          preload(*Resolver.new(options).resolve(self, inclusions))
        else
          self
        end
      }
      scope :auto_eager_load, lambda { |inclusions, options = {}|
        if inclusions.present?
          eager_load(*Resolver.new(options).resolve(self, inclusions))
        else
          self
        end
      }

      class_attribute :auto_preloadable
    end
  end
end
