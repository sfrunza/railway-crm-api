class Api::V1::PostsController < ApplicationController
  def index
    render json: { message: "Hello World" }, status: :ok
  end
end
