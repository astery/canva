defmodule CanvaServiceTest do
  use ExUnit.Case

  alias CanvaService.Impl

  import Canva.Generators
  import Hammox

  setup :verify_on_exit!

  describe "Impl" do
    test "generate/0 should return an existing renderable canvas id" do
      assert {:ok, id} = Impl.generate_canvas()
      assert {:ok, string} = Impl.show_canvas(id)

      assert is_binary(string)
    end

    test "add_operation/0 should emit an event" do
      assert {:ok, id} = Impl.generate_canvas()
      CanvaService.Events.subscribe_on_canvas_events(id, self())

      {:ok, canvas} = CanvaFiles.load_canvas_from_file(id)
      operation = operation_generator(canvas.size) |> Enum.take(0)
      assert :ok = Impl.add_operation(id, operation)

      assert_receive {:canvas_updated, ^id}
    end
  end
end
