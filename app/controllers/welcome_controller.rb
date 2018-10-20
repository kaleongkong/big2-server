class WelcomeController < ApplicationController
  $room = {players:{}}
  def join_room
    $room[:players][params[:user]] = true if params[:user]
    render :json => {start_state: ($room[:players].length == 2 ? 1 : -1)}
  end

  def reset
    $room[:players] = {}
    render :json => {user_count: $room[:players].length}
  end
end
