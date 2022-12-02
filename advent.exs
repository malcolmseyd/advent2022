Mix.install([{:httpoison, "~> 1.8"}])
HTTPoison.start()

defmodule Advent do
  def input(day) do
    # for use inside of a subfolder
    filename = "../input#{day}.txt"

    case File.read(filename) do
      {:ok, contents} ->
        contents

      {:error, :enoent} ->
        url = "https://adventofcode.com/2022/day/#{day}/input"

        session =
          File.read!("../session.txt")
          |> String.trim()

        resp = HTTPoison.get!(url, [], hackney: [cookie: ["session=#{session}"]])

        case resp do
          %HTTPoison.Response{status_code: 200, body: body} ->
            File.write!(filename, body)
            body

          %HTTPoison.Response{status_code: 404} ->
            raise "Day #{day} is not out yet! Try again later!"
        end
    end
  end

  def uncache(day) do
    case File.rm("input#{day}.txt") do
      :ok ->
        :ok

      {:error, :enoent} ->
        :ok

      other ->
        other
    end
  end
end
