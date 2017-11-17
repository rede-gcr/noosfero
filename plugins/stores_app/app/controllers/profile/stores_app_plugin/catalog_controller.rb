module StoresAppPlugin
  class CatalogController < ApiController

    def listing
      render json: CatalogSerializer.new(profile).to_hash
    end

    protected

  end
end
