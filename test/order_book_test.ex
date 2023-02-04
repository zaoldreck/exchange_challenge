defmodule OrderBookTest do
  use ExUnit.Case

  test "new function creates an empty OrderBook", %{} do
    assert OrderBook.new() == %OrderBook{buy: [], sell: []}
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

    order_book =
      OrderBook.json_to_struct(input_1)
      |> OrderBook.list_order()

    assert expect_output == order_book |> Mappable.to_map(keys: :strings)
  end

  # test "Input Example 2" do
  #   expect_output =
  #     Jason.decode!("""
  #     {
  #       "buy": [
  #         {
  #           "price": 90.394,
  #           "volume": 4.445
  #         },
  #         {
  #           "price": 90.15,
  #           "volume": 1.305
  #         },
  #         {
  #           "price": 89.394,
  #           "volume": 4.3
  #         }
  #       ],
  #       "sell": [
  #         {
  #           "price": 100.003,
  #           "volume": 2.4
  #         },
  #         {
  #           "price": 100.013,
  #           "volume": 2.2
  #         }
  #       ]
  #     }
  #     """)

  #   input_2 = """
  #   {
  #     "orders": [
  #        {"command": "sell", "price": 100.003, "amount": 2.4},
  #        {"command": "buy", "price": 90.394, "amount": 3.445},
  #        {"command": "buy", "price": 89.394, "amount": 4.3},
  #        {"command": "sell", "price": 100.013, "amount": 2.2},
  #        {"command": "buy", "price": 90.15, "amount": 1.305},
  #        {"command": "buy", "price": 90.394, "amount": 1.0}
  #     ]
  #   }
  #   """

  #   order_book = OrderBook.json_to_struct(input_2)
  #   |> OrderBook.list_order

  #   assert expect_output == order_book |> Mappable.to_map(keys: :strings)
  # end

  # test "Input Example 3" do
  #   expect_output =
  #     Jason.decode!("""
  #     {
  #       "buy": [
  #         {
  #           "price": 90.394,
  #           "volume": 2.245
  #         },
  #         {
  #           "price": 90.15,
  #           "volume": 1.305
  #         },
  #         {
  #           "price": 89.394,
  #           "volume": 4.3
  #         }
  #       ],
  #       "sell": [
  #         {
  #           "price": 100.003,
  #           "volume": 2.4
  #         },
  #         {
  #           "price": 100.013,
  #           "volume": 2.2
  #         }
  #       ]
  #     }
  #     """)

  #   input_3 = """
  #   {
  #     "orders": [
  #        {"command": "sell", "price": 100.003, "amount": 2.4},
  #        {"command": "buy", "price": 90.394, "amount": 3.445},
  #        {"command": "buy", "price": 89.394, "amount": 4.3},
  #        {"command": "sell", "price": 100.013, "amount": 2.2},
  #        {"command": "buy", "price": 90.15, "amount": 1.305},
  #        {"command": "buy", "price": 90.394, "amount": 1.0},
  #        {"command": "sell", "price": 90.394, "amount": 2.2}
  #     ]
  #   }
  #   """

  #   order_book = OrderBook.json_to_struct(input_3)
  #   |> OrderBook.list_order

  #   assert expect_output == order_book |> Mappable.to_map(keys: :strings)
  # end

  # test "Input Example 4" do
  #   expect_output =
  #     Jason.decode!("""
  #     {
  #       "buy": [
  #         {
  #           "price": 100.01,
  #           "volume": 1.6
  #         },
  #         {
  #           "price": 91.33,
  #           "volume": 1.8
  #         },
  #         {
  #           "price": 90.15,
  #           "volume": 0.15
  #         },
  #         {
  #           "price": 89.394,
  #           "volume": 4.3
  #         }
  #       ],
  #       "sell": [
  #         {
  #           "price": 100.013,
  #           "volume": 2.2
  #         },
  #         {
  #           "price": 100.15,
  #           "volume": 3.8
  #         }
  #       ]
  #     }
  #     """)

  #   input_4 = """
  #   {
  #     "orders": [
  #        {"command": "sell", "price": 100.003, "amount": 2.4},
  #        {"command": "buy", "price": 90.394, "amount": 3.445},
  #        {"command": "buy", "price": 89.394, "amount": 4.3},
  #        {"command": "sell", "price": 100.013, "amount": 2.2},
  #        {"command": "buy", "price": 90.15, "amount": 1.305},
  #        {"command": "buy", "price": 90.394, "amount": 1.0},
  #        {"command": "sell", "price": 90.394, "amount": 2.2},
  #        {"command": "sell", "price": 90.15, "amount": 3.4},
  #        {"command": "buy", "price": 91.33, "amount": 1.8},
  #        {"command": "buy", "price": 100.01, "amount": 4.0},
  #        {"command": "sell", "price": 100.15, "amount": 3.8}
  #     ]
  #   }
  #   """

  #   order_book = OrderBook.json_to_struct(input_4)
  #   |> OrderBook.list_order

  #   assert expect_output == order_book |> Mappable.to_map(keys: :strings)
  # end
end
