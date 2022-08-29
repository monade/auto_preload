# frozen_string_literal: true

module AutoPreload
  # This class parses a string in the format "articles,comments" and returns an array of symbols.
  class Resolver
    MAX_ITERATIONS = 100

    def initialize
      @iterations = 0
    end

    # Resolves a string as an array of symbols or hashes.
    #
    # @param query [ActiveRecord::Base, ActiveRecord::Relation]
    # @param inclusions [String, Array<String>]
    # @return [Array<Symbol, Hash>]
    def resolve(query, inclusions)
      model = query.respond_to?(:klass) ? query.klass : query

      format_output(run_resolve(model, inclusions))
    end

    private

    # @param model [ActiveRecord::Base]
    # @param inclusions [String, Array<String>]
    # @return [Array<Symbol, Hash>]
    def run_resolve(model, inclusions)
      inclusions = inclusions.split(",") if inclusions.is_a? String
      inclusions.flat_map { |item| parse_association(model, item) }
    end

    # @param list [Array<Symbol, Hash>]
    # @return [Array<Symbol, Hash>]
    def format_output(list)
      list = list.compact.uniq # .sort { |a, _b| a.is_a?(Hash) ? 1 : -1 }
      symbols = list.select { |item| item.is_a? Symbol }
      objects = merge(list.select { |item| item.is_a? Hash })

      objects.present? ? (symbols << objects) : symbols
    end

    # @param list [Array<Hash>]
    # @return [Hash]
    def merge(objects)
      objects.reduce({}) do |result, object|
        result.merge(object) do |_, old_value, new_value|
          (old_value + new_value).uniq
        end
      end
    end

    # @param model [ActiveRecord::Base]
    # @param item [String]
    # @return [Symbol, Hash, Array<Hash>]
    def parse_association(model, item)
      if item == "*"
        model.auto_preloadable || model.reflect_on_all_associations.map(&:name)
      elsif item == "**"
        recurse_associations(model)
      elsif item.include?(".")
        split_inclusions(model, item)
      else
        item = item.strip.underscore.to_sym
        find_association(model, item) ? item : nil
      end
    end

    # @param model [ActiveRecord::Base]
    # @return [Array<Hash>]
    def recurse_associations(model)
      @iterations += 1
      raise "Too many iterations reached" if @iterations > MAX_ITERATIONS

      associations = resolve_preloadable(model)

      associations.map do |association|
        resolved = resolve(association.klass, "**")
        resolved.present? ? { association.name.to_sym => resolved } : association.name.to_sym
      end
    end

    def resolve_preloadable(model)
      if model.auto_preloadable
        model.auto_preloadable.map { |w| model.reflect_on_association(w) }
      else
        model.reflect_on_all_associations
      end
    end

    # @param model [ActiveRecord::Base]
    # @param inclusions [String]
    # @return [Array<Hash>]
    def split_inclusions(model, inclusions)
      @iterations += 1
      raise "Too many iterations reached" if @iterations > MAX_ITERATIONS

      head, *tail = inclusions.split(".", 2)
      head = head.strip.underscore.to_sym
      child_model = find_association(model, head).klass
      [{ head => resolve(child_model, tail[0]) }]
    end

    # @param model [ActiveRecord::Base]
    # @param name [Symbol]
    # @return [nil, ActiveRecord::Reflection::AssociationReflection]
    def find_association(model, name)
      model.reflect_on_all_associations.find { |association| association.name.to_sym == name }
    end
  end
end
