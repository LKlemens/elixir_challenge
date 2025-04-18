defmodule ElixirChallenge.PrimeFactorsSumFinder do
  def divs(number, target, divisor) do
    cond do
      # finished factoring
      number == 1 ->
        if target == 0 do
          {:good, 0, 0}
        else
          {:bad, 0, 0}
        end

      # hit prime
      divisor > floor(:math.sqrt(number)) ->
        if number == target do
          {:good, 0, 0}
        else
          {:bad, 0, 0}
        end

      # target missed
      target <= 0 ->
        {:bad, 0, 0}

      # target implicitly missed
      target < divisor ->
        {:bad, 0, 0}

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

      {:bad, _, _} ->
        false

      {:continue, start_num, start_target} ->
        test(start_num, start_target, 3)
    end
  end

  def test(number, target, divisor) do
    case divs(number, target, divisor) do
      {:good, _, _} ->
        true

      {:bad, _, _} ->
        false

      {:continue, start_num, start_target} ->
        test(start_num, start_target, divisor + 2)
    end
  end

  def start_find_number(master, candidates, target_sum) do
    case candidates do
      [candidate | rest] ->
        spawn(fn -> parallel_helper(master, candidate, target_sum) end)
        start_find_number(master, rest, target_sum)

      [] ->
        nil
    end
  end

  def parallel_helper(master, candidate, target_sum) do
    if check(candidate, target_sum) do
      send(master, {:good, candidate})
    else
      send(master, {:bad, 0})
    end
  end

  def continue_find_number(master, candidates, target_sum) do
    case candidates do
      [candidate | rest] ->
        receive do
          {:bad, _} ->
            spawn(fn -> parallel_helper(master, candidate, target_sum) end)
            continue_find_number(master, rest, target_sum)

          {:good, found} ->
            found
        end

      [] ->
        receive do
          {:bad, _} ->
            continue_find_number(master, [], target_sum)

          {:good, found} ->
            found
        end
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
    start_pool = candidates |> Enum.take(System.schedulers_online())
    rest = candidates |> Enum.drop(System.schedulers_online())
    start_find_number(self(), start_pool, target_sum)
    continue_find_number(self(), rest, target_sum)
  end
end
