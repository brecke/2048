defmodule GameWeb.GameLive do
  alias Phoenix.Presence
  alias Game.Play
  alias GameWeb.MatrixUtils
  use GameWeb, :live_view

  alias GameWeb.Presence
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
    %{status: matrix, next_player: player, direction: direction} = socket.assigns

    Play.broadcast_play(%{
      direction: direction,
      next_player: switch_player(player),
      status: matrix,
      players: Presence.list("users")
    })

    socket
  end

  defp handle_move(socket, direction) do
    %{current_user: current_user, next_player: next_player} = socket.assigns

    # only accept key strokes from the next_player :)
    case current_user == next_player do
      true ->
        socket |> move(direction) |> uncover_new_tile() |> has_won?() |> broadcast_play()

      false ->
        socket
    end
  end

  def handle_event("handle_key_press", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, socket |> handle_move(@left)}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowRight"}, socket) do
    {:noreply, socket |> handle_move(@right)}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowUp"}, socket) do
    {:noreply, socket |> handle_move(@up)}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowDown"}, socket) do
    {:noreply, socket |> handle_move(@down)}
  end

  def handle_event("handle_key_press", _params, socket) do
    {:noreply, socket}
  end

  defp next_player(all_players, current_player) when is_list(all_players) do
    index = all_players |> Enum.find_index(&(&1 == current_player))

    case index == length(all_players) - 1 do
      true -> all_players |> Enum.at(0)
      _ -> all_players |> Enum.at(index + 1)
    end
  end

  defp switch_player(current_player) do
    all_pids = Presence.list("users") |> Map.keys()

    next_player(all_pids, current_player)
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
    %{status: matrix, next_player: player, direction: direction, players: players} = play

    socket = socket |> assign(status: matrix, next_player: player, players: players)

    {:noreply, socket}
  end

  defp get_random_coord(size), do: :rand.uniform(size) - 1

  defp trim_down_pid() do
    self()
    |> :erlang.pid_to_list()
    |> List.delete_at(0)
    |> List.delete_at(-1)
    |> to_string()
  end

  def mount(params, _session, socket) do
    size = params |> Map.get("size", "6") |> String.to_integer()

    socket = socket |> assign(size: size)

    socket =
      case connected?(socket) do
        true ->
          uuid = trim_down_pid()

          Presence.track(self(), "users", uuid, %{
            name: "player#{uuid}"
          })

          all_players = Presence.list("users")

          next_player =
            all_players |> Map.keys() |> hd()

          Play.subscribe()
          matrix = Matrix.new(size, 0)

          # Gonna place 3 obstacles randomly
          {:ok, new_matrix} =
            matrix
            |> Result.and_then(
              &Matrix.update_element(&1, 2, {get_random_coord(size), get_random_coord(size)})
            )
            |> Result.and_then(
              &Matrix.update_element(&1, -1, {get_random_coord(size), get_random_coord(size)})
            )
            |> Result.and_then(
              &Matrix.update_element(&1, -1, {get_random_coord(size), get_random_coord(size)})
            )
            |> Result.and_then(
              &Matrix.update_element(&1, -1, {get_random_coord(size), get_random_coord(size)})
            )

          socket
          |> assign(
            loading: false,
            status: new_matrix,
            players: all_players,
            current_user: uuid,
            next_player: next_player
          )

        false ->
          socket
          |> assign(loading: true, status: nil, players: [], next_player: "", current_user: nil)
      end

    {:ok, socket |> assign(message: nil)}
  end
end
