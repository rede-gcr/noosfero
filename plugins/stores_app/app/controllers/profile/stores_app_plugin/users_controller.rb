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

    def signup
      @user = User.find_by email: params[:email]
      return render json: {error: 'user_exists'} if @user

      user_params   = params.slice(:name, :email, :phone, :password)
        .merge(login: generate_login, password_confirmation: params[:password])
      person_params = params.slice(:name, :email)
        .merge(identifier: user_params[:login], cell_phone: params[:phone])

      @user = User.new user_params
      @user.person = Person.new person_params
      @user.person.environment = environment

      if @user.valid?
        ApplicationRecord.transaction do
          @user.save!
          @user.person.user = @user
          @user.person.save!
        end
        profile.add_member @user.person

        render json: UserSerializer.new(@user).to_hash
      else
        @user.person.valid?
        fields = @user.errors.keys + @user.person.errors.keys
        render json: {error: 'invalid_fields', fields: fields}
      end
    end

    protected

    def generate_login
      login = params[:name].parameterize
      1.step do |i|
        break unless Profile[login]
        login = "#{params[:name].parameterize}#{i}"
      end
      login
    end

  end
end
