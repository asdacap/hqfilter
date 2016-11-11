
module Hqfilter
  module IndexFilterAndSortViewHelper
    ############################ VIEWS METHOD ##################################
    # Return a link used for sorting. It will toggle the direction if specified
    # and add the sort if no sorting specified.
    def sortable(column, title = nil)
      column = column.to_s
      title ||= resource_class.human_attribute_name column
      direction = ( column == sort_column && sort_direction == "asc" ) ? "desc" : "asc"
      if column == sort_column
        link_to index_params.merge(:sort => column, :direction => direction) do
          if sort_direction == 'asc'
            title + "<i class='fa fa-sort-alpha-asc'></i>"
          else
            title + "<i class='fa fa-sort-alpha-desc'></i>"
          end.html_safe
        end
      else
        link_to title, index_params.merge(:sort => column, :direction => direction)
      end
    end

    # Common code which figurout if the filter exist, the params without the filter and params with the filter
    def add_filter_params column, value
      value = value.to_s
      unless column.is_a? Array
        column = [column]
      end

      column = column.map &:to_s
      column.prepend 'filter'
      has_filter = column.inject(index_params) { |memo, v|
        memo && memo[v]
      } == value

      deleted_params = index_params.deep_dup
      column.inject(deleted_params) { |memo, v|
        if memo.nil?
          nil
        elsif column.last == v
          memo.delete v
        else
          memo[v]
        end
      }
      with_params = index_params.deep_dup
      column.inject(with_params) { |memo, v|
        if memo.nil?
          nil
        elsif column.last == v
          memo[v] = value
        else
          memo[v] ||= {}
          memo[v]
        end
      }

      [has_filter, deleted_params, with_params]
    end

    # Return a icon which is a link used for toggling the filter for the specified column and value
    def add_filter(column, value)
      has_filter, deleted_params, with_params = add_filter_params column,value

      if has_filter
        link_to "<i class='fa fa-filter'></i>".html_safe, deleted_params
      else
        link_to "<i class='fa fa-filter show-on-hover'></i>".html_safe, with_params
      end
    end

    # Return a text which is a link used for toggling the filter for the specified column and value
    def add_filter_text(column, value, text=nil, &block)
      has_filter, deleted_params, with_params = add_filter_params column,value

      text = value if text.nil?

      if has_filter
        link_to deleted_params do
          if block.nil?
            content_tag :b, h(text)
          else
            content_tag :b, &block
          end
        end
      else
        link_to with_params do
          if block.nil?
            h(text)
          else
            block.call
          end
        end
      end
    end

    # Return a link that act as a filter for the date
    def add_date_filter field, date, options = {}
      if date.nil?
        "unspecified"
      else

        if date.is_a? Time
          # tz_date = date.utc We set TZ at postgresql
          tx_date = date
        else
          tx_date = date
        end

        to_display = [:quarter, :year, :month, :day, :time].to_set
        to_display = to_display & options[:only].to_set if options[:only].present?
        to_display = to_display - options[:except].to_set if options[:except].present?

        result = ""
        year_key = "#{field}_year"
        month_key = "#{field}_month"
        day_key = "#{field}_day"
        quarter_key = "#{field}_quarter"
        hour_key = "#{field}_hour"
        minute_key = "#{field}_minute"

        if to_display.include? :quarter
          if index_params[:filter][quarter_key].nil?
            new_params = index_params.deep_dup
            new_params[:filter][quarter_key] = tx_date.quarter
            new_params[:filter][year_key] = tx_date.year
            result += link_to "Q#{date.quarter},", new_params
          else
            new_params = index_params.deep_dup
            new_params[:filter].delete quarter_key
            new_params[:filter].delete month_key
            new_params[:filter].delete day_key
            new_params[:filter].delete hour_key
            new_params[:filter].delete minute_key
            result += "<b>" + link_to("Q#{date.quarter},", new_params) + "</b>"
          end

          result += "&nbsp;"
        end

        if to_display.include? :year
          if index_params[:filter][year_key].nil?
            new_params = index_params.deep_dup
            new_params[:filter][year_key] = tx_date.year
            result += link_to date.year, new_params
          else
            new_params = index_params.deep_dup
            new_params[:filter].delete year_key
            new_params[:filter].delete quarter_key
            new_params[:filter].delete month_key
            new_params[:filter].delete day_key
            new_params[:filter].delete hour_key
            new_params[:filter].delete minute_key
            result += "<b>" + link_to(date.year, new_params) + "</b>"
          end
          result += "&nbsp;"
        end

        if to_display.include? :month
          if index_params[:filter][month_key].nil?
            new_params = index_params.deep_dup
            new_params[:filter][month_key] = tx_date.month
            new_params[:filter][quarter_key] = tx_date.quarter
            new_params[:filter][year_key] = tx_date.year
            result += link_to date.strftime("%b"), new_params
          else
            new_params = index_params.deep_dup
            new_params[:filter].delete month_key
            new_params[:filter].delete day_key
            new_params[:filter].delete hour_key
            new_params[:filter].delete minute_key
            result += "<b>" + link_to(date.strftime("%b"), new_params) + "</b>"
          end
          result += "&nbsp;"
        end

        if to_display.include? :day
          if index_params[:filter][day_key].nil?
            new_params = index_params.deep_dup
            new_params[:filter][day_key] = tx_date.day
            new_params[:filter][month_key] = tx_date.month
            new_params[:filter][quarter_key] = tx_date.quarter
            new_params[:filter][year_key] = tx_date.year
            result += link_to date.day, new_params
          else
            new_params = index_params.deep_dup
            new_params[:filter].delete day_key
            new_params[:filter].delete hour_key
            new_params[:filter].delete minute_key
            result += "<b>" + link_to(date.day, new_params) + "</b>"
          end
        end

        if to_display.include?(:time) && date.is_a?(Time)
          result += ",&nbsp;"
          if index_params[:filter][hour_key].nil?
            new_params = index_params.deep_dup
            new_params[:filter][day_key] = tx_date.day
            new_params[:filter][month_key] = tx_date.month
            new_params[:filter][quarter_key] = tx_date.quarter
            new_params[:filter][year_key] = tx_date.year
            new_params[:filter][hour_key] = tx_date.hour
            result += link_to date.strftime("%H"), new_params
          else
            new_params = index_params.deep_dup
            new_params[:filter].delete hour_key
            new_params[:filter].delete minute_key
            result += "<b>" + link_to(date.strftime("%H"), new_params) + "</b>"
          end
          result += ":"
          if index_params[:filter][minute_key].nil?
            new_params = index_params.deep_dup
            new_params[:filter][day_key] = tx_date.day
            new_params[:filter][month_key] = tx_date.month
            new_params[:filter][quarter_key] = tx_date.quarter
            new_params[:filter][year_key] = tx_date.year
            new_params[:filter][hour_key] = tx_date.hour
            new_params[:filter][minute_key] = tx_date.min
            result += link_to date.strftime("%M"), new_params
          else
            new_params = index_params.deep_dup
            new_params[:filter].delete minute_key
            result += "<b>" + link_to(date.strftime("%M"), new_params) + "</b>"
          end
        end


        result.html_safe
      end
    end

  end
end
