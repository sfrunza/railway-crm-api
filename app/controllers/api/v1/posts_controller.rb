class Api::V1::PostsController < ApplicationController
  CACHE_KEY = "#{Rails.env}/posts_v1"

  def index
    @message = Rails.cache.fetch(CACHE_KEY, expires_in: 1.day) do
      Rails.logger.info "[CACHE] MISS: loading fresh posts"
      { message: "Hello World" }
    end

    Rails.logger.info "[CACHE] HIT: returning cached posts"
    render json: @message, status: :ok
  end

  # def index
  #   render json: { message: "Hello World" }
  # end
end
