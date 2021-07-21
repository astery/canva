defmodule Canva.RenderContexts.Composable.Algorithms.Rectangle do
  @moduledoc """
  Walks every point from left-top to right-bottom where
  the rectangle should be drawn and set appropriate character
  checking if current pointer is on the edge of the rectangle
  """

  alias Canva.RenderContexts.Composable
  alias Canva.Operations.Rectangle

  @spec apply(Composable.t(), Rectangle.t()) :: Composable.t()
  def apply(%Composable{} = ctx, %Rectangle{} = rect) do
    left = rect.x
    top = rect.y
    right = rect.x + rect.size.width - 1
    bottom = rect.y + rect.size.height - 1
    fill_char = rect.fill_char
    outline_char = rect.outline_char || rect.fill_char

    for y <- top..bottom, x <- left..right, reduce: ctx do
      ctx ->
        inside? = y > top and y < bottom and x > left and x < right
        char = if(inside?, do: fill_char, else: outline_char)

        Composable.set(ctx, x, y, char)
        |> case do
          :out_of_bounds -> ctx
          ctx -> ctx
        end
    end
  end
end
