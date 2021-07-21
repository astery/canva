defmodule Canva.Generators do
  @moduledoc false

  alias Canva.Size
  alias Canva.Canvas
  alias Canva.Operations.Rectangle
  alias Canva.Operations.Flood

  import StreamData
  import ExUnitProperties

  @dialyzer :no_return

  def size_generator(width_range, height_range \\ nil) do
    gen all width <- integer(width_range),
            height <- integer(height_range || width_range) do
      %Size{width: width, height: height}
    end
  end

  def canva_char_generator() do
    string(:ascii, length: 1)
  end

  # Creates inbound rectangles (all drawn points are inside canvas)
  def rectangle_operation_generator(canvas_size) do
    canvas_width = canvas_size.width
    canvas_height = canvas_size.height
    half_canvas_width = Integer.floor_div(canvas_size.width, 2)
    half_canvas_height = Integer.floor_div(canvas_size.height, 2)

    rect_size_generator =
      frequency([
        {4, size_generator(0..half_canvas_width, 0..half_canvas_height)},
        {1, size_generator(0..canvas_width, 0..canvas_height)}
      ])

    gen all size <- rect_size_generator,
            x <- integer(0..(canvas_width - size.width)),
            y <- integer(0..(canvas_height - size.height)),
            outline <- canva_char_generator(),
            fill <- canva_char_generator() do
      %Rectangle{x: x, y: y, size: size, outline_char: outline, fill_char: fill}
    end
  end

  def flood_operation_generator(canvas_size) do
    gen all x <- integer(0..canvas_size.width),
            y <- integer(0..canvas_size.height),
            fill <- canva_char_generator() do
      %Flood{x: x, y: y, fill_char: fill}
    end
  end

  def operation_generator(canvas_size) do
    frequency([
      {4, rectangle_operation_generator(canvas_size)},
      {1, flood_operation_generator(canvas_size)}
    ])
  end

  def canvas_generator(width_range, height_range \\ nil, operations_count \\ 0..1000) do
    gen all canvas_size <- size_generator(width_range, height_range),
            operations <- list_of(operation_generator(canvas_size), length: operations_count),
            empty <- canva_char_generator() do
      %Canvas{size: canvas_size, operations: operations, empty_char: empty}
    end
  end
end
