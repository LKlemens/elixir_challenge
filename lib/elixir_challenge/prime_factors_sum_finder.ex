defmodule ElixirChallenge.PrimeFactorsSumFinder do
  @doc """
  A function which finds and returns a number in the `candidates` list
  for which the sum of its prime factors is equal `target_sum`.

  ## Examples

      iex> ElixirChallenge.PrimeFactorsSumFinder.find_number_with_factors_sum([8, 13, 12], 6)
      8

      iex> ElixirChallenge.PrimeFactorsSumFinder.find_number_with_factors_sum([8, 13, 12], 7)
      12

  """
  @spec find_number_with_factors_sum([integer()], integer()) :: integer()
  def find_number_with_factors_sum(candidates, target_sum) do
    sorted_candidates = Enum.sort(candidates)

    find_parallel(sorted_candidates, target_sum)
  end

  defp find_sequential(candidates, target_sum) do
    Enum.find(candidates, fn candidate ->
      sum_prime_factors(candidate) == target_sum
    end)
  end

  defp find_parallel(candidates, target_sum) do
    chunk_size = max(1, div(length(candidates), System.schedulers_online()))

    candidates
    |> Enum.chunk_every(chunk_size)
    |> Task.async_stream(
         fn chunk ->
           find_sequential(chunk, target_sum)
         end,
         ordered: false,
         timeout: 3000
       )
    |> Stream.filter(fn {:ok, result} -> not is_nil(result) end)
    |> Stream.map(fn {:ok, result} -> result end)
    |> Enum.at(0)
  end

  defp sum_prime_factors(n) when n <= 1, do: 0
  defp sum_prime_factors(n) do
        {n, sum} = extract_twos(n, 0)
        {n, sum} = extract_threes(n, sum)
        factorize_remaining(n, 5, sum)
  end

  defp extract_twos(n, sum) when rem(n, 2) == 0 do
    extract_twos(div(n, 2), sum + 2)
  end
  defp extract_twos(n, sum), do: {n, sum}


  defp extract_threes(n, sum) when rem(n, 3) == 0 do
    extract_threes(div(n, 3), sum + 3)
  end
  defp extract_threes(n, sum), do: {n, sum}


  defp extract_factors(n, factor, sum) when rem(n, factor) == 0 do
    extract_factors(div(n, factor), factor, sum + factor)
  end
  defp extract_factors(n, _factor, sum), do: {n, sum}


  defp factorize_remaining(1, _, sum), do: sum

  defp factorize_remaining(n, factor, sum) when factor * factor > n and n > 1 do
    sum + n
  end

  defp factorize_remaining(n, factor, sum) when rem(n, factor) == 0 do
    {n, sum} = extract_factors(n, factor, sum)
    factorize_remaining(n, factor, sum)
  end

  defp factorize_remaining(n, factor, sum) do
    next_factor = next_factor(factor)
    factorize_remaining(n, next_factor, sum)
  end


  defp next_factor(factor) do
    # this fn skip multiples of 2 and 3
    case rem(factor, 6) do
      5 -> factor + 2
      1 -> factor + 4
      _ -> factor + 2
    end
  end
end
