class StoresAppPlugin::CatalogSerializer < ApplicationSerializer

  alias_method :profile, :object

  has_many :products, serializer: ProductSerializer

  def products
    profile.distributed_products.unarchived.available
  end

end
