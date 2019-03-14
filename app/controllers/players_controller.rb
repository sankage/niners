class PlayersController < ApplicationController
  http_basic_authenticate_with name: Rails.application.credentials.username,
                           password: Rails.application.credentials.password,
                               only: [:index, :destroy, :regroup, :promote]

  def new
    # Signups are closed from Sunday 12:30 until Tuesday 12:30
    right_now = Time.zone.now
    if right_now.sunday? || right_now.monday? || right_now.tuesday?
      closed = true
      if right_now.sunday? && (right_now.hour < 19 || (right_now.hour == 19 && right_now.min < 30))
        closed = false
      end
      if right_now.tuesday? && (right_now.hour > 13 || (right_now.hour == 12 && right_now.min >= 30))
        closed = false
      end
    end
    @signup_closed = closed
    @player = Player.new(on_standby: false)
  end

  def create
    if Player.recent.pluck(:name).include? player_params[:name]
      flash[:notice] = "You have already registered."
      redirect_to root_path
      return
    end
    @player = Player.with_deleted.where(name: player_params[:name]).first_or_create
    if @player.update(player_params.merge(created_at: Time.now, deleted_at: nil))
      flash[:success] = "You have been registered."
      redirect_to root_path
    else
      flash[:error] = "You were not registered."
      render :new
    end
  end

  def index
    @players = Player.groupings
    @grouped_players = @players.map { |p| p.size }.reduce(0, :+)
    @standby_players = Player.on_standby
    @all_players = Player.recent.order(:name) - @standby_players
    @ungrouped_players = @all_players.size - @grouped_players
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

  def promote
    player = Player.find_by(id: params[:id])
    player.promote!
    redirect_to players_path
  end

  private

  def player_params
    params.require(:player).permit(:name, :walker, :rider, :on_standby)
  end
end
