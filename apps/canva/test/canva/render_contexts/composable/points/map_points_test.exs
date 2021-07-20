defmodule Canva.RenderContexts.Composable.Points.MapPointsTest do
  use ExUnit.Case

  alias Canva.Size
  alias Canva.RenderContexts.Composable.Points
  alias Canva.RenderContexts.Composable.Points.MapPoints

  setup do
    %{points: MapPoints.build(%Size{width: 3, height: 5})}
  end

  test "get/2 should return out_of_bounds if beyond", ctx do
    assert :out_of_bounds = Points.get(ctx.points, 3, 6)
    assert :out_of_bounds = Points.get(ctx.points, 4, 5)
    assert :out_of_bounds = Points.get(ctx.points, 4, -5)
  end

  test "set/2 should update character at position", ctx do
    assert nil == Points.get(ctx.points, 0, 0)
    assert %{} = points = Points.set(ctx.points, 0, 0, "x")
    assert "x" == Points.get(points, 0, 0)
    assert %{} = points = Points.set(points, 0, 0, nil)
    assert nil == Points.get(points, 0, 0)
  end

  test "set/2 should return out_of_bounds if beyond", ctx do
    assert :out_of_bounds = Points.set(ctx.points, 4, 5, "x")
  end
end
