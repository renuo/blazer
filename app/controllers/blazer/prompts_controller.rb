module Blazer
  class PromptsController < BaseController
    def run
      return head :not_found unless defined?(OpenAI)

      render plain: RunPromptJob.perform_now(Blazer.data_sources[params[:data_source]].id, params[:prompt])
    end
  end
end
