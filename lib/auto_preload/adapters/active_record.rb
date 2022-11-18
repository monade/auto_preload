# frozen_string_literal: true

module AutoPreload
  module Adapters
    # This class takes a model and finds all the preloadable associations.
    class ActiveRecord
      def resolve_preloadables(model, _options = {})
        if model.auto_preloadable
          model.auto_preloadable.map { |w| model.reflect_on_association(w) }.compact
        else
          model.reflect_on_all_associations
        end
      end
    end
  end
end
