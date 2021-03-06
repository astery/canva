defmodule CanvaTest do
  use ExUnit.Case
  doctest Canva

  alias Canva.Size
  alias Canva.Operations.Rectangle
  alias Canva.Operations.Flood

  # Runs same tests for all public canvas configurations
  # (Canva.build_* functions)
  canvas_strategies = [
    &Canva.build_composable_map_based_render_ctx/0,
    &Canva.build_composable_array_based_render_ctx/0
  ]

  use ExUnitProperties
  import Canva.Generators

  for strategy <- canvas_strategies do
    describe inspect(strategy) do
      setup do
        %{strategy: unquote(strategy)}
      end

      property "render_canvas/2 should not emit eny errors" do
        check all canvas <- canvas_generator(1..50) do
          string = Canva.render_canvas(canvas)
          assert is_binary(string)
        end
      end

      test "render/2 should render area filled with spaces on empty canvas", ctx do
        canvas = build_canvas(%Size{width: 1, height: 3}, ctx.strategy)

        assert """



               """ == render(canvas, [])
      end

      test "render/2 should render outline at canvas border", ctx do
        size = %Size{width: 3, height: 5}
        canvas = build_canvas(size, ctx.strategy)

        operations = [
          %Rectangle{x: 0, y: 0, size: size, outline_char: "@"}
        ]

        assert """
               @@@
               @ @
               @ @
               @ @
               @@@
               """ == render(canvas, operations)
      end

      test "render/2 should fill whole canvas", ctx do
        size = %Size{width: 3, height: 5}
        canvas = build_canvas(size, ctx.strategy)

        operations = [
          %Rectangle{x: 0, y: 0, size: size, fill_char: "@"}
        ]

        assert """
               @@@
               @@@
               @@@
               @@@
               @@@
               """ == render(canvas, operations)
      end

      test "render/2 fixture 1", ctx do
        canvas = build_canvas(%Size{width: 24, height: 9}, ctx.strategy)

        operations = [
          %Rectangle{x: 3, y: 2, size: size(5, 3), outline_char: "@", fill_char: "X"},
          %Rectangle{x: 10, y: 3, size: size(14, 6), outline_char: "X", fill_char: "O"}
        ]

        assert """


                  @@@@@
                  @XXX@  XXXXXXXXXXXXXX
                  @@@@@  XOOOOOOOOOOOOX
                         XOOOOOOOOOOOOX
                         XOOOOOOOOOOOOX
                         XOOOOOOOOOOOOX
                         XXXXXXXXXXXXXX
               """ == render(canvas, operations)
      end

      test "render/2 fixture 2", ctx do
        canvas = build_canvas(%Size{width: 21, height: 8}, ctx.strategy)

        operations = [
          %Rectangle{x: 14, y: 0, size: size(7, 6), outline_char: nil, fill_char: "."},
          %Rectangle{x: 0, y: 3, size: size(8, 4), outline_char: "O", fill_char: nil},
          %Rectangle{x: 5, y: 5, size: size(5, 3), outline_char: "X", fill_char: "X"}
        ]

        assert """
                             .......
                             .......
                             .......
               OOOOOOOO      .......
               O      O      .......
               O    XXXXX    .......
               OOOOOXXXXX
                    XXXXX
               """ = render(canvas, operations)
      end

      test "render/2 fixture 3", ctx do
        canvas = build_canvas(%Size{width: 21, height: 8}, ctx.strategy)

        operations = [
          %Rectangle{x: 14, y: 0, size: size(7, 6), outline_char: nil, fill_char: "."},
          %Rectangle{x: 0, y: 3, size: size(8, 4), outline_char: "O", fill_char: nil},
          %Rectangle{x: 5, y: 5, size: size(5, 3), outline_char: "X", fill_char: "X"},
          %Flood{x: 0, y: 0, fill_char: "-"}
        ]

        assert """
               --------------.......
               --------------.......
               --------------.......
               OOOOOOOO------.......
               O      O------.......
               O    XXXXX----.......
               OOOOOXXXXX-----------
                    XXXXX-----------
               """ = render(canvas, operations)
      end
    end
  end

  defp build_canvas(size, strategy) do
    Canva.build_canvas(size)
    |> Canva.build_renderable_canvas(strategy.())
  end

  defp render(canvas, operations) do
    Canva.apply_operations(canvas, operations)
    |> Canva.render_canvas()
    |> trim_traling_space_on_each_line()
  end

  defp size(width, height), do: %Size{width: width, height: height}

  defp trim_traling_space_on_each_line(string) do
    string
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing(&1, " "))
    |> Enum.join("\n")
  end
end
