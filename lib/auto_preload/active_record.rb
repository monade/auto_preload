# frozen_string_literal: true

module AutoPreload
  module ActiveRecord
    extend ActiveSupport::Concern

    included do
      scope :auto_includes, lambda { |inclusions|
        if inclusions.present?
          includes(*Resolver.new.resolve(self, inclusions))
        else
          self
        end
      }
      scope :auto_preload, lambda { |inclusions|
        if inclusions.present?
          preload(*Resolver.new.resolve(self, inclusions))
        else
          self
        end
      }
      scope :auto_eager_load, lambda { |inclusions|
        if inclusions.present?
          eager_load(*Resolver.new.resolve(self, inclusions))
        else
          self
        end
      }

      class_attribute :auto_preloadable
    end
  end
end
