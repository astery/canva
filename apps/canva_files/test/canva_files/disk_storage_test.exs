defmodule CanvaFiles.DiskStorageTest do
  use CanvaFiles.BehaviourCase, implementation: CanvaFiles.DiskStorage

  setup_all do
    CanvaFiles.DiskStorage.clear_storage()
  end
end
