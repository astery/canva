[![build](https://github.com/astery/canva/actions/workflows/ci.yml/badge.svg)](https://github.com/astery/canva/actions)

# Canva

## What is this?

This is the solution to the test assignment. You can read the problem description in [pages/canvas.md](https://github.com/astery/canva/blob/master/pages/canvas.md)

Consider to read my internal reflections about development process in [pages/reflections.md](https://github.com/astery/canva/blob/master/pages/reflections.md)

## Dependencies

- Elixir: 1.12
- Erlang/OTP: 24.0

## Setup

1. `mix deps.get`
1. `mix dialyzer --plt` # Will take a long time for the first run

Consider to add local git hooks to prevent pushing malformed commit:

`cp .hooks/* .git/hooks`

## Running tests

`mix test`
