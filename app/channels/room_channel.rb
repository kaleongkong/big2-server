class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    $lobby ||= GameComponent::Lobby.new
    output = {
      rooms: ($lobby.rooms ? $lobby.rooms.values.map{|room| room.to_json} : []),
      userAction: data['userAction']
    }
    ActionCable.server.broadcast("room", output)
  end
end
