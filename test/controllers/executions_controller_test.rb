require "test_helper"

class ExecutionsControllerTest < ActionDispatch::IntegrationTest
  test "creates a code execution and returns the output without errors for a correct answer" do
    post executions_url, params: { content: "has_many :posts"}
    assert_response :success
    assert response.body.include?("0 failures, 0 errors")
  end
end
