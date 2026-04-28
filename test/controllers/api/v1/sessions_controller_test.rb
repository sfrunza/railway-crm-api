require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "create returns bearer token" do
    post api_v1_session_url, params: { email_address: @user.email_address, password: "password" }

    assert_response :success
    assert_not_nil JSON.parse(response.body)["token"]
  end

  test "magic exchanges signed token for bearer token" do
    token = @user.generate_token_for(:magic_login)

    post magic_api_v1_session_url, params: { magic_token: token }

    assert_response :success
    body = JSON.parse(response.body)
    assert_not_nil body["token"]
  end

  test "magic rejects invalid token" do
    post magic_api_v1_session_url, params: { magic_token: "invalid" }

    assert_response :unauthorized
  end

  test "show returns user when authenticated" do
    post api_v1_session_url, params: { email_address: @user.email_address, password: "password" }
    bearer = JSON.parse(response.body)["token"]

    get api_v1_session_url, headers: { "Authorization" => "Bearer #{bearer}" }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal @user.id, body["user"]["id"]
    assert_equal @user.email_address, body["user"]["email_address"]
  end
end
