module StoresAppPlugin
  class ItemsController < ApiController

    def add
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
      render json: {}
    end

    protected

    def order
      profile.sales
        .of_user(session.id, user)
        .order('created_at DESC')
        .first
    end

    def user
      user = User.find_by email: 'brauliobo@gmail.com'
      user.person
    end

  end
end
