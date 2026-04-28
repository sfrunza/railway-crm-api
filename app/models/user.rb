class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_digest&.last(10)
  end

  # Short-lived signed token for email "sign in" links. Exchange via POST /api/v1/session/magic
  # with JSON body { magic_token: "..." } — do not treat this token as a session credential until exchanged.
  generates_token_for :magic_login, expires_in: 15.minutes do
    [ id, email_address ]
  end
end
