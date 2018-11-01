class WelcomeController < ApplicationController
  protect_from_forgery with: :null_session
  def join_room
    $lobby ||= GameComponent::Lobby.new
    puts "lobby: #{$lobby.rooms}"
    room = params[:room_id] ? $lobby.get_room(params[:room_id]) : GameComponent::Room.new
    $lobby.add_room(room) if !$lobby.contains?(room.id)
    room.add_player(params[:user]) if params[:user]

    players_stats = {}
    players_stats[params[:user]] = {game_state: -1}
    puts "join_room: #{{players_stats: players_stats, room_id: room.id}}"
    render :json => {players_stats: players_stats, room_id: room.id}
  end

  def move
    cards = []
    params[:combination].each do |card|
      cards << GameComponent::Card.new(card['value'], card['pattern'])
    end
    combination = GameComponent::Combination.new(cards)

    room = $lobby.get_room(params[:room_id])
    puts combination.validate
    puts room.is_new?
    puts room.last_player == params[:user]

    if (combination.validate && (room.is_new? || room.last_player == params[:user] || 
        (room.last_combination.length == combination.length && 
          room.last_combination < combination)))
      room.last_combination = combination
      room.last_player = params[:user]
      render :json => params
    else
      render :json => {error: 'Invalid combination'}
    end
  end

  def pass
    room = $lobby.get_room(params[:room_id])
    if (room.is_new? || room.last_player != params[:last_player])
      render :json => {success: "Success"}
    else
      render :json => {error: "All your components are passed. It's your turn to serve."}
    end
  end

  def reset
    room = $lobby.get_room(params[:room_id])
    $lobby.remove_room(room)
    render :json => {user_count: 0}
  end
end
