class PlayersController < ApplicationController
  http_basic_authenticate_with name: Rails.application.credentials.username,
                           password: Rails.application.credentials.password,
                               only: [:index, :destroy, :regroup]

  def new
    @player = Player.new
  end

  def create
    @player = Player.new(player_params)
    if @player.save
      flash[:notice] = "You have been registered."
      redirect_to root_path
    else
      flash[:error] = "You were not registered."
      render :new
    end
  end

  def index
    @players = Player.groupings
    @grouped_players = @players.map { |p| p.size }.reduce(0, :+)
    @ungrouped_players = Player.recent.count - @grouped_players
    @all_players = Player.recent
  end

  def destroy
    player = Player.find_by(id: params[:id])
    player.destroy
    Player.groupings(force: true)
    redirect_to players_path
  end

  def regroup
    Player.groupings(force: true)
    redirect_to players_path
  end

  private

  def player_params
    params.require(:player).permit(:name, :walker, :rider)
  end
end
