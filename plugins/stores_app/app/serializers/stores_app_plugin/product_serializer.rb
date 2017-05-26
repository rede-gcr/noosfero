class StoresAppPlugin::ProductSerializer < ApplicationSerializer

  alias_method :product, :object

  attribute :available
  attribute :highlighted

  attribute :category
  #has_many :qualifiers

  attribute :name

  def category
    product.product_category&.name
  end

end
