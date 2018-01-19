defmodule HeartCheck.ExecutorTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias HeartCheck.Executor

  @tag :capture_log
  test "it executes" do
    assert length(Executor.execute(MyHeart)) > 0
  end

  @tag :capture_log
  test "it handles timeouts" do
    assert length(Executor.execute(MyTimedOutHeart)) > 0
  end

  test "it logs execution" do
    log =
      capture_log(fn ->
        Executor.execute(MyHeart)
      end)

    assert log =~ "[HeartCheck]"
    assert log =~ "Performing cas"
    assert log =~ "cas: ERROR"
  end
end
