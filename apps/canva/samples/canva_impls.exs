canvases_count = 10

generate_canvases = fn size_range, operations_range ->
  Canva.Generators.canvas_generator(size_range, size_range, operations_range)
  |> Enum.take(canvases_count)
end

render_canvas_fn = fn canvas, strategy ->
  canvas
  |> Canva.build_renderable_canvas(strategy)
  |> Canva.render_canvas()
end

render_strategies = [
  {"map based", Canva.build_composable_map_based_render_ctx()},
  {"array based", Canva.build_composable_array_based_render_ctx()}
]

render_strategies
|> Enum.map(fn {name, strategy} ->
  render_canvases = fn canvases ->
    Enum.each(canvases, &render_canvas_fn.(&1, strategy))
  end

  {name, render_canvases}
end)
|> Benchee.run(
  memory_time: 2,
  inputs: %{
    "size from 5x5         to 50x50" => generate_canvases.(5..50, 1..10),
    "size from 10x10       to 100x1000" => generate_canvases.(10..100, 1..10),
    # if we set above 1000x1000 points system crashes
    # I assume we are reaching stack size limit
  }
)
