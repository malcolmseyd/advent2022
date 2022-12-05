Code.eval_file("../advent.exs")

day = 5

defmodule B do
  def solve(input) do
    [crates, moves] =
      input
      |> String.split("\n\n")

    # |> tap(&IO.inspect(&1))

    # split into charlist of crates, starting at bottom. space is none
    levels =
      crates
      |> String.split("\n")
      |> Enum.reverse()
      |> Enum.drop(1)
      |> Enum.map(fn x ->
        x
        |> to_charlist()
        |> Enum.chunk_every(4)
        |> Enum.map(&Enum.at(&1, 1))
      end)

    # put levels into a map of stacks
    stacks =
      levels
      |> Enum.reduce(%{}, fn row, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {col, idx}, acc ->
          if col == ?\s do
            acc
          else
            Map.update(acc, idx, [col], fn stack -> [col | stack] end)
          end
        end)
      end)

    # parse moves
    moves =
      moves
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line ->
        ["move", amount, "from", src, "to", dst] = String.split(line, " ")
        {amount, ""} = Integer.parse(amount)
        {src, ""} = Integer.parse(src)
        {dst, ""} = Integer.parse(dst)
        {amount, src - 1, dst - 1}
      end)

    # apply moves to stack
    moves
    |> Enum.reduce(stacks, fn {amount, src, dst}, stacks ->
      # move multiple at once. can't just pop multiple times
      {crates, stacks} =
        stacks
        |> Map.get_and_update(src, fn stack ->
          {Enum.take(stack, amount), Enum.drop(stack, amount)}
        end)

      stacks
      |> Map.update(dst, crates, fn dst_stack -> crates ++ dst_stack end)
    end)
    |> Map.to_list()
    |> Enum.map(fn {_, k} ->
      Enum.take(k, 1)
    end)
    |> Enum.concat()
  end
end

defmodule A do
  def solve(input) do
    [crates, moves] =
      input
      |> String.split("\n\n")

    # split into charlist of crates, starting at bottom. space is none
    levels =
      crates
      |> String.split("\n")
      |> Enum.drop(-1)
      |> Enum.reverse()
      |> Enum.map(fn x ->
        x
        |> to_charlist()
        |> Enum.chunk_every(4)
        |> Enum.map(&Enum.at(&1, 1))
      end)

    # put levels into a map of stacks
    stacks =
      levels
      |> Enum.reduce(%{}, fn row, acc ->
        row
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {col, idx}, acc ->
          if col == ?\s do
            acc
          else
            Map.update(acc, idx, [col], fn stack -> [col | stack] end)
          end
        end)
      end)

    # parse moves
    moves =
      moves
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(fn line ->
        ["move", amount, "from", src, "to", dst] = String.split(line, " ")
        {amount, ""} = Integer.parse(amount)
        {src, ""} = Integer.parse(src)
        {dst, ""} = Integer.parse(dst)
        {amount, src - 1, dst - 1}
      end)

    # apply moves to stack
    moves
    |> Enum.reduce(stacks, fn {amount, src, dst}, stacks ->
      Enum.reduce(1..amount, stacks, fn _, stacks ->
        {crate, stacks} =
          stacks
          |> Map.get_and_update(src, fn stack -> {hd(stack), tl(stack)} end)

        stacks
        |> Map.update(dst, [crate], fn dst_stack -> [crate | dst_stack] end)
      end)
    end)
    |> Map.to_list()
    |> Enum.map(fn {_, k} ->
      Enum.take(k, 1)
    end)
    |> Enum.concat()
  end
end

Advent.input(day)
|> B.solve()
|> IO.inspect()

# Advent.uncache(day)

IO.puts("done.")
