Mix.install([
  {:floki, "~> 0.34.0"},
  {:httpoison, "~> 1.8"}
])

HTTPoison.start()

leaderboard_url = "https://adventofcode.com/2022/leaderboard/self"
session = System.get_env("AOC_SESSION")

%{status_code: 200, body: body} =
  HTTPoison.get!(leaderboard_url, [], hackney: [cookie: ["session=#{session}"]])

{:ok, html} = Floki.parse_document(body)

stats_matrix =
  html
  |> Floki.find("article pre")
  |> Enum.at(0)
  |> Tuple.to_list()
  |> Enum.at(2)
  |> Enum.at(-1)
  |> String.trim()
  |> String.split("\n")
  |> Enum.map(&String.split(&1))

stats_url = "https://adventofcode.com/2022/stats"

%{status_code: 200, body: body} = HTTPoison.get!(stats_url)

{:ok, html} = Floki.parse_document(body)

global_completions =
  html
  |> Floki.find(".stats a")
  |> Enum.map(fn elem ->
    [day, p2, p1, _, _] =
      elem
      |> Tuple.to_list()
      |> Enum.at(2)

    day = String.trim(day)

    f = fn p ->
      {_, _, p} = p
      [p] = p
      {p, ""} = Integer.parse(String.trim(p))
      p
    end

    p1 = f.(p1)
    p2 = f.(p2)

    # p1 is people who ONLY did p1, we want anyone who did it
    # so people who did p2 also did p1
    {day, to_string(p1 + p2), to_string(p2)}
  end)

stats_rows =
  Enum.zip(stats_matrix, global_completions)
  |> Enum.map(fn {[day, time1, rank1, _, time2, rank2, _], {_, comp1, comp2}} ->
    # {["9", "00:46:20", "6710", "0", "03:08:04", "11705", "0"], {9, 22900, 15920}}
    # format numbers
    f = fn s ->
      s
      |> String.reverse()
      |> String.graphemes()
      |> Enum.chunk_every(3)
      |> Enum.join(",")
      |> String.reverse()
    end

    [day, time1, f.(rank1), f.(comp1), time2, f.(rank2), f.(comp2)]
  end)
  |> Enum.sort_by(fn x ->
    x
    |> Enum.at(0)
    |> String.to_integer()
  end)
  |> Enum.map(fn row ->
    {"tr", [],
     Enum.map(row, fn col ->
       {"td", [], col}
     end)}
  end)
  |> Enum.to_list()

header_rows = [
  {"tr", [],
   [
     {"th", [], []},
     {"th", [{"colspan", "3"}], ["Part 1"]},
     {"th", [{"colspan", "3"}], ["Part 2"]}
   ]},
  {"tr", [],
   Enum.map(["Day", "Time", "Rank", "Out of", "Time", "Rank", "Out of"], fn col ->
     {"th", [], [col]}
   end)
   |> Enum.to_list()}
]

stats_table =
  [{"table", [], header_rows ++ stats_rows}]
  |> Floki.raw_html()

timestamp = "Generated at #{DateTime.utc_now() |> DateTime.to_string()}"

generated = stats_table <> "\n" <> timestamp

leaderboard_pattern =
  Regex.compile!("(<!--LEADERBOARD_START-->\n).*(\n<!--LEADERBOARD_END-->)", [:dotall])

readme = File.read!("README.md")
new_readme = Regex.replace(leaderboard_pattern, readme, "\\1" <> generated <> "\\2")
File.write!("README.md", new_readme)

IO.puts("new leaderboard generated")
