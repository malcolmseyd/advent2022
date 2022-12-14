defmodule A do
  def solve do
    elves =
      File.read!("input1.txt")
      |> String.split("\n\n")
      |> Enum.map(fn x ->
        x
        |> String.trim()
        |> String.split("\n")
        |> Enum.map(fn y ->
          {i, ""} = Integer.parse(y)
          i
        end)
        |> Enum.sum()
      end)

    elves
    |> Enum.reduce(&max(&1, &2))
  end
end

defmodule B do
  def solve do
    elves =
      File.read!("input1.txt")
      |> String.split("\n\n")
      |> Enum.map(fn x ->
        x
        |> String.trim()
        |> String.split("\n")
        |> Enum.map(fn y ->
          {i, ""} = Integer.parse(y)
          i
        end)
        |> Enum.sum()
      end)

    elves
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(3)
    |> Enum.sum()
  end
end

IO.inspect(A.solve())
IO.inspect(B.solve())

