defmodule GameWeb.Sliding do
  require IEx
  alias MatrixReloaded.Matrix

  defp slide_sideways(matrix, shift_to_fn, clear_padding_fn) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {each_row, row_index} ->
      case Matrix.update_row(
             matrix,
             each_row |> clear_padding_fn.() |> shift_to_fn.(),
             {row_index, 0}
           )
           |> Result.and_then(&Matrix.get_row(&1, row_index)) do
        {:ok, new_row} -> new_row
        {:error, :reason} -> each_row
      end
    end)
  end

  defp slide_vertically(matrix, shift_to_fn, clear_padding_fn) do
    List.duplicate(nil, 6)
    |> Enum.with_index()
    |> Enum.reduce([[0], [0], [0], [0], [0], [0]], fn {_, col_index}, acc ->
      {:ok, each_col} = Matrix.get_col(matrix, col_index)

      slided_col =
        each_col
        |> List.flatten()
        |> clear_padding_fn.()
        |> shift_to_fn.()
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

  def slide(matrix, direction) do
    case direction do
      "left" -> matrix |> slide_sideways(&shift_left/1, &clear_left_padding/1)
      "right" -> matrix |> slide_sideways(&shift_right/1, &clear_right_padding/1)
      "up" -> matrix |> slide_vertically(&shift_left/1, &clear_left_padding/1)
      "down" -> matrix |> slide_vertically(&shift_right/1, &clear_right_padding/1)
    end
  end

  defp pad_right_with_zeros(list) do
    desired_length = 6
    Enum.concat(list, List.duplicate(0, desired_length - length(list)))
  end

  defp shift_right(row) do
    row |> Enum.reverse() |> shift_left() |> Enum.reverse()
  end

  defp shift_left([], acc), do: acc |> pad_right_with_zeros()

  defp shift_left(row, acc) when length(row) == 1 do
    (acc ++ row) |> pad_right_with_zeros()
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

  defp clear_right_padding(row) do
    row
    |> Enum.reverse()
    |> Enum.drop_while(fn x -> x == 0 end)
    |> Enum.reverse()
  end

  defp clear_left_padding(row) do
    row |> Enum.drop_while(fn x -> x == 0 end)
  end
end
