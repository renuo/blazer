module Blazer
  module BaseHelper
    def blazer_title(title = nil)
      if title
        content_for(:title) { title }
      else
        content_for?(:title) ? content_for(:title) : nil
      end
    end

    BLAZER_URL_REGEX = /\Ahttps?:\/\/[\S]+\z/
    BLAZER_IMAGE_EXT = %w[png jpg jpeg gif]

    BLAZER_COMPLETION_COLUMN_SCORE = 1001
    BLAZER_COMPLETION_COLUMN_META = 'column_name'
    BLAZER_COMPLETION_TABLE_SCORE = 1000
    BLAZER_COMPLETION_TABLE_META = 'table_name'


    def extract_tables_and_columns(schema)
      schema.map do |schema_entry|
        [schema_entry[:table], schema_entry[:columns]]
      end
    end

    def blazer_table_name_completion_source
      extract_tables_and_columns(Blazer.data_sources['main'].schema).collect do |entry|
        {
          value: entry.first,
          columns: entry.last.map do |column|
            {
              value: column[:name],
              score: BLAZER_COMPLETION_COLUMN_SCORE,
              meta: BLAZER_COMPLETION_COLUMN_META
            }
          end,
          score: BLAZER_COMPLETION_TABLE_SCORE,
          meta: BLAZER_COMPLETION_TABLE_META
        }
      end.to_json
    end

    def blazer_format_value(key, value)
      if value.is_a?(Numeric) && !key.to_s.end_with?("id") && !key.to_s.start_with?("id")
        number_with_delimiter(value)
      elsif value.is_a?(String) && value =~ BLAZER_URL_REGEX
        # see if image or link
        if Blazer.images && (key.include?("image") || BLAZER_IMAGE_EXT.include?(value.split(".").last.split("?").first.try(:downcase)))
          link_to value, target: "_blank" do
            image_tag value, referrerpolicy: "no-referrer"
          end
        else
          link_to value, value, target: "_blank"
        end
      else
        value
      end
    end

    def blazer_maps?
      Blazer.mapbox_access_token.present?
    end

    def blazer_js_var(name, value)
      "var #{name} = #{json_escape(value.to_json(root: false))};".html_safe
    end

    def blazer_series_name(k)
      k.nil? ? "null" : k.to_s
    end
  end
end
