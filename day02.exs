# Lessons learned:
# - Always convert your data to zero-indexed, 1 indexed always provides pain points

Mix.install([:httpoison])
HTTPoison.start()

defmodule Advent do
  @day 2
  @url "https://adventofcode.com/2022/day/#{@day}/input"

  def input(session \\ "") do
    case File.read("input2.txt") do
      {:ok, contents} ->
        contents

      {:error, :enoent} ->
        %HTTPoison.Response{status_code: 200, body: body} =
          HTTPoison.get!(@url, [], hackney: [cookie: ["session=#{session}"]])

        File.write!("input", body)

        body
    end
  end

  def uncache() do
    case File.rm("input") do
      :ok ->
        :ok
      {:error, :enoent} ->
        :ok
    end
  end
end

defmodule B do
  def solve(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.split()
      |> score()
    end)
    |> tap(&IO.inspect(&1))
    |> Enum.sum()
  end

  def score([them, outcome]) do
    them = decode(them)
    outcome = decode(outcome)

    # given the outcome of the game,
    # find what to play to get that outcome
    # we have to reverse play

    you = pick_move(them, outcome) |> encode()

    shape = you

    outcome_score =
      case outcome do
        :them -> 0
        :draw -> 3
        :you -> 6
      end

    shape + outcome_score
  end

  def pick_move(them, outcome) do
    case outcome do
      :draw -> them
      :you -> Integer.mod(them + 1, 3)
      :them -> Integer.mod(them - 1, 3)
    end
  end

  def encode(0), do: 3
  def encode(x), do: x

  def decode("A"), do: 1
  def decode("B"), do: 2
  def decode("C"), do: 3

  def decode("X"), do: :them
  def decode("Y"), do: :draw
  def decode("Z"), do: :you
end

defmodule A do
  def solve(f) do
    File.read!(f)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.split()
      |> score()
    end)
    |> tap(&IO.inspect(&1))
    |> Enum.sum()
  end

  def score([them, you]) do
    them = move(them)
    you = move(you)

    shape = you

    outcome =
      case play(them, you) do
        :them -> 0
        :draw -> 3
        :you -> 6
      end

    shape + outcome
  end

  def play(them, you) do
    case Integer.mod(you - them, 3) do
      0 -> :draw
      1 -> :you
      2 -> :them
    end
  end

  def move("A"), do: 1
  def move("B"), do: 2
  def move("C"), do: 3

  def move("X"), do: 1
  def move("Y"), do: 2
  def move("Z"), do: 3
end

IO.inspect(A.solve("input2.txt"))
IO.inspect(B.solve("input2.txt"))
