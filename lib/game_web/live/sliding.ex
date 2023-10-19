defmodule GameWeb.Sliding do
  require IEx
  alias MatrixReloaded.Matrix

  @doc """
  Single API for the sliding module
  """
  def slide(matrix, direction) do
    size = matrix |> length()

    case direction do
      "left" ->
        matrix
        |> slide_sideways(
          &shift_left(&1, size),
          &clear_left_padding/1
        )

      "right" ->
        matrix
        |> slide_sideways(
          &shift_right(&1, size),
          &clear_right_padding/1
        )

      "up" ->
        matrix
        |> slide_vertically(
          &shift_left(&1, size),
          &clear_left_padding/1
        )

      "down" ->
        matrix
        |> slide_vertically(
          &shift_right(&1, size),
          &clear_right_padding/1
        )
    end
  end

  # defp remove_zeros(row), do: row |> Enum.reject(&(&1 == 0))

  defp to_array(x), do: [x]

  defp generate_empty_column(size), do: List.duplicate(0, size) |> Enum.map(&to_array/1)

  defp slide_sideways(matrix, shift_to_fn, clear_padding_fn) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {each_row, row_index} ->
      case Matrix.update_row(
             matrix,
             each_row
             |> clear_padding_fn.()
             |> shift_to_fn.(),
             {row_index, 0}
           )
           |> Result.and_then(&Matrix.get_row(&1, row_index)) do
        {:ok, new_row} -> new_row
        {:error, :reason} -> each_row
      end
    end)
  end

  defp slide_vertically(matrix, shift_to_fn, clear_padding_fn) do
    List.duplicate(nil, length(matrix))
    |> Enum.with_index()
    |> Enum.reduce(generate_empty_column(length(matrix)), fn {_, col_index}, acc ->
      {:ok, each_col} = Matrix.get_col(matrix, col_index)

      slided_col =
        each_col
        |> List.flatten()
        |> clear_padding_fn.()
        |> shift_to_fn.()
        |> Enum.map(&to_array/1)

      case col_index do
        0 ->
          slided_col

        _ ->
          {:ok, result} = Matrix.concat_row(acc, slided_col)
          result
      end
    end)
  end

  defp pad_right_with_zeros(list, up_to_size) do
    Enum.concat(list, List.duplicate(0, up_to_size - length(list)))
  end

  defp shift_left(row, size), do: row |> shift_row() |> pad_right_with_zeros(size)

  defp shift_right(row, size),
    do: row |> Enum.reverse() |> shift_left(size) |> Enum.reverse()

  defp shift_row([], acc), do: acc
  defp shift_row(row, acc) when length(row) == 1, do: acc ++ row

  defp shift_row(row, acc \\ []) when length(row) >= 2 do
    heads = row |> Enum.take(2)
    rest = row |> Enum.drop(2)

    case heads do
      [0, tail] ->
        shift_row([tail] ++ rest, acc)

      [head, 0] ->
        shift_row([head] ++ rest, acc)

      [head, tail] ->
        cond do
          head > 0 && head == tail -> shift_row(rest, acc ++ [head + tail])
          true -> shift_row([tail] ++ rest, acc ++ [head])
        end
    end
  end

  defp clear_right_padding(row) do
    row
    |> Enum.reverse()
    |> Enum.drop_while(&(&1 == 0))
    |> Enum.reverse()
  end

  defp clear_left_padding(row), do: row |> Enum.drop_while(&(&1 == 0))
end
