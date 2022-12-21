Code.require_file("advent.exs")

defmodule Main do
  @day 21

  def solve() do
    env =
      Advent.input(@day)
      # example_input
      |> String.trim()
      |> String.split("\n")
      |> Enum.map(&parse/1)
      |> Enum.into(%{})
      # |> tap(&IO.inspect(&1))

    # part 1
    eval("root", env)
    |> tap(&IO.inspect(&1))

    env =
      env
      |> Map.update!("root", fn {_op, var1, var2} -> {"=", var1, var2} end)
      |> Map.put("humn", :x)

    # for part 2, we need part a value for "humn" such that
    # for root's expression, var1 = var2

    # we can do this by evaluating every branch except for the one containing
    # "humn", and then doing symbolic algebra on the remaining tree

    # start at the equals sign and move it up slowly
    eval("root", env)
    |> find_x()
    |> tap(&IO.inspect(&1))
  end

  def find_x(expr, soln \\ nil)

  # recursive step, invert the expression
  def find_x(expr, c) do
    # we can reverse each operation:
    #   c=a+x becomes x=c-a
    #   c=a-x becomes x=a-c
    #   c=x-a becomes x=a+c
    #   c=a*x becomes x=c/a
    #   c=a/x becomes x=a/c
    #   c=x/a becomes x=c*a
    case expr do
      :x ->
        c

      {"=", a, x} when is_number(a) ->
        find_x(x, a)

      {"=", x, a} when is_number(a) ->
        find_x(x, a)

      {"+", a, x} when is_number(a) ->
        find_x(x, c - a)

      {"+", x, a} when is_number(a) ->
        find_x(x, c - a)

      {"-", a, x} when is_number(a) ->
        find_x(x, a - c)

      {"-", x, a} when is_number(a) ->
        find_x(x, a + c)

      {"*", a, x} when is_number(a) ->
        find_x(x, div(c, a))

      {"*", x, a} when is_number(a) ->
        find_x(x, div(c, a))

      {"/", a, x} when is_number(a) ->
        find_x(x, div(a, c))

      {"/", x, a} when is_number(a) ->
        find_x(x, a * c)

      _ ->
        {expr, c}
    end
  end

  def eval(sym, env) when is_binary(sym) do
    Map.get(env, sym)
    |> eval(env)
  end

  def eval(num, _env) when is_number(num) do
    num
  end

  def eval(:x, _env) do
    :x
  end

  def eval({op, var1, var2}, env) do
    expr1 = eval(var1, env)
    expr2 = eval(var2, env)

    if not is_number(expr1) or not is_number(expr2) do
      {op, expr1, expr2}
    else
      case op do
        "+" -> expr1 + expr2
        "-" -> expr1 - expr2
        "*" -> expr1 * expr2
        "/" -> div(expr1, expr2)
      end
    end
  end

  def parse(<<name::binary-size(4), ": ", rest::binary>>) do
    value =
      case rest do
        <<var1::binary-size(4), " ", op::binary-size(1), " ", var2::binary-size(4)>> ->
          {op, var1, var2}

        _ ->
          String.to_integer(rest)
      end

    {name, value}
  end
end

Main.solve()
IO.puts("done.")
