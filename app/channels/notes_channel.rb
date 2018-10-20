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
    ActionCable.server.broadcast('notes', {start_state: 1}) if $room[:players].length == 2
  end
end
