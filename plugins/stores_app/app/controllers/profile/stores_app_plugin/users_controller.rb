module StoresAppPlugin
  class UsersController < ApiController

    def signin
      @user = User.authenticate params[:login], params[:password]
      if @user
        render json: UserSerializer.new(@user).to_hash
      else
        render json: {error: 'invalid_login_pass'}
      end
    end

    protected

  end
end
