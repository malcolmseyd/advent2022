Code.eval_file("../advent.exs")

day = :CHANGE_ME

defmodule A do
  def solve(input) do
    data =
      input
      |> String.trim()
      |> String.split("\n")

    # |> tap(&IO.inspect(&1))

    data
  end
end

Advent.input(day)
|> A.solve()
|> IO.inspect()

# Advent.uncache(day)

IO.puts("done.")

