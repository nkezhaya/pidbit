FROM hexpm/elixir:1.18.4-erlang-27.3.4-alpine-3.20.6
WORKDIR /code
CMD ["elixir", "runner.exs"]
