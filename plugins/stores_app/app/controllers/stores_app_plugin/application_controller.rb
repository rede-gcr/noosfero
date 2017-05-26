module StoresAppPlugin

  class ApplicationController < ApplicationController

    layout 'stores_app_plugin/layout'

    needs_profile

    def index
      render action: :index
    end

    protected

  end
end
