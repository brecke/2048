defmodule GameWeb.GameLive do
  use GameWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      case connected?(socket) do
        true ->
          socket
          |> assign(loading: false)

        false ->
          socket
          |> assign(loading: true)
      end

    IO.puts("yaaaaaaaaaaaaa")

    {:ok, socket}
  end
end
