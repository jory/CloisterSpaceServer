class GamesController < ApplicationController

  respond_to :json
  
  def index
    ids = Player.where(:user_id => session[:user_id]).collect { |p| p.game_id }
    @games = Game.where(:id => ids)
  end

  def show
    @game = Game.find(params[:id])

    if @game.players.where(:user_id => session[:user_id]).empty?
      flash[:error] = "Naughty!"
      redirect_to games_url
      # Does the previous redirect end the action, or do I have to
      # explicitly return?
    end

    @edges = Edge.all
    @tiles = Tile.all
    @placed = @game.tileInstances.where(:status => "placed")
  end

  def new
    @game = Game.new
  end

  def create
    params[:game][:creator] = User.find(session[:user_id])
    params[:game][:users] = params[:game][:users].collect {|user| user[:email]}

    @game = Game.new(params[:game])
    if @game.save
      redirect_to(@game, :notice => 'Game was successfully created.')
    else
      render :action => "new"
    end
  end

  def destroy
    @game = Game.find(params[:id])
    if @game and @game.creator.id == session[:user_id]
      @game.destroy
    end
    redirect_to(games_url)
  end

  def next
    @game = Game.where(:id => params[:game_id]).first
    @tileInstance = @game.next()
    respond_with([@game.current_player, @tileInstance])
  end
  
end
