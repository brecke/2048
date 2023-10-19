defmodule GameWeb.Sliding do
  require IEx
  alias MatrixReloaded.Matrix

  def slide_left(matrix) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {each_row, row_index} ->
      result =
        Matrix.update_row(
          matrix,
          each_row |> clear_left_padding() |> shift_left(),
          {row_index, 0}
        )

      {:ok, matrix} = result
      {:ok, new_row} = Matrix.get_row(matrix, row_index)
      new_row
    end)
  end

  def slide_up(matrix) do
    List.duplicate(nil, 6)
    |> Enum.with_index()
    |> Enum.reduce([[0], [0], [0], [0], [0], [0]], fn {_, col_index}, acc ->
      {:ok, each_col} = Matrix.get_col(matrix, col_index)

      slided_col =
        each_col
        |> List.flatten()
        |> clear_left_padding()
        |> shift_left()
        |> Enum.map(fn x -> [x] end)

      case col_index do
        0 ->
          slided_col

        _ ->
          {:ok, result} = Matrix.concat_row(acc, slided_col)
          result
      end
    end)
  end

  defp shift_left([], acc) do
    acc |> fill_with_nils()
  end

  defp fill_with_nils(list) do
    desired_length = 6
    Enum.concat(list, List.duplicate(0, desired_length - length(list)))
  end

  defp shift_left(row, acc) when length(row) == 1 do
    (acc ++ row) |> fill_with_nils()
  end

  defp shift_left(row, acc \\ []) when length(row) >= 2 do
    heads = row |> Enum.take(2)
    rest = row |> Enum.drop(2)

    case heads do
      [0, tail] ->
        shift_left([tail] ++ rest, acc)

      [head, tail] ->
        cond do
          head > 0 && head == tail -> shift_left(rest, acc ++ [head + tail])
          true -> shift_left([tail] ++ rest, acc ++ [head])
        end
    end
  end

  defp clear_left_padding(row) do
    row |> Enum.drop_while(fn x -> x == 0 end)
  end
end
