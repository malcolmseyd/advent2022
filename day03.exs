Code.eval_file("advent.exs")

day = 3

defmodule B do
  def solve(input) do
    data =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.chunk_every(3)
      |> Enum.map(fn [a, b, c] ->
        a_set = MapSet.new(to_charlist(a))
        b_set = MapSet.new(to_charlist(b))
        c_set = MapSet.new(to_charlist(c))

        [common] =
          a_set
          |> MapSet.intersection(b_set)
          |> MapSet.intersection(c_set)
          |> MapSet.to_list()

        common
        |> score()
      end)
      |> Enum.sum()

    # |> tap(&IO.inspect(&1))

    data
  end

  def score(c) do
    cond do
      c >= ?a and c <= ?z ->
        c - ?a + 1

      c >= ?A and c <= ?Z ->
        c - ?A + 26 + 1
    end
  end
end

defmodule A do
  def solve(input) do
    data =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn x ->
        len = div(String.length(x), 2)
        <<a::binary-size(len), b::binary-size(len)>> = x

        a_set = MapSet.new(to_charlist(a))
        b_set = MapSet.new(to_charlist(b))

        [common] =
          MapSet.intersection(a_set, b_set)
          |> MapSet.to_list()

        common
        |> score()
      end)
      |> Enum.sum()

    # |> tap(&IO.inspect(&1))

    data
  end

  def score(c) do
    cond do
      c >= ?a and c <= ?z ->
        c - ?a + 1

      c >= ?A and c <= ?Z ->
        c - ?A + 26 + 1
    end
  end
end


Advent.input(day)
|> A.solve()
|> IO.inspect()

Advent.input(day)
|> B.solve()
|> IO.inspect()

# Advent.uncache(day)

IO.puts("done.")
