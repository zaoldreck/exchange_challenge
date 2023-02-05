defmodule MatchingEngine do
  def process_orders(order_book) do
    match_prices(order_book.buy, order_book.sell, order_book)
  end

  def match_prices([], [], order_book) do
    order_book
  end

  def match_prices([buy_head | _buy_tail], [sell_head | _sell_tail], order_book) do
    match_price(buy_head, sell_head, order_book)
  end

  def match_price(
        %{price: buy_price, volume: buy_volume},
        %{price: sell_price, volume: sell_volume},
        order_book
      ) do
    if buy_price == sell_price do
      [buy_volume, sell_volume] = match_buy_sell_volume(buy_volume, sell_volume)
      edit_volume(order_book, buy_price, buy_volume, sell_price, sell_volume)
    else
      order_book
    end
  end

  def match_buy_sell_volume(buy_volume, sell_volume) do
    if buy_volume > sell_volume do
      [buy_volume - sell_volume, 0]
    else
      [0, sell_volume - buy_volume]
    end
  end

  def edit_volume(order_book, buy_price, buy_volume, sell_price, sell_volume) do
    buy = edit_and_filter_out_zero_volume(order_book.buy, buy_price, buy_volume)
    sell = edit_and_filter_out_zero_volume(order_book.sell, sell_price, sell_volume)

    %OrderBook{buy: buy, sell: sell}
  end

  def edit_and_filter_out_zero_volume(list, order_price, order_volume) do
    list
    |> Enum.map(fn order ->
      if order.price == order_price, do: %{order | volume: order_volume}, else: order
    end)
    |> Enum.filter(fn %{volume: volume} -> volume > 0 end)
  end
end
