defmodule GameWeb.GameLive do
  use GameWeb, :live_view

  alias GameWeb.Sliding
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

  """
      rest
      |> List.insert_at(length(rest), nil)
      |> Enum.with_index()
      |> Enum.reduce([], fn {each, index}, acc ->
        previous = Enum.at(rest, index - 1, 0)

        case index > 0 && each == previous do
          true -> acc ++ [nil]
          false -> acc ++ [each]
        end

        next = Enum.at(rest, index + 1, 0)

        case index < length(rest) && each == next do
          true -> acc ++ [each + next]
          false -> acc ++ [each]
        end
      end)
  """

  defp move_left(socket) do
    %{status: matrix} = socket.assigns

    new_matrix =
      matrix
      |> Enum.with_index()
      |> Enum.map(fn {each_row, row_index} ->
        result =
          Matrix.update_row(
            matrix,
            each_row |> Sliding.clear_left_padding() |> Sliding.left_slide(),
            {row_index, 0}
          )

        {:ok, matrix} = result
        {:ok, new_row} = Matrix.get_row(matrix, row_index)
        new_row
      end)

    new_matrix |> IO.inspect()

    socket |> assign(status: new_matrix)
  end

  defp move_up(socket) do
    %{status: matrix} = socket.assigns

    new_matrix =
      List.duplicate(nil, 6)
      |> Enum.with_index()
      |> Enum.reduce([[0], [0], [0], [0], [0], [0]], fn {_, col_index}, acc ->
        {:ok, each_col} = Matrix.get_col(matrix, col_index)

        slided_col =
          each_col
          |> List.flatten()
          |> Sliding.clear_left_padding()
          |> Sliding.left_slide()
          |> Enum.map(fn x -> [x] end)

        case col_index do
          0 ->
            slided_col

          _ ->
            {:ok, result} = Matrix.concat_row(acc, slided_col)
            result
        end
      end)

    new_matrix |> IO.inspect()

    socket |> assign(status: new_matrix)
  end

  def handle_event("handle_key_press", %{"key" => "ArrowLeft"}, socket) do
    IO.inspect("left!")

    socket = socket |> move_left() |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowRight"}, socket) do
    IO.inspect("right!")

    socket = socket |> uncover_new_tile() |> has_won?()
    {:noreply, socket}
  end

  def handle_event("handle_key_press", %{"key" => "ArrowUp"}, socket) do
    IO.inspect("up!")

    socket = socket |> move_up() |> uncover_new_tile() |> has_won?()
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
        value == 0,
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

  defp fill_spot(matrix, x, y), do: matrix |> Matrix.update_element(1, {x, y})

  defp uncover_new_tile(socket) do
    %{status: matrix} = socket.assigns

    case random_nil_coordinate(matrix) do
      nil ->
        socket |> assign(message: "Sorry you've lost the game, reload window to play again!")

      {row, col} ->
        {:ok, new_matrix} = fill_spot(matrix, row, col)
        socket |> assign(status: new_matrix)
    end
  end

  def mount(_params, _session, socket) do
    matrix = Matrix.new(6, 0)
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
