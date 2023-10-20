defmodule Game.Play do
  def broadcast_play(play) do
    play |> broadcast(:just_played)
  end

  # defp broadcast({:error, _reason} = error, _event), do: error
  #
  def subscribe do
    Phoenix.PubSub.subscribe(Game.PubSub, "plays")
  end

  defp broadcast(play, event) do
    Phoenix.PubSub.broadcast(Game.PubSub, "plays", {event, play})
    {:ok, play}
  end
end
