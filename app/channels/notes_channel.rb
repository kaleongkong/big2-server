class NotesChannel < ApplicationCable::Channel 
  def subscribed
    # stream_from "some_channel"
    stream_from 'notes'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    $lobby ||= GameComponent::Lobby.new
    puts [$lobby.rooms]
    room = data["room_id"] ? $lobby.get_room(data["room_id"]) : GameComponent::Room.new
    $lobby.add_room(room) if !$lobby.contains?(room.id)
    # room.add_player(data["user"]) if data["user"]

    deck = NotesChannel.generate_cards
    users = {}
    room.get_players.each do |id|
      users[id] = Hash.new
    end
    if room.num_of_players == GameComponent::NUM_OF_PLAYERS
      min_player = {i: -1, value: 13}
      room.get_players.each_with_index do |id, i|
        # num_of_cards = (deck.length/4)
        num_of_cards = 3
        users[id][:deck] = deck[i * num_of_cards.. (i+1) * num_of_cards - 1]
        min_player = {i: i, value: users[id][:deck].min.value} if users[id][:deck].min.value < min_player[:value]
        users[id][:deck] = users[id][:deck].sort.map{|card| card.to_json}
      end
      room.get_players.each_with_index do |id, i|
        users[id][:game_state] = i == min_player[:i] ? 1 : 2
      end
    else
      room.get_players.each_with_index do |id, i|
        users[id][:game_state] = -1
      end
    end
    puts "receive: #{{players_stats: users, room_id: room.id}}"
    ActionCable.server.broadcast('notes', {players_stats: users, room_id: room.id})
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
