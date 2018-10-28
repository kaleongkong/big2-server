class NotesChannel < ApplicationCable::Channel 
  def subscribed
    # stream_from "some_channel"
    stream_from 'notes'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    $room[:players] ||= {}
    $room[:last_combination_data] ||= {}
    $room[:players][data["user"].to_i] = true if data["user"]
    deck = NotesChannel.generate_cards
    users = []
    GameComponent::NUM_OF_PLAYERS.times do
      users << Hash.new
    end
    # user1, user2 = Hash.new, Hash.new
    if $room[:players].length == GameComponent::NUM_OF_PLAYERS
      min_player = {i: -1, value: 13}
      GameComponent::NUM_OF_PLAYERS.times do |i|
        # num_of_cards = (deck.length/4)
        num_of_cards = 5
        users[i][:deck] = deck[i * num_of_cards.. (i+1) * num_of_cards - 1]
        min_player = {i: i, value: users[i][:deck].min.value} if users[i][:deck].min.value < min_player[:value]
        users[i][:deck] = users[i][:deck].sort.map{|card| card.to_json}
      end
      GameComponent::NUM_OF_PLAYERS.times do |i|
        users[i][:game_state] = i == min_player[:i] ? 1 : 2
      end
      ActionCable.server.broadcast('notes', {players_stats: users})
      # user1[:deck] = deck[0..(deck.length/4)-1]
      # user2[:deck] = deck[(deck.length/4).. 2 * (deck.length/4)-1]
      # user1[:game_state] = user1[:deck].min < user2[:deck].min ? 1 : 2
      # user2[:game_state] = user1[:deck].min < user2[:deck].min ? 2 : 1
      # user1[:deck] = user1[:deck].sort.map{|card| card.to_json}
      # user2[:deck] = user2[:deck].sort.map{|card| card.to_json}
      # ActionCable.server.broadcast('notes', {user1: user1, user2: user2})
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
