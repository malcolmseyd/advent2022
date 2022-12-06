Code.eval_file("../advent.exs")

day = 6

defmodule B do
  def solve(input) do
    data =
      input
      |> String.trim()
      |> to_charlist()
      |> Enum.chunk_every(14, 1)
      |> Enum.with_index()
      |> find_marker()

    # |> tap(&IO.inspect(&1))

    data
  end

  def find_marker([]) do
    throw("Couldn't find code")
  end

  def find_marker([{chunk, i} | rest]) do
    letters = MapSet.new(chunk)

    if length(chunk) == MapSet.size(letters) do
      i + 14
    else
      find_marker(rest)
    end
  end
end

defmodule A do
  def solve(input) do
    data =
      input
      |> String.trim()
      |> to_charlist()
      |> Enum.chunk_every(4, 1)
      |> Enum.with_index()
      |> find_marker()

    # |> tap(&IO.inspect(&1))

    data
  end

  def find_marker([]) do
    throw("Couldn't find code")
  end

  def find_marker([{chunk, i} | rest]) do
    letters = MapSet.new(chunk)

    if length(chunk) == MapSet.size(letters) do
      i + 4
    else
      find_marker(rest)
    end
  end
end

Advent.input(day)
|> B.solve()
|> IO.inspect()

# Advent.uncache(day)

IO.puts("done.")
