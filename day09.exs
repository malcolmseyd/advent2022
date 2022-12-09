# Lessons learned:
# - GETTING IT RIGHT FIRST IS BETTER THAN DEBUGGING. Write tests for every case
#   that you can think of and make sure your code passes all of these.
#   Alternatively, constantly tinker with small examples in IEx, as it provides
#   a tight feedback loop.
# - DO YOUR RESEARCH ON DEBUGGING TOOLS. This is the second day in a row that I
#   have spent much longer on debugging my solution than writing it. Every time
# - your data model doesn't need to be passed through your whole program. Write
#   small, focused functions and delegate tasks to functions early. Writing
#   quick and dirty functions with multiple responsibilities might seem like a
#   good idea at first, but even for one-off things like an Advent of Code
#   challenge, you will still probably read your code more than you write it, so
#   write it well.
# - Agent is a great escape hatch for state. If you need state to be accessed
#   in deeply nested parts of your program (in my case, looking for changes),
#   but changing every call site is awkward, don't! Use a named Agent.

Code.require_file("advent.exs")

defmodule Main do
  @day 9

  def solve(i) do
    Advent.input(@day)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn <<dir::binary-size(1), " ", steps::binary>> ->
      {steps, ""} = Integer.parse(steps)
      {dir, steps}
    end)
    |> part(i)
  end

  def part(input, 1) do
    {_head_pos, _tail_pos, tail_history} =
      input
      |> Enum.reduce(
        {{0, 0}, {0, 0}, MapSet.new([{0, 0}])},
        fn {dir, steps}, state ->
          # apply `steps` times
          Enum.reduce(1..steps, state, fn _, {head_pos, tail_pos, tail_history} ->
            {head_pos, tail_pos} = trail({move(head_pos, dir), tail_pos})
            tail_history = MapSet.put(tail_history, tail_pos)
            {head_pos, tail_pos, tail_history}
          end)
        end
      )

    # |> tap(&IO.inspect(&1))

    tail_history
    |> MapSet.size()
    |> tap(&IO.inspect(&1))
  end

  def part(input, 2) do
    # multiple knots now
    # for this, let's try keeping a list of knot positions

    # move each knot at a time, starting at the first (head) and moving each
    # following knot like we moved the tail last time.
    # when we hit the last knot, the only difference is that we log the position
    #   ...H..
    #   ....1.
    #   ..432.
    #   .5....
    #   6.....  (6 covers 7, 8, 9, s)
    #
    #   ..H1..
    #   ...2.. <- see now moving the head affected both 1 and 2. 2 is 1's tail
    #   ..43..
    #   .5....
    #   6.....  (6 covers 7, 8, 9, s)

    {_knots, tail_history} =
      input
      |> Enum.reduce(
        {
          Enum.map(1..10, fn _ -> {0, 0} end),
          MapSet.new([{0, 0}])
        },
        fn {dir, steps}, state ->
          # apply `steps` times
          # IO.puts("")
          # IO.inspect({dir, steps})

          Enum.reduce(1..steps, state, fn _, {[head_pos | knots], tail_history} ->
            # apply movement to head,
            head = move(head_pos, dir)
            knots = [head | knots]

            # update knots for new head
            knots = trail_knots(knots, dir)

            # record tail position
            tail_pos = Enum.at(knots, -1)
            tail_history = MapSet.put(tail_history, tail_pos)
            # IO.inspect(knots)

            # print_knots(tail_history)

            # last = Agent.get(last_tail, fn x -> x end)
            # if last && last != tail_pos do
            #   IO.puts("before")
            #   print_knots(Agent.get(last_knots, fn x -> x end))
            #   IO.puts("after")
            #   print_knots(tail_history)
            # end

            # Agent.update(last_knots, fn _ -> knots end)
            # Agent.update(last_tail, fn _ -> tail_pos end)

            {knots, tail_history}
          end)
        end
      )

    # |> tap(&IO.inspect(&1))

    # print_knots(tail_history)

    tail_history
    |> MapSet.size()
    |> tap(&IO.inspect(&1))

    # print_knots([{4, 8}, {5, 7}, {5, 6}, {5, 5}, {5, 4}, {4, 4}, {3, 4}, {3, 3}, {2, 3}, {2, 2}])
  end

  # iterate through all knots, moving them and returning a list of new knots
  def trail_knots(knots, dir, new_knots \\ [])

  def trail_knots([head_pos], _dir, new_knots) do
    # no more tails, record last head and return entirely new knots
    new_knots ++ [head_pos]
  end

  def trail_knots([head_pos | [tail_pos | knots]], dir, new_knots) do
    # print_knots([head_pos | [tail_pos | knots]] ++ new_knots)
    old_tail = tail_pos
    # catch tail up to head
    {head_pos, tail_pos} = trail({head_pos, tail_pos})
    # IO.inspect({"moved tail:", head_pos, old_tail, tail_pos})

    # record head position and make tail the new head
    trail_knots([tail_pos | knots], dir, new_knots ++ [head_pos])
  end

  def move(pos, dir) do
    # apply motion
    {motion_x, motion_y} =
      case dir do
        "U" -> {0, 1}
        "D" -> {0, -1}
        "R" -> {1, 0}
        "L" -> {-1, 0}
      end

    {x, y} = pos

    {x + motion_x, y + motion_y}
  end

  # move tail to follow head
  def trail({head_pos, tail_pos}) do
    # detect difference between head and tail
    {head_x, head_y} = head_pos
    {tail_x, tail_y} = tail_pos
    dx = head_x - tail_x
    dy = head_y - tail_y

    if abs(dx) > 2 or abs(dy) > 2 do
      IO.puts("WHAT THE HECK, TOO FAR")
      IO.inspect({head_pos, tail_pos})
      raise "WHAT THE HECK, TOO FAR"
    end

    # move if too far
    # if too far in one direction
    # snap other direction
    # i.e. too far up, snap x value to head_x
    # example:
    #  ......
    #  ......
    #  ......
    #  ....H.
    #  s..T..

    #  ......
    #  ......
    #  ....H.
    #  ....T.
    #  s.....
    tail_pos =
      case {dx, dy} do
        # part 2, head can move diagonally now
        # move up-right
        {2, 2} -> {head_x - 1, head_y-1}
        {-2, 2} -> {head_x + 1, head_y-1}
        {2, -2} -> {head_x - 1, head_y+1}
        {-2, -2} -> {head_x + 1, head_y+1}

        # part 1, basically just follow the head
        # move right
        {2, _} -> {head_x - 1, head_y}
        # move left
        {-2, _} -> {head_x + 1, head_y}
        # move up
        {_, 2} -> {head_x, head_y - 1}
        # move down
        {_, -2} -> {head_x, head_y + 1}
        # ok
        _ -> tail_pos
      end

    {head_pos, tail_pos}
  end


  def print_knots(knots) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(knots, fn {x, _y} -> x end)
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(knots, fn {_x, y} -> y end)

    set = MapSet.new(knots)

    # IO.puts("printing...")

    grid =
      Enum.map(max_y..min_y, fn y ->
        Enum.map(min_x..max_x, fn x ->
          if MapSet.member?(set, {x, y}) do
            "#"
          else
            "."
          end
        end)
        |> Enum.join("")
      end)
      |> Enum.join("\n")

    IO.puts(grid)
    IO.puts("x = #{min_x} .. #{max_x}")
    IO.puts("y = #{min_y} .. #{max_y}")
  end
end

# Main.solve(1)
Main.solve(2)
IO.puts("done.")
