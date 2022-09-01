# frozen_string_literal: true

require "active_model_serializers"

module AutoPreload
  module Adapters
    # This class takes a model and finds all the preloadable associations.
    class Serializer
      def initialize
        @fallback = ActiveRecord.new
      end

      # @param model [ActiveRecord::Base] The model to find preloadable associations for.
      # @return [Array<ActiveRecord::Reflection>] The preloadable associations.
      def resolve_preloadables(model, options = {}, root: false)
        serializer = resolve_serializer(model, options, root: root)
        preloadables = @fallback.resolve_preloadables(model)
        return preloadables unless serializer

        preloadables_map = preloadables.index_by(&:name)

        serializer._reflections.map do |key, _|
          preloadables_map[key]
        end.compact
      end

      def resolve_serializer(model, options = {}, root: false)
        if root
          options[:serializer] || ActiveModel::Serializer.serializer_for(model)
        else
          ActiveModel::Serializer.serializer_for(model)
        end
      end
    end
  end
end
