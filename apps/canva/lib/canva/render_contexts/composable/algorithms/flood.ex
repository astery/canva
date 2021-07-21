defmodule Canva.RenderContexts.Composable.Algorithms.Flood do
  @moduledoc """
  Draws the fill character to the start coordinate, and continues
  to attempt drawing the character around (up, down, left, right)
  in each direction from the position it was drawn at, as long as a
  different character, or a border of the canvas, is not reached.
  """

  alias Canva.RenderContexts.Composable
  alias Canva.Operations.Flood

  @spec apply(Composable.t(), Flood.t()) :: Composable.t()
  def apply(%Composable{} = ctx, %Flood{} = flood) do
    flood(ctx, flood.x, flood.y, flood.fill_char)
  end

  defp flood(ctx, x, y, fill_char) do
    Composable.get(ctx, x, y)
    |> case do
      nil ->
        Composable.set(ctx, x, y, fill_char)
        |> flood(x + 1, y, fill_char)
        |> flood(x - 1, y, fill_char)
        |> flood(x, y + 1, fill_char)
        |> flood(x, y - 1, fill_char)

      _ ->
        ctx
    end
  end
end
