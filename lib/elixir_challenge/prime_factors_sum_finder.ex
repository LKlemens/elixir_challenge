defmodule ElixirChallenge.PrimeFactorsSumFinder do
  def divs(number, target, divisor) do
    cond do
      # finished factoring
      number == 1 ->
        if target == 0 do
          {:good, 0, 0}
        else
          {:bad, target, 0}
        end

      # hit prime
      divisor > floor(:math.sqrt(number)) ->
        if number == target do
          {:good, 0, 0}
        else
          {:bad, target, 0}
        end

      # target missed
      target <= 0 ->
        {:bad, target, 0}

      # target implicitly missed
      target < divisor ->
        {:bad, target, 0}

      # finished factoring
      rem(number, divisor) != 0 ->
        {:continue, number, target}

      # hit factor
      true ->
        divs(div(number, divisor), target - divisor, divisor)
    end
  end

  def check(number, target) do
    case divs(number, target, 2) do
      {:good, _, _} ->
        true

      {:bad, left, _} ->
        false

      {:continue, start_num, start_target} ->
        test(start_num, start_target, 3)
    end
  end

  def test(number, target, divisor) do
    case divs(number, target, divisor) do
      {:good, _, _} ->
        true

      {:bad, left, _} ->
        false

      {:continue, start_num, start_target} ->
        test(start_num, start_target, divisor + 2)
    end
  end

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
    candidate = hd(candidates)

    if check(candidate, target_sum) do
      candidate
    else
      find_number_with_factors_sum(tl(candidates), target_sum)
    end
  end
end
