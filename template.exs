Code.require_file("advent.exs")

defmodule Main do
  @day 0

  def solve() do
    Advent.input(@day)
    |> Strings.split("\n")
    # |> tap(&IO.inspect(&1))
  end

end

Main.solve()
IO.puts("done.")
