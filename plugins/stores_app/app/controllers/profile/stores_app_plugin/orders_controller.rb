module StoresAppPlugin
  class OrdersController < ApiController

    def last
      render json: OrderSerializer.new(last_order, scope: self).to_hash
    end

    protected

    def last_order
      profile.sales
        .of_user(session.id, user)
        .order('created_at DESC')
        .first
    end

  end
end
