defmodule GdCollabManagerWeb.Utils.PubSubUtils do
  alias Phoenix.PubSub

  def subscribe_to_topic(topic) do
    PubSub.subscribe(GdCollabManager.PubSub, topic)
  end

  def broadcast_to_topic(topic, event, payload) do
    PubSub.broadcast(GdCollabManager.PubSub, topic, {event, payload})
  end
end
