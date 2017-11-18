module StoresAppPlugin
  class UserSerializer < ApplicationSerializer

    alias_method :user, :object

    attribute :name
    attribute :email
    attribute :phone
    attribute :auth_token

    def name
      user.person.name
    end

    def auth_token
      user.private_token
    end

  end
end
