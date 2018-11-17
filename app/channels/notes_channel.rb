class NotesChannel < ApplicationCable::Channel 
  def subscribed
    # stream_from "some_channel"
    stream_from "notes_#{params[:roomId]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    $lobby ||= GameComponent::Lobby.new
    puts [$lobby.rooms]
    room = data["room_id"] ? $lobby.get_room(data["room_id"]) : GameComponent::Room.new
    $lobby.add_room(room) if !$lobby.contains?(room.id)

    deck = NotesChannel.generate_cards
    users = {}
    room.get_players.each do |player|
      users[player.id] = player
    end
    min_player = GameComponent::User.new
    room.get_players.each_with_index do |player, i|
      num_of_cards = 13
      player.set_hand(deck[i * num_of_cards.. (i+1) * num_of_cards - 1])
      min_player = player if player.min_card < min_player.min_card
    end
    room.get_players.each do |player|
      player.set_game_state(player.id === min_player.id ? 1 : 2)
    end
    users = Hash[users.map{|k, v| [k, v.stat_json]}]
    ActionCable.server.broadcast("notes_#{room.id}", {players_stats: users, room_id: room.id})
  end

  def self.generate_cards
    values = (0..12).to_a
    patterns = (0..3).to_a
    cards = []
    values.each do |v|
      patterns.each do |p|
        cards << GameComponent::Card.new(v, p)
      end
    end
    return cards.shuffle
  end
end
