defmodule CanvaServiceTest do
  use ExUnit.Case

  alias CanvaService.Impl

  describe "Impl" do
    test "generate/0 should return an existing renderable canvas id" do
      assert {:ok, id} = Impl.generate_canvas()
      assert {:ok, string} = Impl.show_canvas(id)

      assert is_binary(string)
    end
  end
end
