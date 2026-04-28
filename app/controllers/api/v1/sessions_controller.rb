class Api::V1::SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ create magic ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
    render json: { error: "Too many login attempts. Try again later." },
           status: :too_many_requests
  }
  rate_limit to: 20, within: 3.minutes, only: :magic, with: -> {
    render json: { error: "Too many attempts. Try again later." },
           status: :too_many_requests
  }

  def create
    if user = User.authenticate_by(session_params)
      start_new_session_for(user)
      render json: { token: Current.session.token }
    else
      render json: { error: "Invalid email address or password" }, status: :unauthorized
    end
  end

  # Exchange a short-lived magic_login token (from email link query string) for a session bearer token.
  def magic
    user = User.find_by_token_for!(:magic_login, params.require(:magic_token))
    start_new_session_for(user)
    render json: { token: Current.session.token }
  rescue ActionController::ParameterMissing
    render json: { error: "magic_token is required" }, status: :unprocessable_content
  rescue ActiveRecord::RecordNotFound, ActiveSupport::MessageVerifier::InvalidSignature
    render json: { error: "Invalid or expired link" }, status: :unauthorized
  end

  def show
    render json: { user: current_user_payload }
  end


  def destroy
    terminate_session
    render json: { message: "Logged out" }, status: :ok
  end

  private

  def session_params
    params.permit(:email_address, :password)
  end

  def current_user_payload
    user = Current.user
    return {} if user.nil?

    { id: user.id, email_address: user.email_address }
  end
end
