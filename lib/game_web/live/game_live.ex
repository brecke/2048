defmodule GameWeb.GameLive do
  alias Game.Play
  alias GameWeb.MatrixUtils
  use GameWeb, :live_view

  alias GameWeb.Sliding
  alias MatrixReloaded.Matrix
  require IEx

  @left "left"
  @right "right"
  @up "up"
  @down "down"

  defp has_won?(socket) do
    %{status: matrix} = socket.assigns

    victorious_coords = matrix |> MatrixUtils.find_victorious_coords()

    if length(victorious_coords) > 0 do
      socket |> assign(message: "You have won the match!!")
    else
      socket
    end
  end

  defp move(socket, direction) do
    %{status: matrix} = socket.assigns
    socket |> assign(status: matrix |> Sliding.slide(direction), direction: direction)
  end

  defp broadcast_play(socket) do
    %{status: matrix, player: player, direction: direction} = socket.assigns

    Play.broadcast_play(%{
      direction: direction,
      player: switch_player(player),
      status: matrix
    })

    socket
  end

  defp handle_move(socket, direction) do
    socket |> move(direction) |> uncover_new_tile() |> has_won?() |> broadcast_play()
  end

  def handle_event("handle_key_press", %{"key" => "ArrowLeft"} = params, socket) do
    {:noreply, socket |> handle_move(@left)}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowRight"} = params, socket) do
    {:noreply, socket |> handle_move(@right)}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowUp"} = params, socket) do
    {:noreply, socket |> handle_move(@up)}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowDown"} = params, socket) do
    {:noreply, socket |> handle_move(@down)}
  end

  def handle_event("handle_key_press", _params, socket) do
    {:noreply, socket}
  end

  defp switch_player(player) do
    case player do
      "player1" -> "player2"
      "player2" -> "player1"
      _ -> "player1"
    end
  end

  defp uncover_new_tile(socket) do
    %{status: matrix} = socket.assigns

    case MatrixUtils.random_nil_coordinate(matrix) do
      nil ->
        socket |> assign(message: "Sorry you've lost the game, reload window to play again!")

      {row, col} ->
        {:ok, new_matrix} = MatrixUtils.fill_spot(matrix, row, col)
        socket |> assign(status: new_matrix)
    end
  end

  def handle_info({:just_played, play}, socket) do
    %{status: matrix, player: player, direction: direction} = play

    socket = socket |> assign(status: matrix, player: player)

    {:noreply, socket}
  end

  def mount(params, _session, socket) do
    size = params |> Map.get("size", "6") |> String.to_integer()

    # two players only for now
    player = "player1"

    socket = socket |> assign(size: size, player: player)

    socket =
      case connected?(socket) do
        true ->
          Play.subscribe()
          matrix = Matrix.new(size, 0)
          x = :rand.uniform(size) - 1
          y = :rand.uniform(size) - 1
          {:ok, new_matrix} = matrix |> Result.and_then(&Matrix.update_element(&1, 2, {x, y}))

          socket
          |> assign(loading: false, status: new_matrix)

        false ->
          socket
          |> assign(loading: true, status: nil)
      end

    {:ok, socket |> assign(message: nil)}
  end
end
