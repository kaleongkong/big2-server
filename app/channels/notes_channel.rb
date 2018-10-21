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
    $room[:players][data["user"]] = true if data["user"]
    deck = NotesChannel.generate_cards
    if $room[:players].length == 2
      ActionCable.server.broadcast('notes', {start_state: 1, user1: deck[0..(deck.length/4)-1].sort_by{|card| card[:order]}, user2: deck[(deck.length/4).. 2 * (deck.length/4)-1].sort_by{|card| card[:order]}})
    end
  end

  def self.generate_cards
    nums = (1..13).to_a
    values = nums.map do |num|
      if num == 11
        num = 'J'
      elsif num == 12
        num = 'Q'
      elsif num == 13
        num = 'K'
      end
      num
    end
    patterns = ['diamond', 'cube', 'heart', 'spade']
    cards = []
    patterns.each do |p|
      values.each do |v|
        order = v
        order = v == 'J' ? 11 : (v=='Q' ? 12 : 13) if ['J', 'Q', 'K'].include?(v)
        cards << {value: v, pattern: p, order: order}
      end
    end
    cards.shuffle!
    return cards
  end
end
