defmodule GameWeb.GameLive do
  alias GameWeb.MatrixUtils
  use GameWeb, :live_view

  alias GameWeb.Sliding
  alias MatrixReloaded.Matrix
  require IEx

  defp has_won?(socket) do
    %{status: matrix} = socket.assigns

    victorious_coords = matrix |> MatrixUtils.find_victorious_coords()

    if length(victorious_coords) > 0 do
      socket |> assign(message: "You have won the match!!")
    else
      socket
    end
  end

  defp move_left(socket) do
    %{status: matrix} = socket.assigns
    socket |> assign(status: matrix |> Sliding.slide("left"))
  end

  defp move_right(socket) do
    %{status: matrix} = socket.assigns
    socket |> assign(status: matrix |> Sliding.slide("right"))
  end

  defp move_down(socket) do
    %{status: matrix} = socket.assigns
    socket |> assign(status: matrix |> Sliding.slide("down"))
  end

  defp move_up(socket) do
    %{status: matrix} = socket.assigns
    socket |> assign(status: matrix |> Sliding.slide("up"))
  end

  def handle_event("handle_key_press", %{"key" => "ArrowLeft"}, socket) do
    socket = socket |> move_left() |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowRight"}, socket) do
    socket = socket |> move_right() |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowUp"}, socket) do
    socket = socket |> move_up() |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowDown"}, socket) do
    socket = socket |> move_down() |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", _params, socket) do
    {:noreply, socket}
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

  def mount(params, _session, socket) do
    size = params |> Map.get("size", "6") |> String.to_integer()

    socket =
      case connected?(socket) do
        true ->
          matrix = Matrix.new(size, 0)
          x = :rand.uniform(size) - 1
          y = :rand.uniform(size) - 1
          {:ok, new_matrix} = matrix |> Result.and_then(&Matrix.update_element(&1, 2, {x, y}))

          socket
          |> assign(loading: false, status: new_matrix, size: new_matrix |> length())

        false ->
          socket
          |> assign(loading: true, status: nil, size: size)
      end

    {:ok, socket |> assign(message: nil)}
  end
end
