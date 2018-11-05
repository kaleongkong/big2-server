class WelcomeController < ApplicationController
  protect_from_forgery with: :null_session
  def create_room
    user_id = "User#{rand(999999)}"
    $lobby ||= GameComponent::Lobby.new
    room = GameComponent::Room.new
    $lobby.add_room(room)
    room.add_player(user_id) # will need to check if id is already used.
    render :json => {
      user_id: user_id,
      rooms: $lobby.rooms.values.map{|room| room.to_json},
      room_id: room.id
    }
  end

  def start_game
    # room = $lobby.get_room(params[:room_id])
    # players_stats = {}
    # players_stats[params[:user]] = {game_state: -1}
    # render :json => {players_stats: players_stats, room_id: room.id}
  end

  def get_rooms
    $lobby ||= GameComponent::Lobby.new
    render :json => {
      rooms: ($lobby.rooms ? $lobby.rooms.values.map{|room| room.to_json} : [])
    }
  end

  def delete_room
    $lobby ||= GameComponent::Lobby.new
    $lobby.rooms.delete(params[:room_id])
    render :json => {rooms: ($lobby.rooms ? $lobby.rooms.values.map{|room| room.to_json} : [])}
  end

  def join_room
    room_id = params[:room_id]
    user_id = (params[:user_id] && !params[:user_id].empty?) || "User#{rand(999999)}"
    room = $lobby.get_room(room_id)
    room.add_player(user_id)
    render :json => {
      rooms: ($lobby.rooms ? $lobby.rooms.values.map{|room| room.to_json} : []), 
      user_id: user_id,
      room_id: room.id
    }
  end

  def leave_room
    room_id = params[:room_id]
    user_id = params[:user_id]
    room = $lobby.get_room(room_id)
    room.remove_player(user_id)
    render :json => {
      rooms: ($lobby.rooms ? $lobby.rooms.values.map{|room| room.to_json} : []), 
      user_id: user_id,
      room_id: room.id
    }
  end

  def join_room_old
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
