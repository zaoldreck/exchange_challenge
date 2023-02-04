defmodule OrderBook do
  defstruct buy: [], sell: []

  def new do
    %OrderBook{buy: [], sell: []}
  end

  def json_to_struct(json) do
    Jason.decode!(json)
    |> Map.get("orders")
    |> Enum.map(fn order -> Mappable.to_struct(order, Order) end)
  end

  def update_order(order, order_book) do
    # IO.inspect book
    case order.command do
      "buy" ->
        %{order_book | buy: [%{price: order.price, volume: order.amount} | order_book.buy]}

      "sell" ->
        %{order_book | sell: [%{price: order.price, volume: order.amount} | order_book.sell]}
    end
  end

  def group_by_price(records) do
    records
    |> Enum.group_by(& &1.price)
    |> Enum.map(fn {price, records} ->
      %{price: price, volume: Enum.reduce(records, 0, fn item, acc -> item.volume + acc end)}
    end)
  end

  @spec list(atom | %{:buy => any, :sell => any, optional(any) => any}) :: %OrderBook{
          buy: list,
          sell: list
        }
  def list(order_book) do
    buy =
      order_book.buy
      |> OrderBook.group_by_price()
      |> Enum.sort_by(& &1.price, :desc)

    sell =
      order_book.sell
      |> OrderBook.group_by_price()
      |> Enum.sort_by(& &1.price, :asc)

    %OrderBook{
      buy: buy,
      sell: sell
    }
  end

  def list_order(json) do
    Enum.reduce(json, OrderBook.new(), &OrderBook.update_order/2)
    |> OrderBook.list()
  end
end
