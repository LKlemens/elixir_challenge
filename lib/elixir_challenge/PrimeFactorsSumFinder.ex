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

  def factors_sum(num, target, pid) do
    factor_sum(num, num, 2, target, pid)
  end

  def factor_sum(num, 1, _div, 0, pid), do: send(pid, num)
  def factor_sum(_num, 1, _div, _target, _pid), do: :noop
  def factor_sum(_num, _n, _div, target, _pid) when target < 0, do: :noop

  def factor_sum(num, n, div, target, pid) do
    cond do
      div * div > n ->
        if n == target do
          send(pid, num)
        else
          :noop
        end

      rem(n, div) == 0 ->
        factor_sum(num, div(n, div), div, target - div, pid)

      div == 2 ->
        factor_sum(num, n, 3, target, pid)

      true ->
        factor_sum(num, n, div + 2, target, pid)
    end
  end


  @spec find_number_with_factors_sum([integer()], integer()) :: integer()
  def find_number_with_factors_sum(candidates, target_sum) do
    # Your solution
    pids = for num <- candidates do  spawn(__MODULE__, :factors_sum, [num, target_sum, self()]) end
    # target_sum is sum of one of candidate, so receive always
    receive do
      correct_number ->
        for pid <- pids do pid |> Process.exit(:shutdown) end
        correct_number
    end
  end
end
