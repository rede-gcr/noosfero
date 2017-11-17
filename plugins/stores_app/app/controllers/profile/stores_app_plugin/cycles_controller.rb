module StoresAppPlugin
  class CyclesController < ApiController

    def index
      render json: {data: 'ok'}
    end

    protected

  end
end
