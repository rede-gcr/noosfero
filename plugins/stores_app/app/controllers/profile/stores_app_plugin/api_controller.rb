module StoresAppPlugin
  class ApiController < ActionController::Base

    attr_reader :environment
    include NeedsProfile

    layout false
    before_filter :set_environment
    needs_profile
    before_filter :allow_cors

    protected

    def allow_cors
      headers['Access-Control-Allow-Origin']   = '*'
      headers['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
      headers['Access-Control-Request-Method'] = '*'
      headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    end

    def user
      @user ||= User.find_by private_token: params[:auth_token]
    end

    def set_environment
      @environment = Environment.default
    end

    def order
      @order ||= profile.sales
        .where(consumer_id: user.person.id)
        .order('created_at DESC')
        .first
    end

  end
end
