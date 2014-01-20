class PlayersController < ApplicationController
  def new
  end

  def create
    player=Player.new
    player.name=params[:name]
    player.save
    @player=player
  end

  def update
  end

  def delete
  end

  def show

  end

  def index
  end

  def edit
  end
end
