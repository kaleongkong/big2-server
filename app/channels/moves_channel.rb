class MovesChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from 'moves'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    room = $lobby.get_room(data['room_id'])
    last_player = data['last_player']
    data['players_stats'] = {}
    data['players_stats']['users'] = {}
    room.get_players.each_with_index do |id, i|
      data['players_stats']['users'][id] = {id: id, game_state: room.get_order(data['last_player']) == (i-1)%GameComponent::NUM_OF_PLAYERS ? 1 : 2}
    end
    data['combination'] = room.last_combination.cards.map{|c| c.to_json} if !room.is_new? && data['combination'].empty?
    ActionCable.server.broadcast('moves', data)
  end
end
