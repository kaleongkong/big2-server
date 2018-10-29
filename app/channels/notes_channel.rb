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
    room = data["room_id"] ? $lobby.get_room(data["room_id"]) : GameComponent::Room.new
    $lobby.add_room(room) if !$lobby.contains?(room.id)
    room.add_player(data["user"].to_i) if data["user"]

    deck = NotesChannel.generate_cards
    users = []
    GameComponent::NUM_OF_PLAYERS.times do
      users << Hash.new
    end
    if room.num_of_players == GameComponent::NUM_OF_PLAYERS
      min_player = {i: -1, value: 13}
      GameComponent::NUM_OF_PLAYERS.times do |i|
        # num_of_cards = (deck.length/4)
        num_of_cards = 3
        users[i][:deck] = deck[i * num_of_cards.. (i+1) * num_of_cards - 1]
        min_player = {i: i, value: users[i][:deck].min.value} if users[i][:deck].min.value < min_player[:value]
        users[i][:deck] = users[i][:deck].sort.map{|card| card.to_json}
      end
      GameComponent::NUM_OF_PLAYERS.times do |i|
        users[i][:game_state] = i == min_player[:i] ? 1 : 2
      end
      ActionCable.server.broadcast('notes', {players_stats: users, room_id: room.id})
    end
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
