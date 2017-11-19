module StoresAppPlugin
  class ItemsController < ApiController

    def add
      create_order_if_needed

      @product = Product.find params[:product_id]
      @item    = order.items.find{ |i| i.product == @product }
      @item  ||= order.items.build product: @product, quantity_consumer_ordered: 0
      @item.quantity_consumer_ordered += 1
      @item.save

      render json: OrderSerializer.new(order, scope: self).to_hash
    end

    def remove
      @item = order.items.find params[:id]
      @item.destroy
      render json: OrderSerializer.new(order, scope: self).to_hash
    end

    protected

    def create_order_if_needed
      return if order
      @order = profile.sales.create! consumer: user.person
    end

  end
end
