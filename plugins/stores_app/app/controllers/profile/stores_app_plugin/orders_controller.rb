module StoresAppPlugin
  class OrdersController < ApiController

    def last
      return render json: nil unless order
      render json: OrderSerializer.new(order, scope: self).to_hash
    end

    protected

  end
end
