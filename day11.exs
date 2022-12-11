Code.require_file("advent.exs")

defmodule Main do
  @day 11

  def solve(i) do
    example1 = """
    Monkey 0:
    Starting items: 79, 98
    Operation: new = old * 19
    Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

    Monkey 1:
    Starting items: 54, 65, 75, 74
    Operation: new = old + 6
    Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

    Monkey 2:
    Starting items: 79, 60, 97
    Operation: new = old * old
    Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

    Monkey 3:
    Starting items: 74
    Operation: new = old + 3
    Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
    """

    Advent.input(@day)
    # example1
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

    # {id, items, {operator, operand}, {predicate, true_branch, false_branch}}
    monkeys =
      input
      # |> tap(&IO.inspect(&1))

    monkey_ids = Map.keys(monkeys)

    # 20 rounds
    1..20
    |> Enum.reduce(monkeys, fn round, monkeys ->
      # IO.puts("round #{round}")
      # IO.inspect(monkeys)
      # each monkey takes a turn
      Enum.reduce(monkey_ids, monkeys, fn id, monkeys ->
        {{^id, op, test}, items} = Map.get(monkeys, id)
        # the monkey inspects each item
        Enum.reduce(items, monkeys, fn item, monkeys ->
          item = inspect_item(id, item, op)
          item = trunc(item / 3)
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

  def part(input, 2) do
    Agent.start_link(fn -> %{} end, name: :inspections)

    monkeys =
      input
      # |> tap(&IO.inspect(&1))

    monkey_ids = Map.keys(monkeys)

    # cap the value of each item based on the monkeys' test
    predicate_factors =
      Map.values(monkeys)
    |> Enum.map(fn {{_, _, {pred, _, _}}, _} -> pred end)
    |> Enum.product()

    # 10000 rounds
    1..10000
    |> Enum.reduce(monkeys, fn round, monkeys ->
      # IO.puts("round #{round}")
      # IO.inspect(monkeys)
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
