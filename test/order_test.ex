defmodule OrderTest do
  use ExUnit.Case

  test "Order structure is correct" do
    order = %Order{command: "buy", price: 10.0, amount: 100.0}
    assert order.command == "buy"
    assert order.price == 10.0
    assert order.amount == 100.0
  end

  test "Order default values are correct" do
    order = %Order{}
    assert order.command == ""
    assert order.price == 0.0
    assert order.amount == 0.0
  end
end
