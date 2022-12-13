Code.require_file("advent.exs")

defmodule Main do
  @day 13

  def solve() do
    packets =
      Advent.input(@day)
      |> String.trim()
      |> String.split("\n\n")
      |> Enum.map(fn pair ->
        pair
        |> String.split()
        |> Enum.map(fn x ->
          # quick and dirty, trusted input
          {x, []} = Code.eval_string(x)
          x
        end)
      end)

    # part 1
    packets
    |> Enum.map(&compare(&1))
    |> Enum.with_index(1)
    |> Enum.filter(fn {ord, _} -> ord == :less end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.sum()
    |> tap(&IO.inspect(&1))

    # part 2
    (packets ++ [[[[2]]], [[[6]]]])
    |> Enum.flat_map(fn x -> x end)
    |> Enum.sort(&(compare([&1, &2]) == :less))
    |> Enum.with_index(1)
    |> Enum.filter(fn {packet, _} -> packet == [[2]] or packet == [[6]] end)
    |> Enum.map(fn {_, i} -> i end)
    |> Enum.product()
    |> tap(&IO.inspect(&1))
  end

  # both lists case
  def compare([[], []]), do: :equal
  def compare([[], _second]), do: :less
  def compare([_first, []]), do: :greater

  def compare([[first | first_rest], [second | second_rest]]) do
    case compare([first, second]) do
      :equal -> compare([first_rest, second_rest])
      x -> x
    end
  end

  # one is list, one is number
  def compare([[first | first_rest], second]) when is_number(second) do
    compare([[first | first_rest], [second]])
  end

  def compare([first, [second | second_rest]]) when is_number(first) do
    compare([[first], [second | second_rest]])
  end

  # both numbers case
  def compare([first, second]) do
    cond do
      first < second -> :less
      first > second -> :greater
      first == second -> :equal
    end
  end
end

Main.solve()
IO.puts("done.")
