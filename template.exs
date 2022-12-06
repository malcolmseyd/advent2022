Code.require_file("../advent.exs")

defmodule Main do
  @day 6

  def solve(i) do
    Advent.input(@day)
    |> part(i)
    |> IO.inspect()
  end

  def part(input, 1) do
    input
    # |> tap(&IO.inspect(&1))
  end
end

Main.solve(1)
Main.solve(2)
IO.puts("done.")
