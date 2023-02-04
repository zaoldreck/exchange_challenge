defmodule OrderBookTest do
  use ExUnit.Case

  test "new function creates an empty OrderBook", %{} do
    assert OrderBook.new == %OrderBook{buy: [], sell: []}
  end

  test "json_to_struct decodes JSON and maps to OrderBook", %{} do
    json = """
    {
      "orders": [
        { "command": "buy", "price": 10.0, "amount": 100.0 },
        { "command": "sell", "price": 5.0, "amount": 50.0 }
      ]
    }
    """

    decoded = OrderBook.json_to_struct(json)
    [first_order, last_order] = decoded

    assert length(decoded) == 2
    assert first_order.command == "buy"
    assert first_order.price == 10.0
    assert first_order.amount == 100.0
    assert last_order.command == "sell"
    assert last_order.price == 5.0
    assert last_order.amount == 50.0
  end

  test "update_order adds order to buy list", %{} do
    order = %Order{command: "buy", price: 10.0, amount: 100.0}
    updated_order_book = OrderBook.update_order(order, %{buy: [], sell: []})

    assert updated_order_book == %{
      buy: [%{price: 10.0, volume: 100.0}],
      sell: []
    }
  end

  test "update_order adds order to sell list", %{} do
    order = %Order{command: "sell", price: 5.0, amount: 50.0}
    updated_order_book = OrderBook.update_order(order, %{buy: [], sell: []})

    assert updated_order_book == %{
      buy: [],
      sell: [%{price: 5.0, volume: 50.0}]
    }
  end

  test "list sorts buy and sell lists", %{} do
    order_book = %OrderBook{
      buy: [%{price: 10.0, volume: 100.0}, %{price: 5.0, volume: 50.0}],
      sell: [%{price: 20.0, volume: 200.0}, %{price: 15.0, volume: 150.0}]
    }

    sorted_order_book = OrderBook.list(order_book)

    assert sorted_order_book == %OrderBook{
      buy: [%{price: 10.0, volume: 100.0}, %{price: 5.0, volume: 50.0}],
      sell: [%{price: 15.0, volume: 150.0}, %{price: 20.0, volume: 200.0}]
    }
  end

  test "Input Example 1" do
    expect_output =
      Jason.decode!("""
      {
        "buy": [
          {
            "price": 90.394,
            "volume": 3.445
          }
        ],
        "sell": [
          {
            "price": 100.003,
            "volume": 2.4
          }
        ]
      }
      """)

    input_1 = """
    {
      "orders": [
         {"command": "sell", "price": 100.003, "amount": 2.4},
         {"command": "buy", "price": 90.394, "amount": 3.445}
      ]
    }
    """

    decoded = OrderBook.json_to_struct(input_1)
    order_book = Enum.reduce(decoded, OrderBook.new(), &OrderBook.update_order/2)

    assert expect_output == order_book |> OrderBook.list() |> Mappable.to_map(keys: :strings)
  end
end
