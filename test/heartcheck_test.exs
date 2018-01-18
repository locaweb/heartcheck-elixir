defmodule HeartCheckTest do
  use ExUnit.Case, async: false

  test "created a list of checks" do
    assert length(MyHeart.checks()) > 0
  end

  test "it creates a 'catch-all' perform_check/1 for undeclared checks" do
    assert {:error, reason} = MyHeart.perform_check(:banana)
    assert String.contains?(reason, "undefined check")
    assert String.contains?(reason, "banana")
  end

  test "it creates the perform_check/1 function on the macro`ed module" do
    assert :erlang.function_exported(MyHeart, :perform_check, 1)
  end

  test "it stringifies the original declartion" do
    assert :ok = MyHeart.perform_check(:string_test)

    assert {:error, ~S(undefined check: "string_test")} = MyHeart.perform_check("string_test")
  end

  test "it makes MyHeart respond to the defined checks" do
    assert_exists = fn check ->
      assert {:error, "undefined check: #{inspect(check)}"} != MyHeart.perform_check(check)
    end

    assert_exists.(:redis)
    assert_exists.(:module)
    assert_exists.(:string_test)
    assert_exists.(:cas)
    assert_exists.(:domain_name)
    assert_exists.(:domain_lazy)
    assert_exists.(:localhost)
  end

  test "macros do not hardcode configuration into compiled code" do
    current_config = Application.get_env(:heartcheck, :config)

    on_exit(fn ->
      Application.put_env(:heartcheck, :config, current_config)
    end)

    assert :ok = MyHeart.perform_check(:config_test)

    Application.put_env(:heartcheck, :config, "something else")

    assert {:error, ~s(unexpected value: "something else")} = MyHeart.perform_check(:config_test)
  end
end
