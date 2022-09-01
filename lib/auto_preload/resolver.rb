# frozen_string_literal: true

module AutoPreload
  # This class parses a string in the format "articles,comments" and returns an array of symbols.
  class Resolver
    MAX_ITERATIONS = 100

    def initialize(options = {})
      @iterations = 0
      @options = options
      @max_iterations = options[:max_iterations] || MAX_ITERATIONS
      @adapter = AutoPreload.config.adapter
    end

    # Resolves a string as an array of symbols or hashes.
    #
    # @param query [ActiveRecord::Base, ActiveRecord::Relation]
    # @param inclusions [String, Array<String>]
    # @return [Array<Symbol, Hash>]
    def resolve(query, inclusions)
      model = query.respond_to?(:klass) ? query.klass : query

      format_output(run_resolve(model, inclusions, root: true))
    end

    protected

    # @param model [ActiveRecord::Base]
    # @param inclusions [String, Array<String>]
    # @return [Array<Symbol, Hash>]
    def run_resolve(model, inclusions, root: false)
      inclusions = inclusions.split(",") if inclusions.is_a? String
      inclusions.flat_map { |item| parse_association(model, item, root: root) }
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
    # @param item [String, Symbol]
    # @return [Symbol, Hash, Array<Hash>]
    def parse_association(model, item, root: false)
      if item == "*"
        resolve_preloadables(model, root: root).map(&:name)
      elsif item == "**"
        recurse_associations(model, root: root)
      elsif item.include?(".")
        split_inclusions(model, item, root: root)
      else
        item = item.strip.underscore.to_sym
        find_association(model, item, root: root) ? item : nil
      end
    end

    # @param model [ActiveRecord::Base]
    # @return [Array<Hash>]
    def recurse_associations(model, root: false)
      increase_iterations_count!

      associations = resolve_preloadables(model, root: root)

      associations.map do |association|
        resolved = resolve(association.klass, "**")
        resolved.present? ? { association.name.to_sym => resolved } : association.name.to_sym
      end
    end

    # @param model [ActiveRecord::Base]
    # @param inclusions [String]
    # @return [Array<Hash>]
    def split_inclusions(model, inclusions, root: false)
      increase_iterations_count!

      head, *tail = inclusions.split(".", 2)
      head = head.strip.underscore.to_sym
      child_model = find_association(model, head, root: root).klass
      [{ head => resolve(child_model, tail[0]) }]
    end

    # @param model [ActiveRecord::Base]
    # @return [Array<ActiveRecord::Reflection::AssociationReflection>]
    def resolve_preloadables(model, root: false)
      @adapter.resolve_preloadables(model, @options, root: root)
    end

    # @param model [ActiveRecord::Base]
    # @param name [Symbol]
    # @return [nil, ActiveRecord::Reflection::AssociationReflection]
    def find_association(model, name, root: false)
      resolve_preloadables(model, root: root).find { |association| association.name == name.to_sym }
    end

    # @raise [RuntimeError]
    def increase_iterations_count!
      @iterations += 1
      raise "Too many iterations reached" if @iterations > @max_iterations
    end
  end
end
