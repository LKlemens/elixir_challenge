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
    caller = self()

    start_number_processor(caller, candidates, target_sum)

    receive do
      {:solution, number} ->
        number
    end
  end

  def start_number_processor(caller, candidates, target_sum) do
    spawn(fn ->
      parent = self()

      candidates
      |> Enum.each(fn number ->
        spawn_link(fn ->
          if process_number(number, target_sum) do
            send(parent, {:found, number})
          end
        end)
      end)

      receive do
        {:found, number} ->
          send(caller, {:solution, number})
          exit({:shutdown, :found})
      end
    end)
  end

  @spec process_number(integer(), integer(), integer()) :: boolean()
  def process_number(current, target_sum, sum \\ 0, divisor \\ 2) do
    cond do
      divisor * divisor <= current -> if rem(current, divisor) == 0 do
        process_number(div(current, divisor), target_sum, sum + divisor, divisor)
      else
        process_number(current, target_sum, sum, divisor + 1)
      end
      current > 1 -> process_number(div(current, current), target_sum, sum + current, current)
      true -> sum == target_sum
    end
  end
end
