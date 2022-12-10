# Lessons learned:
# - Named atoms can provide a nice escape hatch for state, but use them sparingly. I probably didn't need to use them today, and I did have an issue where my part 1 state bled into part 2

Code.require_file("advent.exs")

defmodule Main do
  @day 10

  def solve(i) do
    Advent.input(@day)
    |> String.trim_trailing()
    |> String.split("\n")
    |> Enum.map(&parse(&1))
    |> part(i)
  end

  def part(input, 1) do
    # for sampling
    Agent.start_link(fn -> [] end, name: :samples)
    # last timing works because atoms > numbers
    Agent.start_link(fn -> [20, 60, 100, 140, 180, 220, :infinity] end, name: :timings)

    # register X starts at 1
    x = 1

    # state can be:
    #   :ready # can receive instruction
    #   {:adding, num} # blocking, try again later
    state = :ready

    # operators are input
    ops = input

    # each iteration is a clock cycle
    # iterate until the machine halts
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({state, x, ops}, fn cycle, {state, x, ops} ->
      sample(cycle + 1, x) # look ahead for the cycle

      # eval should act like an FSM
      # current_state -> {:cont | :halt, next_state}
      eval({state, x, ops})
    end)

    Agent.get(:samples, fn x -> x end)
    |> Enum.reduce(0, fn {x, cycle}, acc -> acc + x * cycle end)
    |> tap(&IO.inspect(&1))
  end

  def part(input, 2) do
    # for sampling
    Agent.start_link(fn -> [] end, name: :crt_samples)

    # register X starts at 1
    x = 1

    # state can be:
    #   :ready # can receive instruction
    #   {:adding, num} # blocking, try again later
    state = :ready

    # operators are input
    ops = input

    # each iteration is a clock cycle
    # iterate until the machine halts
    Stream.iterate(0, &(&1 + 1))
    |> Enum.reduce_while({state, x, ops}, fn cycle, {state, x, ops} ->
      # eval should act like an FSM
      # current state -> next state
      sample_crt(cycle, x)
      eval({state, x, ops})
    end)

    Agent.get(:crt_samples, fn x -> x end)
    |> Enum.reverse()
    |> Enum.map(fn
      true -> ?#
      false -> ?.
    end)
    |> Enum.chunk_every(40)
    |> Enum.intersperse('\n')
    |> Enum.concat()
    |> to_string()
    # |> Enum.reduce(0, fn {x, cycle}, acc -> acc + x * cycle end)
    # |> tap(&IO.inspect(&1))
    |> IO.puts()
  end

  def sample_crt(cycle, x) do
    pos = rem(cycle, 40)
    on = x >= pos - 1 and x <= pos + 1
    Agent.update(:crt_samples, fn samples -> [on | samples] end)
  end

  def eval({:ready, x, []}) do
    # no more instructions, halt
    {:halt, x}
  end

  def eval({:ready, x, [op | ops]}) do
    # apply instruction with register
    {state, new_x} = apply_op(x, op)
    {:cont, {state, new_x, ops}}
  end

  def eval({{:adding, new_x}, _x, ops}) do
    {:cont, {:ready, new_x, ops}}
  end

  # gives new processor state
  def apply_op(x, :noop) do
    {:ready, x}
  end

  def apply_op(x, {:addx, num}) do
    {{:adding, x + num}, x}
  end

  # side effects!
  def sample(cycle, x) do
    timing = Agent.get(:timings, fn [h | _] -> h end)

    if cycle == timing do
      # record sample
      Agent.update(:samples, fn samples -> [{x, timing} | samples] end)
      # update timings
      Agent.update(:timings, fn [_ | timings] -> timings end)
    end
  end

  def parse("noop") do
    :noop
  end

  def parse(<<"addx ", num::binary>>) do
    {num, ""} = Integer.parse(num)
    {:addx, num}
  end
end

Main.solve(1)
Main.solve(2)
IO.puts("done.")
