defmodule GameWeb.MatrixUtils do
  @moduledoc """
  Matrix manipulation utilities
  """
  alias MatrixReloaded.Matrix

  def find_victorious_coords(matrix) do
    for {row, row_index} <- Enum.with_index(matrix),
        {value, column_index} <- Enum.with_index(row),
        value == 2048,
        do: {row_index, column_index}
  end

  defp find_nil_coordinates(matrix) do
    for {row, row_index} <- Enum.with_index(matrix),
        {value, column_index} <- Enum.with_index(row),
        value == 0,
        do: {row_index, column_index}
  end

  def random_nil_coordinate(matrix) when is_list(matrix) do
    nil_coordinates = matrix |> find_nil_coordinates()

    if length(nil_coordinates) > 0 do
      Enum.random(nil_coordinates)
    else
      nil
    end
  end

  def fill_spot(matrix, x, y), do: matrix |> Matrix.update_element(1, {x, y})
end
