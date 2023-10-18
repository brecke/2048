defmodule GameWeb.Sliding do
  require IEx

  def left_slide([], acc) do
    acc |> fill_with_nils()
  end

  defp fill_with_nils(list) do
    desired_length = 6
    Enum.concat(list, List.duplicate(0, desired_length - length(list)))
  end

  def left_slide(row, acc) when length(row) == 1 do
    (acc ++ row) |> fill_with_nils()
  end

  def left_slide(row, acc \\ []) when length(row) >= 2 do
    heads = row |> Enum.take(2)
    rest = row |> Enum.drop(2)

    case heads do
      [0, tail] ->
        left_slide([tail] ++ rest, acc)

      [head, tail] ->
        cond do
          head > 0 && head == tail -> left_slide(rest, acc ++ [head + tail])
          true -> left_slide([tail] ++ rest, acc ++ [head])
        end
    end
  end

  def clear_left_padding(row) do
    row |> Enum.drop_while(fn x -> x == 0 end)
  end
end
