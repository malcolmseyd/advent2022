Code.require_file("advent.exs")

defmodule Main do
  @day 14

  @sand_spawn {500, 0}

  def solve() do
    walls =
      Advent.input(@day)
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> String.split(" -> ")
        |> Enum.map(&parse_coords(&1))
      end)

    # populate cave with walls
    cave =
      walls
      |> Enum.reduce(MapSet.new(), fn path, cave ->
        # add each wall from a path
        path
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.reduce(cave, fn [a, b], cave ->
          # draw line from a to b
          line(a, b)
          |> Enum.reduce(cave, fn point, cave ->
            # add each point in the line to our cave
            MapSet.put(cave, point)
          end)
        end)
      end)

    # the y of the lowest wall
    {_, bottom} =
      cave
      |> Enum.max_by(fn {_x, y} -> y end)

    # part 1
    # drop sand until it reaches bottom (falls forever)
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(cave, fn n, cave ->
      # drop a single grain of sand and watch it fall
      # keep falling until it's at rest

      case drop(cave, bottom) do
        # halt with number of grains dropped before one falls into the abyss
        :halt ->
          {:halt, n - 1}

        sand ->
          # add sand to cave as a solid point
          cave = MapSet.put(cave, sand)
          {:cont, cave}
      end
    end)
    |> tap(&IO.inspect(&1))

    floor = bottom + 2

    # drop sand until it reaches bottom (falls forever)
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(cave, fn n, cave ->
      # drop a single grain of sand and watch it fall
      # keep falling until it's at rest

      case drop_floor(cave, floor) do
        # sand rests at spawn position
        @sand_spawn ->
          # zero indexed
          {:halt, n}

        sand ->
          # add sand to cave as a solid point
          cave = MapSet.put(cave, sand)
          {:cont, cave}
      end
    end)
    |> tap(&IO.inspect(&1))
  end

  # sand falls until it becomes solid or hits floor
  def drop_floor(cave, floor, sand \\ @sand_spawn) do
    # let sand fall until it reaches the bottom or rest
    case fall(sand, cave) do
      # fell inside floor, rest at old position
      {:move, {_x, y}} when y == floor ->
        sand

      # sand falling
      {:move, sand} ->
        drop_floor(cave, floor, sand)

      # sand stopped, return new point
      :rest ->
        sand
    end
  end

  # sand falls until it becomes solid or goes into abyss
  def drop(cave, bottom, sand \\ @sand_spawn) do
    # let sand fall until it reaches the bottom or rest
    case fall(sand, cave) do
      # reached bottom, sand fell into abyss
      {:move, {_x, y}} when y >= bottom ->
        :halt

      # sand falling
      {:move, sand} ->
        drop(cave, bottom, sand)

      # sand stopped, return new point
      :rest ->
        sand
    end
  end

  def fall(sand, cave) do
    {x, y} = sand

    # x means right, y means down
    # movement:
    cond do
      # 1. down
      not MapSet.member?(cave, {x, y + 1}) ->
        {:move, {x, y + 1}}

      # 2. down-left
      not MapSet.member?(cave, {x - 1, y + 1}) ->
        {:move, {x - 1, y + 1}}

      # 3. down-right
      not MapSet.member?(cave, {x + 1, y + 1}) ->
        {:move, {x + 1, y + 1}}

      # 4. at rest
      true ->
        :rest
    end
  end

  # walls are straight lines from prev point to next point
  def line({ax, ay}, {bx, by}) when ax == bx do
    ay..by
    |> Enum.map(fn y ->
      {ax, y}
    end)
  end

  def line({ax, ay}, {bx, by}) when ay == by do
    ax..bx
    |> Enum.map(fn x ->
      {x, ay}
    end)
  end

  def parse_coords(text) do
    [x, y] =
      text
      |> String.split(",")
      |> Enum.map(&String.to_integer(&1))

    {x, y}
  end
end

Main.solve()
IO.puts("done.")
