# ExchangeChallenge

For Exchange Code Challenges
run:
```
mix test test/order_book_test.ex
```

Struct Data:
```
%Order{ command: "", price: 0.0, amount: 0.0 }
```

```
%OrderBook{ buy: [], sell: [] }
```

Console
```
iex -S mix
```

```
input_4 = """
{
  "orders": [
      {"command": "sell", "price": 100.003, "amount": 2.4},
      {"command": "buy", "price": 90.394, "amount": 3.445},
      {"command": "buy", "price": 89.394, "amount": 4.3},
      {"command": "sell", "price": 100.013, "amount": 2.2},
      {"command": "buy", "price": 90.15, "amount": 1.305},
      {"command": "buy", "price": 90.394, "amount": 1.0},
      {"command": "sell", "price": 90.394, "amount": 2.2},
      {"command": "sell", "price": 90.15, "amount": 3.4},
      {"command": "buy", "price": 91.33, "amount": 1.8},
      {"command": "buy", "price": 100.01, "amount": 4.0},
      {"command": "sell", "price": 100.15, "amount": 3.8}
  ]
}
"""

order_book =
  OrderBook.json_to_struct(input_4)
  |> OrderBook.list_order()
```

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
