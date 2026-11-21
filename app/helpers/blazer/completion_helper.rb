module Blazer
  module CompletionHelper
    COLUMN_SCORE = 1001
    TABLE_SCORE = 1000

    # the tables and columns for the autocompletion of the SQL editor
    def blazer_table_name_completion_source(data_source)
      schema = begin
        data_source.schema
      rescue StandardError => e
        Rails.logger.warn("Blazer: no schema for the autocompletion: #{e.message}")
        []
      end

      schema.map do |entry|
        {
          value: entry[:table],
          columns: entry[:columns].map { |column| {value: column[:name], score: COLUMN_SCORE, meta: "column_name"} },
          score: TABLE_SCORE,
          meta: "table_name"
        }
      end
    end
  end
end
