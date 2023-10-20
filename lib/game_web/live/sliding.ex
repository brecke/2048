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
          &shift_left/2,
          &clear_left_padding/1
        )

      "right" ->
        matrix
        |> slide_sideways(
          &shift_right/2,
          &clear_right_padding/1
        )

      "up" ->
        matrix
        |> slide_vertically(
          &shift_left/2,
          &clear_left_padding/1
        )

      "down" ->
        matrix
        |> slide_vertically(
          &shift_right/2,
          &clear_right_padding/1
        )
    end
  end

  defp group_values([]) do
    []
  end

  defp group_values([head | tail]) do
    group_values([head | tail], [], [])
  end

  defp group_values([-1 | tail], current_group, result) do
    group_values(tail, [], result ++ [Enum.reverse(current_group)] ++ [-1])
  end

  defp group_values([head | tail], current_group, result) do
    group_values(tail, [head | current_group], result)
  end

  defp group_values([], current_group, result) do
    result ++ [Enum.reverse(current_group)]
  end

  # defp remove_zeros(row), do: row |> Enum.reject(&(&1 == 0))

  defp to_array(x), do: [x]

  defp generate_empty_column(size), do: List.duplicate(0, size) |> Enum.map(&to_array/1)

  defp slide_sideways(matrix, shift_to_fn, clear_padding_fn) do
    matrix
    |> Enum.with_index()
    |> Enum.map(fn {each_row, row_index} ->
      slided_row =
        each_row
        |> group_values()
        |> Enum.reject(&(&1 == []))
        |> Enum.map(fn each_element ->
          case is_list(each_element) do
            true ->
              each_element |> clear_padding_fn.() |> shift_to_fn.(length(each_element))

            false ->
              each_element
          end
        end)
        |> List.flatten()

      case Matrix.update_row(
             matrix,
             slided_row,
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
        |> group_values()
        |> Enum.reject(&(&1 == []))
        |> Enum.map(fn each_subcolumn ->
          case is_list(each_subcolumn) do
            true ->
              each_subcolumn
              |> clear_padding_fn.()
              |> shift_to_fn.(length(each_subcolumn))

            false ->
              each_subcolumn
          end
        end)
        |> List.flatten()
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
