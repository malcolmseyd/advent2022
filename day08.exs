# lessons learned
# - read and reread the spec. i had pretty much the right solution about 20 mins into
#   working on part 2, but spent two hours troubleshooting until i realized i was
#   doing a sum instead of multiplication

Code.require_file("advent.exs")

defmodule Main do
  @day 8

  def solve(i) do
    Advent.input(@day)
    |> String.trim_trailing()

    # """
    # 30373
    # 25512
    # 65332
    # 33549
    # 35390
    # """
    # |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> to_charlist()
      |> Enum.map(fn char ->
        char - ?0
      end)
    end)
    |> tap(&IO.inspect(&1))
    |> part(i)
  end

  def part(input, 1) do
    # find_visible from left, right, up, and down
    input =
      input
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        line
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          {x, y, char}
        end)
      end)

    visible = MapSet.new()

    # left
    visible =
      Enum.reduce(
        input,
        visible,
        fn line, visible ->
          find_visible(line, visible)
        end
      )

    # right (reverse row)
    visible =
      Enum.reduce(
        input,
        visible,
        fn line, visible ->
          find_visible(Enum.reverse(line), visible)
        end
      )

    # top (transpose)
    visible =
      Enum.reduce(
        transpose(input),
        visible,
        fn line, visible ->
          find_visible(line, visible)
        end
      )

    # bottom (transpose + reverse row)
    visible =
      Enum.reduce(
        transpose(input),
        visible,
        fn line, visible ->
          find_visible(Enum.reverse(line), visible)
        end
      )

    MapSet.size(visible)
    |> tap(&IO.inspect(&1))
  end

  def part(input, 2) do
    # the last strategy won't work
    # this time, we should just use indicies and check all 4 directions
    max_x = length(hd(input)) - 1
    max_y = length(input) - 1

    # for x <- 0..0, y <- 0..0 do
    for x <- 0..max_x, y <- 0..max_y do
      h =
        input
        |> Enum.at(y)
        |> Enum.at(x)

      score = 1
      # IO.puts(h)

      # normal input
      # [1,2]
      # [3,4]
      # IO.puts("left")
      IO.inspect({x,y})
      # IO.inspect(input)
      score = score * visibility_score(input, {x, y, h})
      # IO.inspect(score)

      # swap across the diagonal, x becomes y
      # [1,3]
      # [2,4]
      # top is now at left
      input = transpose(input)
      {x, y} = {y, x}
      # IO.puts("top")
      # IO.inspect({x,y})
      # IO.inspect(input)
      score = score * visibility_score(input, {x, y, h})
      # IO.inspect(score)

      # swap across the horizontal
      # [3,1]
      # [4,2]
      # bottom is now at left
      input = Enum.map(input, &Enum.reverse(&1))
      x = max_x - x
      # IO.puts("bottom")
      # IO.inspect({x,y})
      # IO.inspect(input)
      score = score * visibility_score(input, {x, y, h})
      # IO.inspect(score)

      # swap across diagonal, x becomes y
      # [3,4]
      # [1,2]
      # right is now at left
      input = input |> Enum.reverse()
      y = max_y - y
      input = transpose(input)
      {x, y} = {y, x}
      # IO.puts("right")
      # IO.inspect({x,y})
      # IO.inspect(input)
      score = score * visibility_score(input, {x, y, h})
      # IO.inspect(score)

      # left is left
      y = max_y - y
      # IO.inspect({x,y})
      # IO.puts("")
      score
      # {x, y, score}
    end

    # Enum.map(Enum.with_index(input), fn {y, line} ->
    #   Enum.map(line, fn tree ->
    #     visibility_score(input, tree)
    #   end)
    # end)
    # |> List.flatten()
    # |> Enum.max()
    # visibility_score(input, input |> hd |> hd)
    |> tap(&IO.inspect(&1))
    |> Enum.max()
    |> tap(&IO.inspect(&1))
  end

  def visibility_score(input, {0, _, _}) do
    0
  end

  def visibility_score(input, {x, y, h}) do
    # IO.puts("scoring")
    # max_x = length(hd(input)) - 1
    # max_y = length(input) - 1

    Enum.find_value(
      (x - 1)..0,
      x,
      fn tx ->
        th =
          input
          |> Enum.at(y)
          |> Enum.at(tx)

        if th >= h do
          # IO.inspect({tx, y, th})
          x - tx
        end
      end
    )

    # left_score =
    #   if x == 0 do
    #     0
    #   else
    #     Enum.find_value(
    #       (x - 1)..0,
    #       x,
    #       fn tx ->
    #         th =
    #           input
    #           |> Enum.at(y)
    #           |> Enum.at(tx)

    #         if th >= h do
    #           x - tx
    #         end
    #       end
    #     )
    #   end

    # right_score =
    #   if x == max_x do
    #     0
    #   else
    #     Enum.find_value(
    #       (x + 1)..max_x,
    #       max_x - x,
    #       fn cx ->
    #         {tx, _ty, th} = input |> Enum.at(y) |> Enum.at(cx)

    #         if th >= h do
    #           tx - x
    #         end
    #       end
    #     )
    #   end

    # top_score =
    #   if y == 0 do
    #     0
    #   else
    #     Enum.find_value(
    #       (y - 1)..0,
    #       y,
    #       fn cy ->
    #         {_tx, ty, th} = input |> Enum.at(cy) |> Enum.at(x)

    #         if th >= h do
    #           y - ty
    #         end
    #       end
    #     )
    #   end

    # bottom_score =
    #   if y == max_y do
    #     0
    #   else
    #     Enum.find_value(
    #       (y + 1)..max_y,
    #       max_y - y,
    #       fn cy ->
    #         {_tx, ty, th} = input |> Enum.at(cy) |> Enum.at(x)
    #         # IO.inspect({_tx, ty})

    #         if th >= h do
    #           ty - y
    #         end
    #       end
    #     )
    #   end

    # IO.inspect({left_score, right_score, top_score, bottom_score})
    # left_score + right_score + top_score + bottom_score
  end

  def score_left() do
  end

  # adds the trees visible from the left a set
  def find_visible(line, visible, max \\ -1)

  def find_visible([{x, y, height} | line], visible, max) do
    if height > max do
      max = height
      visible = MapSet.put(visible, {x, y})
      find_visible(line, visible, max)
    else
      find_visible(line, visible, max)
    end
  end

  def find_visible([], visible, _) do
    visible
  end

  # https://stackoverflow.com/a/42887944
  def transpose(rows) do
    rows
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end

# Main.solve(1)
Main.solve(2)
IO.puts("done.")
