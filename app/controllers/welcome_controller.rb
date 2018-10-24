class WelcomeController < ApplicationController
  protect_from_forgery with: :null_session
  def join_room
    $room ||= {}
    $room[:players] ||= {}
    $room[:players][params[:user]] = true if params[:user]
    $room[:last_combination_data] ||= {}
    user1 = {
      start_state: -1
    }
    user2 = {
      start_state: -1
    }
    render :json => {user1: user1, user2: user2}
  end

  def move
    cards = []
    params[:combination].each do |card|
      cards << GameComponent::Card.new(card['value'], card['pattern'])
    end
    puts "cards: #{cards.to_json}"
    puts $room
    combination = GameComponent::Combination.new(cards)

    # puts $room[:last_combination_data][:combination] < combination
    if (combination.validate && 
      ($room[:last_combination_data].empty? || $room[:last_combination_data][:user] == params[:user] || 
        ($room[:last_combination_data][:combination].cards.length == combination.cards.length && 
          $room[:last_combination_data][:combination] < combination)))
      $room[:last_combination_data] = {user: params[:user], combination: combination}
      render :json => params[:combination]
    else
      render :json => {error: 'Invalid combination'}
    end
  end

  def pass
    puts "last_combination_data: #{$room[:last_combination_data]}"
    puts "params: #{params[:last_player]}"
    if ($room[:last_combination_data].empty? || $room[:last_combination_data][:user] != params[:last_player])
      render :json => {success: "Success"}
    else
      render :json => {error: "All your components are passed. It's your turn to serve."}
    end
  end

  def reset
    $room = {}
    render :json => {user_count: 0}
  end
end
