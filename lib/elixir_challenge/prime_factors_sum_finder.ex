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
    # threads_amount = System.schedulers_online()
    me = self()

    pid =
      spawn(fn ->
        # find_number_worker(candidates, target_sum, threads_amount)
        find_number_worker(me, candidates, target_sum)
      end)

    receive do
      {:found, candidate} ->
        Process.exit(pid, :kill)
        candidate
    end
  end

  def find_number_worker(
        master,
        candidates,
        target_sum,
        threads_amount \\ System.schedulers_online()
      ) do
    start_pool = candidates |> Enum.take(threads_amount)
    rest = candidates |> Enum.drop(threads_amount)
    me = self()

    start_pool
    |> Enum.map(fn candidate ->
      pid = spawn(fn -> parallel_helper(me, candidate, target_sum) end)
      Process.link(pid)
    end)

    found = continue_find_number(rest, target_sum)
    send(master, {:found, found})
  end

  def parallel_helper(master, candidate, target_sum) do
    if check(candidate, target_sum) do
      send(master, {:good, candidate})
    else
      send(master, {:bad, 0})
    end
  end

  def continue_find_number(candidates, target_sum) do
    me = self()

    receive do
      {:bad, _} ->
        case candidates do
          [candidate | rest] ->
            pid = spawn(fn -> parallel_helper(me, candidate, target_sum) end)
            Process.link(pid)
            continue_find_number(rest, target_sum)

          [] ->
            continue_find_number([], target_sum)
        end

      {:good, found} ->
        found
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

  def divs(number, target, divisor) do
    cond do
      # finished factoring
      number == 1 ->
        if target == 0 do
          {:good, 0, 0}
        else
          {:bad, 0, 0}
        end

      # target missed (obviously)
      target <= 0 ->
        {:bad, 0, 0}

      # target missed (no way to reach it)
      target > number ->
        {:bad, 0, 0}

      # hit prime
      divisor > floor(:math.sqrt(number)) ->
        if number == target do
          {:good, 0, 0}
        else
          {:bad, 0, 0}
        end

      # target missed (sum can only be larger than it)
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
end
