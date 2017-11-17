module StoresAppPlugin
  class ProductSerializer < ApplicationSerializer

    alias_method :product, :object

    attribute :id

    attribute :available
    attribute :highlighted

    attribute :category
    #has_many :qualifiers

    attribute :name

    attribute :image

    attribute :distributed
    attribute :supplier_name

    attribute :created_at
    attribute :updated_at

    def category
      product.product_category&.name
    end

    def image
      image_filename :big
    end

    def distributed
      product.distributed?
    end

    def supplier_name
      product.supplier&.name
    end

    protected

    def image_filename size
      i = product.own_image || product.supplier_image
      i&.public_filename size
    end

  end
end
