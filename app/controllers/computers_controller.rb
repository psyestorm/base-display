class ComputersController < ApplicationController
  def create
    Computer.parse_post_data(params)
  end
end
