defmodule MemRealloc do
  @initial [1, 0, 14, 14, 12, 12, 10, 10, 8, 8, 6, 6, 4, 3, 2, 1]

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

  @spec redistribute([integer], [[integer]], integer, boolean) :: {integer, [integer]}
  defp redistribute(current, all_redists, iter, cycle) do
    already_seen =
      if cycle do
        iter > 0 && List.first(all_redists) == current
      else
        Enum.member?(
          Enum.drop(Enum.reverse(all_redists), 1),
          List.last(all_redists)
        )
      end

    if already_seen do
      {iter, List.last(all_redists)}
    else
      most_taxed = find_most_taxed_bank(current)
      zeroed_out_banks = List.update_at(current, most_taxed, fn _ -> 0 end)
      blocks_to_dist = Enum.at(current, most_taxed)
      next = next_bank_idx(current, most_taxed)
      new_banks = dist(zeroed_out_banks, next, blocks_to_dist)

      if cycle do
        redistribute(new_banks, [List.first(all_redists), new_banks], iter + 1, cycle)
      else
        redistribute(new_banks, all_redists ++ [new_banks], iter + 1, cycle)
      end
    end
  end

  @spec main(boolean) :: {integer, [integer]}
  def main(cycle \\ false) do
    redistribute(@initial, [@initial], 0, cycle)
  end
end

expected = {2793, [1, 0, 14, 14, 12, 12, 10, 10, 8, 8, 6, 6, 4, 3, 2, 1]}
result = MemRealloc.main(true)

IO.inspect(result)

if result != expected do
  raise "got unexpected result"
end
