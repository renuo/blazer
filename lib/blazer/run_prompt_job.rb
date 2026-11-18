module Blazer
  class RunPromptJob < ActiveJob::Base
    RETRIES = 3

    def perform(data_source_id, prompt)
      @data_source = Blazer.data_sources[data_source_id]
      @prompt = prompt
      @schema = @data_source.schema.to_json
      @client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"), log_errors: true)
      generate_sql
    end

    private

    def generate_sql
      sql = nil
      messages = [
        {role: "system", content: system_prompt},
        {role: "system", content: @schema},
        {role: "user", content: @prompt}
      ]

      RETRIES.times do |try_count|
        sql = @client.chat(parameters: {model: "gpt-4o", messages: messages}).dig("choices", 0, "message", "content")
        sql = sql.gsub(/```sql\n/, "").gsub(/\n```$/, "")

        messages << {role: "assistant", content: "Attempt ##{try_count.next}: `#{sql}`"}

        # Blazer runs the statement in a transaction that is rolled back and with a timeout
        result = @data_source.run_statement(sql)
        return sql unless result.error && !result.timed_out?

        Rails.logger.error("Execution of SQL query failed: #{result.error}")
        messages << {role: "user", content: try_again_prompt(result.error)}
      rescue Faraday::UnauthorizedError => e
        return e.response[:body]["error"]["message"]
      end

      sql
    end

    def system_prompt
      <<~PROMPT
        You are an SQL generator for postgres. Make use of the schema json representing the database structure of a
        Ruby on Rails application. Given a prompt you always return an SQL query.
        Make sure that the query performs a SELECT and it is valid.
        Unless specified otherwise, returns all columns (*).
        Never generate a DROP, DELETE, or UPDATE statement.
        Format the query on multiple lines for readability.
        Do not include any comments.
        Do not add a semicolon at the end.
        Always respond with a raw SQL without markdown code block so that it can be directly executed.
        No markdown code blocks, really! Never start with ```.
      PROMPT
    end

    def try_again_prompt(error)
      <<~PROMPT
        This didn't work. The SQL query returned the following error: `#{error}`.
        Please try again and provide a corrected query.
      PROMPT
    end
  end
end
