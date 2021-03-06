module JSONAPI
  class IncludeDirectives
    # Construct an IncludeDirectives Hash from an array of dot separated include strings.
    # For example ['posts.comments.tags']
    # will transform into =>
    # {
    #   posts:{
    #     include:true,
    #     include_related:{
    #       comments:{
    #         include:true,
    #         include_related:{
    #           tags:{
    #             include:true
    #           }
    #         }
    #       }
    #     }
    #   }
    # }

    def initialize(resource_klass, includes_array, force_eager_load: false)
      @resource_klass = resource_klass
      @force_eager_load = force_eager_load
      @include_directives_hash = { include_related: {} }
      includes_array.each do |include|
        parse_include(include)
      end
    end

    def include_directives
      @include_directives_hash
    end

    def model_includes
      get_includes(@include_directives_hash)
    end

    private

    def get_related(current_path)
      current = @include_directives_hash
      current_resource_klass = @resource_klass
      current_path.split('.').each do |fragment|
        fragment = fragment.to_sym

        if current_resource_klass
          current_relationship = current_resource_klass._relationships[fragment]
          current_resource_klass = current_relationship.try(:resource_klass)
        else
          warn "[RELATIONSHIP NOT FOUND] Relationship could not be found for #{current_path}."
        end

        include_in_join = @force_eager_load || !current_relationship || current_relationship.eager_load_on_include

        current[:include_related][fragment] ||= { include: false, include_related: {}, include_in_join: include_in_join }
        current = current[:include_related][fragment]
      end
      current
    end

    def get_includes(directive)
      directive[:include_related].select { |k,v| v[:include_in_join] }.map do |name, directive|
        sub = get_includes(directive)
        sub.any? ? { name => sub } : name
      end
    end

    def parse_include(include)
      parts = include.split('.')
      local_path = ''

      parts.each do |name|
        local_path += local_path.length > 0 ? ".#{name}" : name
        related = get_related(local_path)
        related[:include] = true
      end
    end
  end
end
