defmodule GameWeb.GameLive do
  alias GameWeb.MatrixUtils
  use GameWeb, :live_view

  alias MatrixReloaded.Matrix
  require IEx

  defp has_won?(socket) do
    %{status: matrix} = socket.assigns

    victorious_coords =
      for {row, row_index} <- Enum.with_index(matrix),
          {value, column_index} <- Enum.with_index(row),
          value == 2048,
          do: {row_index, column_index}

    if length(victorious_coords) > 0 do
      socket |> assign(message: "You have won the match!!")
    else
      socket
    end
  end

  defp recalculate_score(socket) do
    %{status: matrix} = socket.assigns

    default_to_zero = fn each -> each || 0 end

    score =
      Enum.reduce(matrix, 0, fn each_row, acc ->
        cols_sum =
          Enum.reduce(each_row, 0, fn each_value, acc ->
            acc + default_to_zero.(each_value)
          end)

        acc + cols_sum
      end)

    socket =
      cond do
        score == 2048 -> socket |> assign(message: "You have won the match!!")
        score > 2048 -> socket |> assign(message: "Ooops! You have gone over 2048 :(")
        true -> socket
      end

    socket |> assign(score: score)
  end

  def handle_event("handle_key_press", %{"key" => "ArrowLeft"}, socket) do
    IO.inspect("left!")

    socket = socket |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowRight"}, socket) do
    IO.inspect("right!")

    socket = socket |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowUp"}, socket) do
    IO.inspect("up!")

    socket = socket |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowDown"}, socket) do
    IO.inspect("down!")

    socket = socket |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", _params, socket) do
    {:noreply, socket}
  end

  defp find_nil_coordinates(matrix) do
    for {row, row_index} <- Enum.with_index(matrix),
        {value, column_index} <- Enum.with_index(row),
        value == nil,
        do: {row_index, column_index}
  end

  # Get a random nil coordinate
  def random_nil_coordinate(matrix) when is_list(matrix) do
    nil_coordinates = find_nil_coordinates(matrix)

    # debug
    IO.puts("Found #{nil_coordinates |> length()} nil coordinates")

    if length(nil_coordinates) > 0 do
      Enum.random(nil_coordinates)
    else
      nil
    end
  end

  defp fill_spot(matrix, x, y) do
    # matrix |> IO.inspect()
    # {:ok, result} = Matrix.get_element(matrix, {x, y})
    # IO.puts("Previous: (#{x},#{y}) => #{result || "null"}")

    # {:ok, new_matrix} = 
    matrix |> Matrix.update_element(1, {x, y})

    # new_matrix |> IO.inspect()
    # {:ok, result} = Matrix.get_element(new_matrix, {x, y})
    # IO.puts("Current: (#{x},#{y}) => #{result}")
  end

  defp uncover_new_tile(socket) do
    %{status: matrix} = socket.assigns

    case random_nil_coordinate(matrix) do
      nil ->
        socket |> assign(message: "Sorry you've lost the game, reload window to play again!")

      # show alert maybe?
      {row, col} ->
        {:ok, new_matrix} = fill_spot(matrix, row, col)
        socket |> assign(status: new_matrix)
    end
  end

  def mount(_params, _session, socket) do
    matrix = Matrix.new(6, nil)
    x = :rand.uniform(6) - 1
    y = :rand.uniform(6) - 1

    {:ok, status} = matrix |> Result.and_then(&Matrix.update_element(&1, 2, {x, y}))

    status |> IO.inspect()

    socket =
      case connected?(socket) do
        true ->
          socket
          |> assign(loading: false, status: status)

        false ->
          socket
          |> assign(loading: true, status: nil)
      end

    {:ok, socket |> assign(message: nil)}
  end
end
