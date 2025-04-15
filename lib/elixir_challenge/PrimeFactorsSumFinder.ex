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

    def factors_sum(num, target, pid), do: factor_sum(num, num, 2, target, pid)

    def factor_sum(num, 1, _div, target, pid) when target==0, do: send(pid, num)
    def factor_sum(_num, 1, _div, _target, _pid), do: nil

    def factor_sum(_num, _n, _div, target, _pid) when target<0, do: nil

    def factor_sum(num, n, div, target, pid) when div * div > n and target-n==0, do: send(pid, num)
    def factor_sum(_num, n, div, _target, _pid) when div * div > n, do: nil

    def factor_sum(num, n, div, target, pid) do
      cond do
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
    for num <- candidates do  spawn(__MODULE__, :factors_sum, [num, target_sum, self()]) end
    receive do
      correct_number -> correct_number
    end
  end
end
