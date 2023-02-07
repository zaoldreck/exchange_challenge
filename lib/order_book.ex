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
    # legacy
    case order.command do
      "buy" ->
        %{order_book | buy: [%{price: order.price, volume: order.amount} | order_book.buy]}

      "sell" ->
        %{order_book | sell: [%{price: order.price, volume: order.amount} | order_book.sell]}
    end
  end

  def handle_command(
        %{command: "sell", price: price, amount: amount} = order,
        %OrderBook{buy: buy, sell: sell} = order_book
      ) do
    remaining_amount = amount

    {updated_buy, remaining_amount} =
      Enum.reduce(buy, {[], remaining_amount}, fn %{price: record_price, volume: record_volume},
                                                  {acc, remaining_amount} ->
        if record_price >= price do
          updated_volume =
            Decimal.sub(Decimal.from_float(record_volume), Decimal.from_float(remaining_amount))
            |> Decimal.to_float()

          if updated_volume >= 0 do
            remaining_amount = 0
            {[%{price: record_price, volume: updated_volume} | acc], remaining_amount}
          else
            remaining_amount = updated_volume
            {[%{price: record_price, volume: 0} | acc], -1 * remaining_amount}
          end
        else
          {[%{price: record_price, volume: record_volume} | acc], remaining_amount}
        end
      end)

    updated_buy = updated_buy |> filter_out_zero_volume

    update_sell =
      if remaining_amount > 0 do
        [%{price: order.price, volume: remaining_amount} | order_book.sell]
      else
        [%{price: order.price, volume: 0} | order_book.sell]
      end
      |> filter_out_zero_volume

    %OrderBook{buy: updated_buy, sell: update_sell}
  end

  def handle_command(
        %{command: "buy", price: price, amount: amount} = order,
        %OrderBook{buy: buy, sell: sell} = order_book
      ) do
    remaining_amount = amount

    {updated_sell, remaining_amount} =
      Enum.reduce(sell, {[], remaining_amount}, fn %{price: record_price, volume: record_volume},
                                                   {acc, remaining_amount} ->
        if record_price <= price do
          updated_volume =
            Decimal.sub(Decimal.from_float(record_volume), Decimal.from_float(remaining_amount))
            |> Decimal.to_float()

          if updated_volume >= 0 do
            remaining_amount = 0
            {[%{price: record_price, volume: updated_volume} | acc], remaining_amount}
          else
            remaining_amount = updated_volume
            {[%{price: record_price, volume: 0} | acc], -1 * remaining_amount}
          end
        else
          {[%{price: record_price, volume: record_volume} | acc], remaining_amount}
        end
      end)

    updated_sell = updated_sell |> filter_out_zero_volume

    updated_buy =
      if remaining_amount > 0 do
        [%{price: order.price, volume: remaining_amount} | order_book.buy]
      end

    %OrderBook{sell: updated_sell, buy: updated_buy}
  end

  defp filter_out_zero_volume(orders) do
    Enum.filter(orders, fn order -> order.volume > 0 end)
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
    Enum.reduce(json, OrderBook.new(), &OrderBook.handle_command/2)
    |> OrderBook.list()
    |> MatchingEngine.process_orders()
  end
end
