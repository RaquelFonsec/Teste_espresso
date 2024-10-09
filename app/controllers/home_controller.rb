class HomeController < ApplicationController
  def index
    render json: { message: 'Success' }, status: :ok
  end
end
