Mix.install([
  {:floki, "~> 0.34.0"},
  {:httpoison, "~> 1.8"}
])

HTTPoison.start()

url = "https://adventofcode.com/2022/leaderboard/self"
session = System.get_env("AOC_SESSION")

%{status_code: 200, body: body} =
  HTTPoison.get!(url, [], hackney: [cookie: ["session=#{session}"]])

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

stats_rows =
  stats_matrix
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
   Enum.map(["Day", "Time", "Rank", "Score", "Time", "Rank", "Score"], fn col ->
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
