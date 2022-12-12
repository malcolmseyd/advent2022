# Lessons learned:
# - Functional programming isn't as suited to quick and dirty prototyping as
#   Python. I really struggled with Elixir while I tried to figure out what
#   algorithm I should be using, and then how to implement it in a purely
#   functional fashion. I ended up writing my first solution in Python (yeah
#   yeah, I know) because it seemed so much easier. I guess today was my cheat
#   day. But after I knew what I wanted to code, the Elixir solution came
#   together in no time. I guess what I learned today is that being very explicit about state isn't really helpful when the program is rapidly changing, and it more hinders progress than helps it (that being said, most practical environments benefit from being explicit about state)
# - I LOVE DBG(). Another day of it helping be debug much better than IO.inspect :)

Code.require_file("advent.exs")

defmodule Main do
  @day 12

  def solve(part) do
    input =
      Advent.input(@day)
      |> String.trim_trailing()
      |> String.split("\n")
      |> Enum.map(&to_charlist(&1))

    height_map =
      input
      |> Enum.with_index()
      |> Enum.map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          {{x, y}, char}
        end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    start_pos =
      height_map
      |> Enum.find_value(fn {pos, char} -> if char == ?S, do: pos end)

    end_pos =
      height_map
      |> Enum.find_value(fn {pos, char} -> if char == ?E, do: pos end)

    height_map =
      height_map
      |> Map.put(start_pos, ?a)
      |> Map.put(end_pos, ?z)

    visited = bfs(height_map, end_pos)

    case part do
      1 ->
        IO.inspect(Map.get(visited, start_pos))

      2 ->
        Map.keys(visited)
        |> Enum.filter(fn pos -> Map.get(height_map, pos) == ?a end)
        |> Enum.map(fn pos -> Map.get(visited, pos) end)
        |> Enum.min()
        |> IO.inspect()
    end
  end

  def bfs(height_map, start) do
    visited = %{start => 0}
    seen = :queue.from_list([start])

    iter_bfs(height_map, {visited, seen})
  end

  def iter_bfs(height_map, {visited, seen}) do
    case :queue.out(seen) do
      {:empty, _seen} ->
        visited

      {{:value, pos}, seen} ->
        dist = Map.get(visited, pos)

        {visited, seen} =
          neighbours(height_map, pos)
          |> Enum.filter(fn n -> not Map.has_key?(visited, n) end)
          |> Enum.reduce({visited, seen}, fn n, {visited, seen} ->
            visited = Map.put(visited, n, dist + 1)
            seen = :queue.in(n, seen)
            {visited, seen}
          end)

        iter_bfs(height_map, {visited, seen})
    end
  end

  def neighbours(height_map, from) do
    {x, y} = from

    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y}
    ]
    |> Enum.filter(fn to ->
      if Map.has_key?(height_map, to) do
        from = Map.get(height_map, from)
        to = Map.get(height_map, to)
        # since we start at the top and go down
        # don't decrease by more than 1
        from - to <= 1
      else
        false
      end
    end)
  end
end

Main.solve(1)
Main.solve(2)
IO.puts("done.")
