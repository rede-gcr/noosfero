Noosfero::Application.routes.draw do

  get 'store/:profile' => 'stores_app_plugin/application#index'

end
