#
# Helpers for named.conf and named.options templates
#

module Named
  module ConfHelpers
    def each_resource(type, names)
      names = names.call if names.respond_to? :call
      names.each do |name|
        r = node.run_context.resource_collection.find("#{type}[#{name}]")
        yield r
      end
    end

    def each_resource_with_property(type, names, prop, value)
      each_resource type, names do |r|
        if block_given?
          res_value = r.send(prop.to_sym)
          if res_value.is_a?(Array) && res_value.include?(value)
            yield r
          elsif res_value == value
            yield r
          end
        end
      end
    end
  end
end
