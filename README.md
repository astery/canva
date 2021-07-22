[![build](https://github.com/astery/canva/actions/workflows/ci.yml/badge.svg)](https://github.com/astery/canva/actions)

# Canva

## What is this?

This is the solution to the test assignment. You can read the problem description in [pages/canvas.md](https://github.com/astery/canva/blob/master/pages/canvas.md)

Consider to read my internal reflections about development process in [pages/reflections.md](https://github.com/astery/canva/blob/master/pages/reflections.md)

## Dependencies

- Elixir: 1.12
- Erlang/OTP: 24.0

## Setup

1. `mix setup`
1. `mix dialyzer --plt` # Will take a long time for the first run

Consider to add local git hooks to prevent pushing malformed commit:

`cp .hooks/* .git/hooks`

## Run

- Start server `iex -S mix phx.server`
- Generate couple of canvases
- Try live update by running in console:

```elixir
import Canva.Generators
size = %Canva.Size{width: 30, height: 30} # Current size of generated canvases
operation = operation_generator(size) |> Enum.at(0) # generate operation
CanvaService.add_operation("<id of canvas>", operation) 
```

## Running tests

- `mix test`
- `mix benchmark`

## Screenshot

![screenshot](https://github.com/astery/canva/blob/master/pages/screenshot.png)]
