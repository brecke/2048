defmodule GameWeb.SlidersTest do
  alias MatrixReloaded.Matrix
  alias GameWeb.Sliding
  use ExUnit.Case, async: true

  test "slide a whole board leftwards" do
    slided = Matrix.diag([1, 2, 3, 4, 5]) |> Result.and_then(&Sliding.slide(&1, "left"))

    assert slided == [
             [1, 0, 0, 0, 0],
             [2, 0, 0, 0, 0],
             [3, 0, 0, 0, 0],
             [4, 0, 0, 0, 0],
             [5, 0, 0, 0, 0]
           ]

    # matrix full of 2s
    slided = Matrix.new(5, 2) |> Result.and_then(&Sliding.slide(&1, "left"))

    assert slided == [
             [4, 4, 2, 0, 0],
             [4, 4, 2, 0, 0],
             [4, 4, 2, 0, 0],
             [4, 4, 2, 0, 0],
             [4, 4, 2, 0, 0]
           ]

    # randomly generated matrix
    slided =
      [
        [0, 1, 0, 1, 2],
        [0, 2, 0, 2, 2],
        [0, 0, 0, 1, 2],
        [0, 0, 2, 1, 2],
        [0, 1, 1, 1, 0]
      ]
      |> Sliding.slide("left")

    assert slided == [
             [2, 2, 0, 0, 0],
             [4, 2, 0, 0, 0],
             [1, 2, 0, 0, 0],
             [2, 1, 2, 0, 0],
             [2, 1, 0, 0, 0]
           ]
  end

  test "slide a whole board rightwards" do
    slided = Matrix.diag([1, 2, 3, 4, 5]) |> Result.and_then(&Sliding.slide(&1, "right"))

    assert slided == [
             [0, 0, 0, 0, 1],
             [0, 0, 0, 0, 2],
             [0, 0, 0, 0, 3],
             [0, 0, 0, 0, 4],
             [0, 0, 0, 0, 5]
           ]

    # matrix full of 2s
    slided = Matrix.new(5, 2) |> Result.and_then(&Sliding.slide(&1, "right"))

    assert slided == [
             [0, 0, 2, 4, 4],
             [0, 0, 2, 4, 4],
             [0, 0, 2, 4, 4],
             [0, 0, 2, 4, 4],
             [0, 0, 2, 4, 4]
           ]

    # randomly generated matrix
    slided =
      [
        [0, 1, 0, 1, 2],
        [0, 2, 0, 2, 2],
        [0, 0, 0, 1, 2],
        [0, 0, 2, 1, 2],
        [0, 1, 1, 1, 0]
      ]
      |> Sliding.slide("right")

    assert slided == [
             [0, 0, 0, 2, 2],
             [0, 0, 0, 2, 4],
             [0, 0, 0, 1, 2],
             [0, 0, 2, 1, 2],
             [0, 0, 0, 1, 2]
           ]
  end

  test "slide a whole board upwards" do
    slided = Matrix.diag([1, 2, 3, 4, 5]) |> Result.and_then(&Sliding.slide(&1, "up"))

    assert slided == [
             [1, 2, 3, 4, 5],
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0]
           ]

    # matrix full of 2s
    slided = Matrix.new(5, 2) |> Result.and_then(&Sliding.slide(&1, "up"))

    assert slided == [
             [4, 4, 4, 4, 4],
             [4, 4, 4, 4, 4],
             [2, 2, 2, 2, 2],
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0]
           ]

    # randomly generated matrix
    slided =
      [
        [0, 1, 0, 1, 2],
        [0, 2, 0, 2, 2],
        [0, 0, 0, 1, 2],
        [0, 0, 2, 1, 2],
        [0, 1, 1, 1, 0]
      ]
      |> Sliding.slide("up")

    assert slided == [
             [0, 1, 2, 1, 4],
             [0, 2, 1, 2, 4],
             [0, 1, 0, 2, 0],
             [0, 0, 0, 1, 0],
             [0, 0, 0, 0, 0]
           ]
  end

  test "slide a whole board downwards" do
    slided = Matrix.diag([1, 2, 3, 4, 5]) |> Result.and_then(&Sliding.slide(&1, "down"))

    assert slided == [
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0],
             [1, 2, 3, 4, 5]
           ]

    # matrix full of 2s
    slided = Matrix.new(5, 2) |> Result.and_then(&Sliding.slide(&1, "down"))

    assert slided == [
             [0, 0, 0, 0, 0],
             [0, 0, 0, 0, 0],
             [2, 2, 2, 2, 2],
             [4, 4, 4, 4, 4],
             [4, 4, 4, 4, 4]
           ]

    # randomly generated matrix
    slided =
      [
        [0, 1, 0, 1, 2],
        [0, 2, 0, 2, 2],
        [0, 0, 0, 1, 2],
        [0, 0, 2, 1, 2],
        [0, 1, 1, 1, 0]
      ]
      |> Sliding.slide("down")

    assert slided == [
             [0, 0, 0, 0, 0],
             [0, 0, 0, 1, 0],
             [0, 1, 0, 2, 0],
             [0, 2, 2, 1, 4],
             [0, 1, 1, 2, 4]
           ]
  end
end
