module StoresAppPlugin
  class CatalogSerializer < ApplicationSerializer

    alias_method :profile, :object

    has_many :products, serializer: ProductSerializer

    def products
      profile.products.supplied.unarchived.available
    end

  end
end
