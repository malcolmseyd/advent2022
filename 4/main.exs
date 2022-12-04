Code.eval_file("../advent.exs")

day = 4

defmodule A do
  def solve(input) do
    data =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn x ->
        [[a, b], [c, d]] =
          x
          |> String.split(",")
          |> Enum.map(fn y ->
            y
            |> String.split("-")
            |> Enum.map(fn z ->
              {i, ""} = Integer.parse(z)
              i
            end)
          end)

        if (a <= c and b >= d) or (a >= c and b <= d) do
          1
        else
          0
        end
      end)
      |> Enum.sum()

    # |> tap(&IO.inspect(&1))

    data
  end
end

defmodule B do
  def solve(input) do
    data =
      input
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn x ->
        [[a, b], [c, d]] =
          x
          |> String.split(",")
          |> Enum.map(fn y ->
            y
            |> String.split("-")
            |> Enum.map(fn z ->
              {i, ""} = Integer.parse(z)
              i
            end)
          end)

        if a > d or b < c do
          0
        else
          1
        end
      end)
      |> Enum.sum()

    # |> tap(&IO.inspect(&1))

    data
  end
end

Advent.input(day)
|> B.solve()
|> IO.inspect()

# Advent.uncache(day)

IO.puts("done.")
