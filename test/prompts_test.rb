require_relative "test_helper"

class PromptsTest < ActionDispatch::IntegrationTest
  class FakeClient
    class << self
      attr_accessor :answers, :messages
    end

    def initialize(*)
    end

    def chat(parameters:)
      self.class.messages = parameters[:messages].map(&:dup)
      {"choices" => [{"message" => {"content" => self.class.answers.shift}}]}
    end
  end

  def setup
    super
    Object.const_set(:OpenAI, Module.new) unless defined?(OpenAI)
    OpenAI.const_set(:Client, FakeClient)
    ENV["OPENAI_API_KEY"] ||= "test"
  end

  def teardown
    OpenAI.send(:remove_const, :Client)
    Object.send(:remove_const, :OpenAI) if OpenAI.constants.empty?
    super
  end

  def test_run
    FakeClient.answers = ["```sql\nSELECT 1\n```"]

    post blazer.run_prompts_path, params: {prompt: "one", data_source: "main"}
    assert_response :success
    assert_equal "SELECT 1", response.body
  end

  def test_run_retries_invalid_sql
    FakeClient.answers = ["SELECT FROM nowhere WHERE", "SELECT 2"]

    post blazer.run_prompts_path, params: {prompt: "two", data_source: "main"}
    assert_equal "SELECT 2", response.body
    assert_match "returned the following error", FakeClient.messages.last[:content]
  end

  def test_run_without_openai
    OpenAI.send(:remove_const, :Client)
    Object.send(:remove_const, :OpenAI)

    post blazer.run_prompts_path, params: {prompt: "one", data_source: "main"}
    assert_response :not_found
  ensure
    Object.const_set(:OpenAI, Module.new)
    OpenAI.const_set(:Client, FakeClient)
  end

  def test_form
    get blazer.new_query_path
    assert_response :success
    refute_match %(id="prompt-editor"), response.body

    get blazer.new_query_path(gpt: 1)
    assert_response :success
    assert_match %(id="prompt-editor"), response.body
  end

  def test_create_saves_prompt
    post blazer.queries_path, params: {query: {name: "Test", statement: "SELECT 1", data_source: "main", gpt_prompt: "one"}}
    assert_equal "one", Blazer::Query.last.gpt_prompt
  end
end
