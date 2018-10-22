module GameComponent
  class Card
    include Comparable
    attr_accessor :value, :pattern
    def initialize(value, pattern)
      self.value = value
      self.pattern = pattern
    end

    def patternId2Name(id)
      return ['Diamond', 'Club', 'Heart', 'Spade'][id]
    end

    def valueId2Name(id)
      return (['Ace'] + ((2..10).to_a) + ['Jack', 'Queen', 'King'])[id]
    end

    def to_json
      return {value: valueId2Name(value), pattern: patternId2Name(pattern)}
    end

    def <=> (card)
      if self.value < card.value
        return -1
      elsif self.value > card.value
        return 1
      elsif self.pattern < card.pattern
        return -1 
      elsif self.pattern > card.pattern
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
      self.cards = cards.sort
      self.weight = 1
      validate
    end

    def validate
      return true if cards.empty?
      return false if cards.length == 4 || (cards.length > 5 && cards.length < 13)
      return false if cards.length >= 2 && cards.length <= 3 && cards.map{|c| c.value}.uniq.length > 1
      return is_four_card || is_full_house || is_flash || is_straight
    end

    def is_full_house
      return false if cards.map{|c| c.value}.uniq.length > 2
      return false if ![2,3].include?(cards.select{|c| c.value == cards[0].value}.length)
      self.weight = 4
      return true
    end

    def is_four_card
      return false if cards.map{|c| c.value}.uniq.length > 2
      return false if ![1,4].include?(cards.select{|c| c.value == cards[0].value}.length)
      self.weight = 5
      return true
    end

    def is_straight
      self.weight = 2
      return check_consecutive(cards.map{|c| c.value})
    end

    def is_flash
      self.weight = 3
      return cards.map{|c| c.pattern}.uniq.length == 1
    end

    def is_royal_flash
      r = is_flash && is_straight
      self.weight = 6
      return r
    end

    def <=> (combination)
      combination.sort!
      return 0 if combination.length == 1
      if combination.length <= 3
        return self.cards[-1] <=> combination.cards[-1]
      elsif (is_full_house && combination.is_full_house) || (is_four_card && combination.is_four_card)
        if dominate_value > combination.dominate_value
          return 1
        else
          return 0
        end
      elsif (is_straight && combination.is_straight) || (is_royal_flash && combination.is_royal_flash)
        (0..4).to_a.reverse.each do |i|
          r = cards[i].value <=> combination[i].value
          return r if r!= 0
        end
      elsif (is_flash && combination.is_flash)
        return self.cards[-1].pattern <=> combination.cards[-1].pattern
      else
        return self.weight <=> combination.weight
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
end