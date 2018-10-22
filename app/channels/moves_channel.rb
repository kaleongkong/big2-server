class MovesChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from 'moves'
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    last_player = data['last_player']
    user1 = data['last_player'] == 'user2' ? 1 : 2
    user2 = data['last_player'] == 'user2' ? 2 : 1
    data[:users] = [{id: 1, game_state: user1}, {id: 2, game_state: user2}]
    ActionCable.server.broadcast('moves', data)
  end
end
