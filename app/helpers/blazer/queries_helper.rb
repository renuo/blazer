module Blazer
  module QueriesHelper
    def gpt?(query)
      defined?(OpenAI) && query.respond_to?(:gpt_prompt) && (params[:gpt].present? || query.gpt_prompt.present?)
    end
  end
end
