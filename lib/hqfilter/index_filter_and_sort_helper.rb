require "hqfilter/resource_controller_helper.rb"

module Hqfilter
  # A module with various helpers that have some function that help with index filtering and sort.
  # This is here instead of the application helper so that it can be overriden by including class.
  module IndexFilterAndSortHelper
    extend ActiveSupport::Concern
    include ResourceControllerHelper

    included do
      helper_method :index_params, :sort_column, :sort_direction, :filter_params, :filter_available_for

      # These four function enable the subclass to implement custom logic for sorting of filtering.
      # Subclass need to call add_custom_filter_field or add_custom_sort_field with the custom field name
      # and a block. The block will be called with current scope and value and is expected to return a scope.
      #
      # example:
      #
      # add_custom_sort_field :submitter do |scope,direction|
      #     scope.reorder("users.name #{direction}")
      # end
      #
      def self.custom_filter_fields
        @custom_filter_fields ||= {}.with_indifferent_access
      end
      def self.add_custom_filter_field field, &block
        custom_filter_fields[field] = block
      end

      def self.custom_sort_fields
        @custom_sort_fields ||= {}.with_indifferent_access
      end
      def self.add_custom_sort_field field, &block
        custom_sort_fields[field] = block
      end

      # Declare thse field as boolean. So it accept '0' as false and '1' as true
      def self.boolean_filter_field *fields
        fields.each do |field|
          add_custom_filter_field field do |scope,value|
            if value == '0'
              scope.where(statement_of_undertaking_accepted: [false,nil])
            else
              scope.where(statement_of_undertaking_accepted: true)
            end
          end
        end
      end


      ################################# DATE TIME HELPER ####################################
      # Assume index filter and sort field is used and will generate necessary method
      # for the date field to be filtered correctly
      def self.date_filter_field field
      class_eval <<-RUBY
      add_custom_filter_field :#{field}_hour do |scope,hour|
        scope.#{field}_hour(hour)
      end
      add_custom_filter_field :#{field}_minute do |scope,minute|
        scope.#{field}_minute(minute)
      end
      add_custom_filter_field :#{field}_day do |scope,day|
        scope.#{field}_day(day)
      end
      add_custom_filter_field :#{field}_month do |scope,month|
        scope.#{field}_month(month)
      end
      add_custom_filter_field :#{field}_year do |scope,year|
        scope.#{field}_year(year)
      end
      add_custom_filter_field :#{field}_quarter do |scope,quarter|
        scope.#{field}_quarter(quarter)
      end
        RUBY
      end

    end

    ## NOTE: These methods are implemented here instead of in included block so that they can be overridden.

    # Accept a scope, and return it after applying filters according to params
    def do_params_filter scope
      filter_params.each do |k,value|
        if value.present?
          if self.class.custom_filter_fields[k].present?
            scope = self.class.custom_filter_fields[k].call scope, value
          elsif resource_class.column_names.include? k
            if resource_class.columns_hash[k].type == :boolean
              if value == '0'
                puts "Should filter"
                scope = scope.where(k => [false,nil])
              else
                scope = scope.where(k => true)
              end
            else
              scope = scope.where(k => value)
            end
          elsif resource_class.reflect_on_association(k.to_sym).present?
            klass = resource_class.reflect_on_association(k.to_sym).klass
            scope = do_inner_params_filter klass, value, scope
          else
            Rails.logger.warn("No filter is available for field #{k}")
          end
        end
      end
      scope
    end

    def do_inner_params_filter klass, params, scope
      params.each do |col,value|
        if klass.columns_hash[col].present?
          if klass.columns_hash[col].type == :boolean
            if value == '0'
              scope = scope.where(klass.arel_table[col].eq(false).or(klass.arel_table[col].eq(nil)))
            else
              scope = scope.where(klass.arel_table[col].eq(true))
            end
          else
            scope = scope.where(klass.arel_table[col].eq(value))
          end
        elsif resource_class.reflect_on_association(col.to_sym).present?
          klass2 = resource_class.reflect_on_association(col.to_sym).klass
          scope = do_inner_params_filter klass2, value, scope
        end
      end
      scope
    end

    # Accept a scope, and return it after applying sort according to params
    def do_params_sort scope
      if self.class.custom_sort_fields[sort_column].present?
        scope = self.class.custom_sort_fields[sort_column].call scope, sort_direction
      elsif resource_class.column_names.include? sort_column
        scope.reorder(resource_class.table_name+"."+sort_column + " " + sort_direction)
      end
    end

    # Do filter first then sort on the scope
    def do_params_filter_and_sort scope
      do_params_sort do_params_filter scope
    end

    # Current index params
    # Used for url params
    def index_params
      {:sort => sort_column, :direction => sort_direction, filter: filter_params }.with_indifferent_access
    end

    # The sort columns and direction
    def sort_column
      sortable_columns.include?(params[:sort]) ? params[:sort] : "created_at"
    end
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    # Deeply remove empty value
    def clean_hash hash
      hash ||= {}
      hash = hash.map do |k,v|
        if v.is_a? Hash
          [k,clean_hash(v)]
        else
          [k,v]
        end
      end
      hash = Hash[hash]
      Hash[hash.select do |k,v|
        if v.is_a? Hash
          v.size > 0
        else
          v.present?
        end
      end]
    end

    # The filter params.
    # A params with blank value is considered not exist
    def filter_params
      @filter_params_cache ||= clean_hash(params[:filter]).with_indifferent_access
    end

    # List of sortable column
    # Usefull for filtering which field can be filtered.
    def sortable_columns
      resource_class.column_names + self.class.custom_sort_fields.keys.map(&:to_s)
    end

    # If the any filter in items is specified, return true
    def filter_available_for *items
      items.any? do |item|
        item = [item] unless item.is_a? Array
        item.reduce(filter_params) do |memo,it|
          if memo.is_a?(Hash)
            if memo[it].nil?
              false
            else
              memo[it]
            end
          else
            false
          end
        end
      end
    end
  end
end
