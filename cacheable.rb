require 'set'
module Cacheable

  def memoize(method_name, *additional_method_names)
    method_names = Array(method_name).concat(additional_method_names).flatten
    raise "use symbols or strings to call method" unless method_names.all? { |a| a.respond_to?(:to_sym) } #=> check cases as memoize :code_pools, 2, :me

    no_method_defined = method_names.uniq.reject { |a| method_defined?(a) }
    raise "#{no_method_defined.inspect}'s not defined" unless no_method_defined.empty?

    method_names.uniq.each do |method_name|
      memoized_method_name = "memoized_#{method_name}"
      
			unless method_defined?(memoized_method_name)
        alias_method memoized_method_name, method_name

        define_method method_name do |*arguments, &block|
          @memoize_on_arguments ||= Hash.new { |h, k| h[k] = {} }
          return @memoize_on_arguments[method_name][arguments] if @memoize_on_arguments[method_name].include?(arguments)

          old_method = self.class.instance_method(memoized_method_name)
          memoized_value = old_method.bind(self).call(*arguments, &block)

          @memoize_on_arguments[method_name][arguments] = memoized_value
        end
				
      end
    end
  end
end
