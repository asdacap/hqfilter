
module Hqfilter
  # This module helps with the convention involved
  module ResourceControllerHelper
    extend ActiveSupport::Concern

    included do
      helper_method :singular_resource_name, :resource_class, :resource_instance, :resource_params, :resource_collection_instance
    end

    def singular_resource_name
      controller_path.singularize
    end

    def resource_class
      Kernel.const_get(singular_resource_name.classify)
    end

    def resource_instance
      instance_variable_get("@#{singular_resource_name}")
    end

    def resource_instance= val
      instance_variable_set("@#{singular_resource_name}",val)
    end

    def resource_collection_instance
      instance_variable_get("@#{controller_name}")
    end

    def resource_params
      send :"#{singular_resource_name}_params"
    end
  end
end
