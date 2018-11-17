module TempTest
  class Component
    def self.test1
      c1 = GameComponent::Card.new(10, 0)
      c2 = GameComponent::Card.new(10, 1)
      c3 = GameComponent::Card.new(10, 2)
      c4 = GameComponent::Card.new(0, 1)
      c5 = GameComponent::Card.new(0, 2)
      king_full_house = GameComponent::Combination.new([c1, c2, c3, c4, c5])
      c1 = GameComponent::Card.new(12, 0)
      c2 = GameComponent::Card.new(12, 1)
      c3 = GameComponent::Card.new(12, 2)
      c4 = GameComponent::Card.new(9, 1)
      c5 = GameComponent::Card.new(9, 2)
      dee_full_house = GameComponent::Combination.new([c1, c2, c3, c4, c5])
      puts "King full house should be smaller than Dee full house: #{king_full_house < dee_full_house}"
    end

    def self.test2
      c1 = GameComponent::Card.new(12, 0)
      c2 = GameComponent::Card.new(0, 1)
      c3 = GameComponent::Card.new(1, 2)
      c4 = GameComponent::Card.new(2, 1)
      c5 = GameComponent::Card.new(3, 2)
      straight = GameComponent::Combination.new([c1, c2, c3, c4, c5])
      puts "2,3,4,5,6 must be valid: #{straight.validate}"
    end

    def self.test3
      c1 = GameComponent::Card.new(3, 1)
      c2 = GameComponent::Card.new(4, 1)
      c3 = GameComponent::Card.new(5, 1)
      c4 = GameComponent::Card.new(6, 1)
      c5 = GameComponent::Card.new(7, 1)
      s1 = GameComponent::Combination.new([c1, c2, c3, c4, c5])
      c1 = GameComponent::Card.new(4, 0)
      c2 = GameComponent::Card.new(5, 0)
      c3 = GameComponent::Card.new(6, 0)
      c4 = GameComponent::Card.new(7, 0)
      c5 = GameComponent::Card.new(8, 0)
      s2 = GameComponent::Combination.new([c1, c2, c3, c4, c5])
      puts "3,4,5,6,7 is straight: #{s1.is_straight}"
      puts "4,5,6,7,8 is straight: #{s2.is_straight}"
      puts "3,4,5,6,7 < 4,5,6,7,8: #{s1 < s2}"
    end
  end
end