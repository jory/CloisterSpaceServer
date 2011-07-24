class GamesController < ApplicationController

  respond_to :json
  
  def index
    @games = Game.where(:user_id => session[:user_id])
  end

  def show
    @game = Game.where(:id => params[:id], :user_id => session[:user_id]).first
  end

  def new
    @game = Game.new(:user_id => session[:user_id])
    if @game.save
      redirect_to(@game, :notice => 'Game was successfully created.')
    else
      render :action => "new"
    end
  end

  def create
    @game = Game.new(params[:game])
    if @game.save
      redirect_to(@game, :notice => 'Game was successfully created.')
    else
      render :action => "new"
    end
  end

  def destroy
    @game = Game.where(:id => params[:id], :user_id => session[:user_id]).first
    @game.destroy
    redirect_to(games_url)
  end

  def next
    @game = Game.where(:id => params[:game_id], :user_id => session[:user_id]).first
    @tileInstance = @game.next()
    respond_with(@tileInstance)
  end
  
end
