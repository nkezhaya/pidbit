defmodule Pidbit.Cache do
  @cache_name :pidbit_cache

  @doc """
  Resets the cache.
  """
  @spec reset() :: :ok
  def reset do
    Cachex.reset(@cache_name)
    :ok
  end

  @doc """
  Removes an entry from the cache.
  """
  def clear(key) do
    Cachex.del(@cache_name, key)
  end

  @pairs %{
    list_problems: &Pidbit.Problems.list_problems/0
  }

  @keys Map.keys(@pairs)
  @default_expiration :timer.minutes(5)

  if Mix.env() == :test do
    defmacro fetch(key, expiration \\ @default_expiration, do: block) do
      quote do
        # Suppress test warnings for unused variables after the macro is
        # expanded
        _ = unquote(key)
        _ = unquote(expiration)

        unquote(block)
      end
    end
  else
    defmacro fetch(key, expiration \\ @default_expiration, do: block) do
      quote do
        fallback = fn -> {:commit, unquote(block)} end

        with {:commit, result} <- Cachex.fetch(unquote(@cache_name), unquote(key), fallback) do
          Cachex.expire(unquote(@cache_name), unquote(key), unquote(expiration))
          result
        else
          {_, val} -> val
          _ -> :error
        end
        |> case do
          %Cachex.Error{} ->
            # NOTE: Currently, if an exception is thrown inside a call to
            # Cache.fetch/3, %Cachex.ExecutionError{} gets returned, as opposed
            # to the error being raised in the caller. This is supposed to be
            # fixed at some point, but for now, the only way to raise an
            # Ecto.NoResultsError exception is to just re-run the query again
            # outside of the dispatched cache fetch process. Without this, a 500
            # will be thrown, instead of a 404.

            unquote(block)

          result ->
            result
        end
      end
    end
  end

  # Defines functions from the pairs. For example: Cache.list_problems()
  for key <- @keys do
    def unquote(key)() do
      fetch(to_string(unquote(key))) do
        @pairs[unquote(key)].()
      end
      |> case do
        :error -> []
        result -> result
      end
    end
  end

  @doc false
  def cache_name, do: @cache_name

  @doc false
  def keys, do: @keys

  @doc false
  def pairs, do: @pairs
end
