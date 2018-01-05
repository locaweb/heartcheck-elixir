defmodule HeartCheckTest do
  use ExUnit.Case

  test "created a list of checks" do
    assert length(MyHeart.checks) > 0
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

    assert {:error, ~S(undefined check: "string_test")} =
      MyHeart.perform_check("string_test")
  end

  test "it makes MyHeart respond to the defined checks" do
    assert_exists = fn(check) ->
      assert {:error, "undefined check: #{inspect(check)}"} !=
        MyHeart.perform_check(check)
    end

    assert_exists.(:redis)
    assert_exists.(:module)
    assert_exists.(:string_test)
    assert_exists.(:cas)
    assert_exists.(:domain_name)
  end
end
