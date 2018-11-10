module GameComponent
  NUM_OF_PLAYERS = 3
  class Card
    include Comparable
    attr_accessor :value, :pattern
    def initialize(value, pattern)
      @value = value
      @pattern = pattern
    end

    def patternId2Name(id)
      return ['Diamond', 'Club', 'Heart', 'Spade'][id]
    end

    def valueId2Name(id)
      return (((3..10).to_a.map{|i| i.to_s}) + ['Jack', 'Queen', 'King', 'Ace', '2'])[id]
    end

    def to_json
      return {value: value, name: valueId2Name(value), pattern: pattern, pattern_name: patternId2Name(pattern)}
    end

    def <=> (card)
      if @value < card.value
        return -1
      elsif @value > card.value
        return 1
      elsif @pattern < card.pattern
        return -1 
      elsif @pattern > card.pattern
        return 1
      else
        return 1
      end
    end
  end

  class Combination
    include Comparable
    attr_accessor :cards, :weight
    def initialize(cards=[])
      @cards = cards.sort
      @weight = 1
      validate
    end

    def validate
      return false if cards.empty?
      return false if cards.length == 4 || (cards.length > 5 && cards.length < 13)
      return false if cards.length >= 2 && cards.length <= 3 && cards.map{|c| c.value}.uniq.length > 1
      return is_four_card || is_full_house || is_flash || is_straight
    end

    def is_full_house
      return false if cards.map{|c| c.value}.uniq.length > 2
      return false if ![2,3].include?(cards.select{|c| c.value == cards[0].value}.length)
      @weight = 4
      return true
    end

    def is_four_card
      return false if cards.map{|c| c.value}.uniq.length > 2
      return false if ![1,4].include?(cards.select{|c| c.value == cards[0].value}.length)
      @weight = 5
      return true
    end

    def is_straight
      @weight = 2
      return check_consecutive(cards.map{|c| c.value})
    end

    def is_flash
      @weight = 3
      return cards.map{|c| c.pattern}.uniq.length == 1
    end

    def is_royal_flash
      r = is_flash && is_straight
      @weight = 6
      return r
    end

    def length
      return @cards.length
    end

    def <=> (combination)
      combination.cards.sort!
      if combination.cards.length <= 3
        return @cards[-1] <=> combination.cards[-1]
      elsif @weight != combination.weight
        return @weight <=> combination.weight
      elsif (is_full_house && combination.is_full_house) || (is_four_card && combination.is_four_card)
        if dominate_value > combination.dominate_value
          return 1
        else
          return 0
        end
      elsif (is_straight && combination.is_straight) || (is_royal_flash && combination.is_royal_flash)
        (0..4).to_a.reverse.each do |i|
          r = cards[i].value <=> combination.cards[i].value
          return r if r!= 0
        end
      elsif (is_flash && combination.is_flash)
        return @cards[-1].pattern <=> combination.cards[-1].pattern
      else
        return 0
      end
    end

    def dominate_value
      map = Hash.new(0)
      cards.each do |card|
        map[card.value] += 1
      end
      return map.max_by{|k, v| v}[0]
    end

    def check_consecutive(values)
      values.sort!
      values.each_with_index do |v, i|
        break if values[i+1].nil?
        return false if v+1 != values[i+1]
      end
      return true
    end
  end

  class Lobby
    attr_accessor :rooms
    def initialize()
      @rooms = {}
    end

    def contains?(room_id)
      !!@rooms[room_id]
    end

    def add_room(room)
      while @rooms[room.id]
        room.reset_id
      end
      @rooms[room.id] = room
    end

    def remove_room(room)
      @rooms.delete room.id
    end

    def get_room(room_id)
      @rooms[room_id]
    end
  end

  class Room
    attr_reader :id
    attr_accessor :players, :last_player, :last_combination, :owner
    def initialize()
      @id = rand(9999999).to_s
      @players = {}
      @last_player = nil
      @last_combination = nil
      @owner = nil
    end

    def reset_id
      @id = rand(9999999).to_s
    end

    def add_player(user)
      @owner = user.id if @players.empty?
      @players[user.id] ||= user
    end

    def get_player(user_id)
      return @players[user_id]
    end

    def remove_player(id)
      @players.delete(id)
    end

    def get_players
      @players.keys
    end

    def get_order(id)
      @players.keys.index(id)
    end

    def num_of_players
      @players.length
    end

    def is_new?
      return @last_player.nil? && @last_combination.nil?
    end

    def to_json
      return { user_ids: @players.keys, limit: 4, id: @id, owner: @owner}
    end
  end

  class User
    attr_reader :id, :hand, :game_state
    def initialize(id)
      @id = id
      @hand = []
      @game_state = 0
    end

    def set_hand(hand)
      @hand = hand
    end

    def remove_card(card)
      @hand.reject! {|c| card == c}
    end

    def set_game_state(game_state)
      @game_state = game_state
    end

    def min_card
      hand.empty? ? GameComponent::Card.new(13, 3) : hand.min
    end

    def stat_json
      {game_state: @game_state, deck: @hand.sort.map{|card| card.to_json}}
    end
  end
end