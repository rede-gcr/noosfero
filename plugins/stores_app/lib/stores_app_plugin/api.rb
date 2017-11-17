module StoresAppPlugin
  class API < Grape::API

    get '/hello' do
      present 'teste'
    end

  end
end
