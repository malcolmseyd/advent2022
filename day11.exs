# Lessons learned:
# - It's okay to use Agents for things that feel like they should be side
#   effects. Yesterday, it was sampling. Today, it was counting. I feel like
#   it's a similar use case to Haskell's State monad, where you can have mutable
#   values that aren't really the main point of the problem but should follow
#   you around everywhere anyways.
# - Use Maps for complex objects. I ended up using a bunch of nested tuples and
#   it left a bad taste in my mouth. Passing around big maps and only pulling
#   out keys that I need seems really appealing, and it's pretty similar to what
#   TypeScript and Clojure programmers do all the time with no issue.
# - Don't waste time parsing small input. For this problem, I probably spent
#   more time writing the parsing code than I would have just manually writing
#   the input into my program. I know it's less clean and general but for a
#   "competitive programming" event like this, it's really an option to
#   consider.

Code.require_file("advent.exs")

defmodule Main do
  @day 11

  def solve(i) do
    Advent.input(@day)
    |> String.trim()
    |> String.split("\n\n")
    |> Enum.map(fn m ->
      m = {{id, _, _}, _} = parse_monkey(m)
      {id, m}
    end)
    |> Enum.into(%{})
    |> part(i)
  end

  def part(input, 1) do
    Agent.start_link(fn -> %{} end, name: :inspections)

    monkeys = input
    monkey_ids = Map.keys(monkeys)

    # number of rounds
    1..20
    |> Enum.reduce(monkeys, fn _round, monkeys ->
      # each monkey takes a turn
      Enum.reduce(monkey_ids, monkeys, fn id, monkeys ->
        {{^id, op, test}, items} = Map.get(monkeys, id)
        # the monkey inspects each item
        Enum.reduce(items, monkeys, fn item, monkeys ->
          item = inspect_item(id, item, op)
          item = trunc(item / 3)
          new_id = pass(item, test)

          monkeys
          # dequeue item from old monkey
          |> Map.update!(id, fn {other, [_ | items]} ->
            {other, items}
          end)
          # enqueue item to new monkey
          |> Map.update!(new_id, fn {other, items} ->
            {other, items ++ [item]}
          end)
        end)
      end)
    end)

    inspections = Agent.get(:inspections, fn x -> x end)
    Agent.stop(:inspections)

    inspections
    |> Map.values()
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.product()
    |> tap(&IO.inspect(&1))
  end

  def part(input, 2) do
    Agent.start_link(fn -> %{} end, name: :inspections)

    monkeys = input
    monkey_ids = Map.keys(monkeys)

    # cap the value of each item based on the monkeys' test
    predicate_factors =
      Map.values(monkeys)
      |> Enum.map(fn {{_, _, {pred, _, _}}, _} -> pred end)
      |> Enum.product()

    # iterate through rounds
    1..10000
    |> Enum.reduce(monkeys, fn _round, monkeys ->
      # each monkey takes a turn
      Enum.reduce(monkey_ids, monkeys, fn id, monkeys ->
        {{^id, op, test}, items} = Map.get(monkeys, id)
        # the monkey inspects each item
        Enum.reduce(items, monkeys, fn item, monkeys ->
          item = inspect_item(id, item, op)
          item = rem(item, predicate_factors)
          new_id = pass(item, test)

          # dequeue item from old monkey
          monkeys
          |> Map.update!(id, fn {other, [_ | items]} ->
            {other, items}
          end)
          # enqueue item to new monkey
          |> Map.update!(new_id, fn {other, items} ->
            {other, items ++ [item]}
          end)
        end)
      end)
    end)

    # |> tap(&IO.inspect(&1))

    inspections = Agent.get(:inspections, fn x -> x end)
    Agent.stop(:inspections)

    inspections
    |> Map.values()
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.take(2)
    |> Enum.product()
    |> tap(&IO.inspect(&1))

    # input
  end

  def inspect_item(id, item, {operator, operand}) do
    Agent.update(:inspections, fn m -> Map.update(m, id, 1, &(&1 + 1)) end)

    operator =
      case operator do
        :add -> fn a, b -> a + b end
        :multiply -> fn a, b -> a * b end
      end

    operand =
      case operand do
        :old -> item
        x -> x
      end

    operator.(item, operand)
  end

  def pass(item, {predicate, true_branch, false_branch}) do
    if rem(item, predicate) == 0 do
      true_branch
    else
      false_branch
    end
  end

  def parse_monkey(monkey) do
    lines = String.split(monkey, "\n")

    [id, items, op] = Enum.take(lines, 3)
    test = Enum.drop(lines, 3)

    [id] = Regex.run(~r/\d+/, id)
    id = String.to_integer(id)

    items =
      Regex.scan(~r/\d+/, items)
      |> Enum.map(fn [x] -> String.to_integer(x) end)

    [_, operator, operand] = Regex.run(~r/old (.) (old|\d+)/, op)

    operator =
      case operator do
        "+" -> :add
        "*" -> :multiply
      end

    operand =
      case operand do
        "old" -> :old
        x -> String.to_integer(x)
      end

    [predicate, true_branch, false_branch] = test

    [predicate] = Regex.run(~r/\d+/, predicate)
    predicate = String.to_integer(predicate)

    [true_branch] = Regex.run(~r/\d+/, true_branch)
    true_branch = String.to_integer(true_branch)

    [false_branch] = Regex.run(~r/\d+/, false_branch)
    false_branch = String.to_integer(false_branch)

    {{id, {operator, operand}, {predicate, true_branch, false_branch}}, items}
  end
end

Main.solve(1)
Main.solve(2)
IO.puts("done.")
