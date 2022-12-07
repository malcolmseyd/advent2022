# lessons learned:
# - dynamic programming IS possible to do in a purely functional way. i was
#   occasionally tempted to use an Agent but i stayed away, and i'm glad i
#   did. all it took was a reduce and i was good to go

Code.require_file("advent.exs")

defmodule Main do
  @day 7

  def solve(i) do
    Advent.input(@day)
    |> String.trim_trailing("\n")
    |> String.split("\n")
    |> parse()
    |> normalize_tree()
    |> part(i)
    |> IO.inspect()
  end

  def part(entries, 1) do
    entries
    |> Map.values()
    |> Enum.filter(fn {type, _} -> type == :dir end)
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.filter(&(&1 <= 100_000))
    |> Enum.sum()

    # |> tap(&IO.inspect(&1))
  end

  def part(entries, 2) do
    {:dir, total_used} = Map.get(entries, ["/"])
    max_used = 70_000_000 - 30_000_000
    smallest_dir = total_used - max_used

    entries
    |> Map.values()
    |> Enum.filter(fn {type, _} -> type == :dir end)
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.filter(&(&1 >= smallest_dir))
    |> Enum.min()

    # |> tap(&IO.inspect(&1))
  end

  def normalize_tree(entries, path \\ ["/"]) do
    # i smell dynamic programming
    case Map.get(entries, path) do
      {:file, value} ->
        # already normalized
        entries

      {:dir, value} when is_number(value) ->
        # already normalized
        entries

      {:dir, children} ->
        # normalize every child to a value

        entries =
          Enum.reduce(children, entries, fn path, entries ->
            normalize_tree(entries, path)
          end)

        sum =
          children
          |> Enum.map(fn path -> Map.get(entries, path) end)
          |> Enum.map(fn {_, value} -> value end)
          |> Enum.sum()

        Map.put(entries, path, {:dir, sum})
    end
  end

  def parse(input, path \\ [], entries \\ %{})

  def parse([], _, entries) do
    entries
  end

  def parse(["$ ls" | input], path, entries) do
    # no-op since we can parse for listings anyways
    parse(input, path, entries)
  end

  def parse(["$ cd .." | input], path, entries) do
    up = Enum.drop(path, -1)
    parse(input, up, entries)
  end

  def parse([<<"$ cd ", dir::binary>> | input], path, entries) do
    down = path ++ [dir]
    parse(input, down, entries)
  end

  def parse([<<"dir ", dir::binary>> | input], path, entries) do
    new_path = path ++ [dir]

    entries =
      entries
      # add dir entry
      |> Map.update(
        path,
        {:dir, MapSet.new([new_path])},
        fn {:dir, dir_entries} ->
          {:dir, MapSet.put(dir_entries, new_path)}
        end
      )

    parse(input, path, entries)
  end

  def parse([line | input], path, entries) do
    [size_str, file] = String.split(line, " ")
    {size, ""} = Integer.parse(size_str)

    new_path = path ++ [file]

    entries =
      entries
      # add dir entry
      |> Map.update(
        path,
        {:dir, MapSet.new([new_path])},
        fn {:dir, dir_entries} ->
          {:dir, MapSet.put(dir_entries, new_path)}
        end
      )
      # add file entry
      |> Map.put(new_path, {:file, size})

    parse(input, path, entries)
  end
end

Main.solve(1)
Main.solve(2)
IO.puts("done.")
