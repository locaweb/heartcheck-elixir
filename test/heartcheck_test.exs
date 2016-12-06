defmodule HeartCheckTest do
  use ExUnit.Case

  test "created a list of tests" do
    assert length(MyHeart.tests) > 0
  end

  test "it creates a 'catch-all' perform_test/1 for undeclared tests" do
    assert {:error, reason} = MyHeart.perform_test(:banana)
    assert String.contains?(reason, "undefined test")
    assert String.contains?(reason, "banana")
  end

  test "it creates the perform_test/1 function on the macro`ed module" do
    assert :erlang.function_exported(MyHeart, :perform_test, 1)
  end

  test "it stringifies the original declartion" do
    assert :ok = MyHeart.perform_test(:string_test)

    assert {:error, "undefined test: \"string_test\""} =
      MyHeart.perform_test("string_test")
  end

  test "it makes MyHeart respond to the defined tests" do
    assert_exists = fn(test) ->
      assert {:error, "undefined test: #{inspect(test)}"} !=
        MyHeart.perform_test(test)
    end

    assert_exists.(:redis)
    assert_exists.(:module)
    assert_exists.(:string_test)
    assert_exists.(:cas)
  end
end
