Code.require_file("../advent.exs")

defmodule Day6 do
  @day 6

  def solve(i) do
    Advent.input(@day)
    |> part(i)
    |> IO.inspect()
  end

  def part(input, 1) do
    solve(input, 4)
  end

  def part(input, 2) do
    solve(input, 14)
  end

  def solve(input, k) do
    {_, i} =
      input
      |> String.trim()
      |> to_charlist()
      |> Enum.chunk_every(k, 1)
      |> Enum.with_index()
      |> Enum.find(fn {chunk, _} ->
        length(chunk) == chunk |> MapSet.new() |> MapSet.size()
      end)

    # |> tap(&IO.inspect(&1))

    i + k
  end
end

Day6.solve(1)
Day6.solve(2)
IO.puts("done.")
