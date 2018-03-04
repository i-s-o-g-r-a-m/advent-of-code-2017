defmodule A do
  @input_file "lib/input.txt"

  @spec parse_input([]) :: []
  defp parse_input(lines) do
    Enum.map(Enum.map(lines, &String.split(&1, "->")), fn x ->
      [
        Enum.at(String.split(Enum.at(x, 0), " ("), 0),
        if Enum.at(x, 1) != nil do
          Enum.map(String.split(Enum.at(x, 1), ","), &String.trim/1)
        else
          []
        end
      ]
    end)
  end

  @spec main() :: []
  def main() do
    {:ok, f} = File.read(@input_file)
    input = String.split(String.trim(f), "\n")
    parsed = parse_input(input)
    children = Enum.reduce(parsed, [], fn x, acc -> acc ++ Enum.at(x, 1) end)

    List.first(
      Enum.filter(parsed, fn x ->
        Enum.find(children, fn y -> y == Enum.at(x, 0) end) == nil
      end)
    )
  end
end

expected = "vvsvez"
result = A.main()
IO.inspect(result)

if Enum.at(result, 0) != expected do
  raise "Did not get expected result #{expected}"
end
