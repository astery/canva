defmodule CanvaFilesTest do
  use ExUnit.Case

  test "generate_id should generate unique ids" do
    first = CanvaFiles.generate_id()
    second = CanvaFiles.generate_id()
    assert first != second
  end
end
