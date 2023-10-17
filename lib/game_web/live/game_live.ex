defmodule GameWeb.GameLive do
  use GameWeb, :live_view

  require IEx

  defp generate_array(rows, columns)
       when is_integer(rows) and is_integer(columns) and rows > 0 and columns > 0 do
    # Create a row filled with nil values
    row = :lists.duplicate(columns, nil)

    # Create a list of rows to form the 2D array
    array = :lists.duplicate(rows, row)

    array
  end

  # Update the value at a specific (x, y) coordinate in a 2D array
  def update_element(array, x, y, new_value) when is_list(array) and x >= 0 and y >= 0 do
    update_element(array, x, y, new_value, 0)
  end

  # Helper function with row index
  defp update_element([], _, _, _, _), do: []

  defp update_element([row | rest], x, y, new_value, row_index) when row_index == y do
    [update_row(row, x, new_value) | rest]
  end

  defp update_element([row | rest], x, y, new_value, row_index) do
    [row | update_element(rest, x, y, new_value, row_index + 1)]
  end

  # Helper function to update an element in a row
  defp update_row([], _, _), do: []

  defp update_row([_ | rest], 0, new_value), do: [new_value | rest]

  defp update_row([cell | rest], x, new_value) when x > 0 do
    [cell | update_row(rest, x - 1, new_value)]
  end

  def mount(_params, _session, socket) do
    status = generate_array(6, 6)
    x = :rand.uniform(5)
    y = :rand.uniform(5)
    status = status |> update_element(x, y, 2)

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

    {:ok, socket}
  end
end
