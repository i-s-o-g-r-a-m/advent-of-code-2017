defmodule MemRealloc do
  @initial [11, 11, 13, 7, 0, 15, 5, 5, 4, 4, 1, 1, 7, 1, 15, 11]

  @spec find_most_taxed_bank([integer]) :: integer
  defp find_most_taxed_bank(banks) do
    max = Enum.max(banks)
    Enum.find_index(banks, &(&1 == max))
  end

  @spec next_bank_idx([integer], integer) :: integer
  defp next_bank_idx(banks, idx) do
    i = idx + 1

    if i < length(banks) do
      i
    else
      0
    end
  end

  @spec dist([integer], integer, integer) :: [integer]
  defp dist(banks, current_bank, blocks) do
    if blocks < 1 do
      banks
    else
      new_banks = List.update_at(banks, current_bank, fn x -> x + 1 end)
      dist(new_banks, next_bank_idx(new_banks, current_bank), blocks - 1)
    end
  end

  @spec redistribute([integer], [[integer]], integer) :: integer
  defp redistribute(current, all_redists, iter) do
    already_seen =
      Enum.member?(
        Enum.drop(Enum.reverse(all_redists), 1),
        List.last(all_redists)
      )

    if already_seen do
      iter
    else
      most_taxed = find_most_taxed_bank(current)
      zeroed_out_banks = List.update_at(current, most_taxed, fn _ -> 0 end)
      blocks_to_dist = Enum.at(current, most_taxed)
      next = next_bank_idx(current, most_taxed)
      new_banks = dist(zeroed_out_banks, next, blocks_to_dist)
      redistribute(new_banks, all_redists ++ [new_banks], iter + 1)
    end
  end

  @spec main() :: integer
  def main() do
    redistribute(@initial, [@initial], 0)
  end
end

expected = 4074

if MemRealloc.main() != expected do
  raise "did not get the expected result of #{expected}"
else
  IO.puts(expected)
end
