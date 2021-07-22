defmodule Canva.RenderContexts.Composable do
  @moduledoc """
  This module is RenderContext which can be configured which
  internal data structure implementing Points behaviour to use
  and render algorithms (algorithms not implemented
  yet, hardcoded) which implemented utilizing Points behaviour
  """

  defprotocol Points do
    @moduledoc """
    Defines simple get/set points interface to Composable RenderContext
    :points field
    """

    alias Canva.AsciiChar

    @doc "Returns char at point"
    @spec get(t(), integer(), integer()) :: AsciiChar.t() | nil | :out_of_bounds
    def get(canvas, x, y)

    @doc "Sets char at point"
    @spec set(t(), integer(), integer(), AsciiChar.t()) :: t() | :out_of_bounds
    def set(canvas, x, y, char)
  end

  alias Canva.RenderContext
  alias Canva.Operations.Rectangle
  alias Canva.Operations.Flood
  alias Canva.Size
  alias Canva.AsciiChar

  @type build_points_fn :: (Size.t() -> Points.t())
  @type apply_rectangle_fn :: (t(), Rectangle.t() -> t())
  @type apply_flood_fn :: (t(), Flood.t() -> t())

  defstruct size: nil,
            empty_char: " ",
            points: nil,
            build_points_fn: nil,
            apply_rectangle_fn: nil,
            apply_flood_fn: nil

  @type t() :: %__MODULE__{
          size: Size.t(),
          empty_char: AsciiChar.t(),
          points: Points.t(),
          build_points_fn: build_points_fn(),
          apply_rectangle_fn: apply_rectangle_fn(),
          apply_flood_fn: apply_flood_fn()
        }

  @doc "Helper delegates call to Points.get"
  @spec get(t(), integer(), integer()) :: AsciiChar.t() | nil | :out_of_bounds
  def get(canvas, x, y), do: Points.get(canvas.points, x, y)

  @doc "Helper delegates call to Points.set and updates them"
  @spec set(t(), integer(), integer(), AsciiChar.t()) :: t() | :out_of_bounds
  def set(canvas, x, y, char) do
    Points.set(canvas.points, x, y, char)
    |> case do
      :out_of_bounds -> :out_of_bounds
      points -> %{canvas | points: points}
    end
  end

  @doc """
  Returns a configured RenderContext

  You must call set_size later, because by default canvas initialized with zero width.

  ## Params:

    - build_points_fn - a function that returns initial state for struct
        implementing points behaviour
   - apply_rectangle_fn - a function that applies rectangle operation
         to render context
   - apply_flood_fn - a function that applies flood operation to render context
  """
  @spec build(build_points_fn(), apply_rectangle_fn(), apply_flood_fn()) :: t()
  def build(build_points_fn, apply_rectangle_fn, apply_flood_fn),
    do: %__MODULE__{
      # to avoid depending on size at initialization
      # use null obj to have consistent state until set_size is called
      size: %Size{},
      points: build_points_fn.(%Size{}),
      apply_flood_fn: apply_flood_fn,
      build_points_fn: build_points_fn,
      apply_rectangle_fn: apply_rectangle_fn
    }

  defimpl RenderContext do
    alias Canva.RenderContexts.Composable
    alias Canva.Operations.Rectangle
    alias Canva.Operations.Flood

    import Size

    def set_size(%Composable{} = ctx, size) when valid_size(size),
      do: %{
        ctx
        | size: size,
          points: ctx.build_points_fn.(size)
      }

    def set_whitespace_char(%Composable{} = ctx, char), do: %{ctx | empty_char: char}

    def apply(%Composable{} = ctx, %Rectangle{} = rect) do
      ctx.apply_rectangle_fn.(ctx, rect)
    end

    def apply(%Composable{} = ctx, %Flood{} = flood) do
      ctx.apply_flood_fn.(ctx, flood)
    end

    # maps every point line by line
    # producing iodata list which
    # is converted at the last step
    def render(%Composable{size: size} = canvas) do
      for y <- 0..(size.height - 1) do
        for x <- 0..(size.width - 1) do
          Composable.get(canvas, x, y)
          |> case do
            nil -> canvas.empty_char
            :out_of_bounds -> raise "inconsistent state"
            char -> char
          end
        end ++ ["\n"]
      end
      |> IO.iodata_to_binary()
    end
  end
end
