class MovesChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "moves_#{params[:roomId]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    room = $lobby.get_room(data['room_id'])
    last_player = data['last_player']
    data['players_stats'] = {}
    data['players_stats']['users'] = {}
    room.get_players.map{|player| player.id}.each_with_index do |id, i|
      data['players_stats']['users'][id] = {
        id: id, 
        hand: room.get_player(id).stat_json[:deck],
        game_state: room.get_order(data['last_player']) == (i-1)%room.get_players.length ? 1 : 2}
    end
    data['combination'] = room.last_combination.cards.map{|c| c.to_json} if !room.is_new? && data['combination'].empty?
    ActionCable.server.broadcast("moves_#{room.id}", data)
  end
end
