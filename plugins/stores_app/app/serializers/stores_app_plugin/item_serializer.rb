module StoresAppPlugin
  class ItemSerializer < ApplicationSerializer

    alias_method :item, :object

    attribute :id
    attribute :name
    attribute :supplier_name
    attribute :unit_name
    attribute :image

    attribute :price
    attribute :status_quantity
    attribute :status_quantity_localized

    attribute :status
    attribute :flags
    attribute :statuses

    attribute :quantity_consumer_ordered_more_than_stored

    def image
      image_filename :big
    end

    def flags
      quantity_price_data[:flags]
    end

    def statuses
      quantity_price_data[:statuses]
    end

    def quantity_consumer_ordered_more_than_stored
      scope.instance_variable_get :@quantity_consumer_ordered_more_than_stored
    end

    protected

    def image_filename size
      i = product.own_image || product.supplier_image
      i&.public_filename size
    end

    def product
      item.product
    end

    def quantity_price_data
      @quantity_price_data ||= item.quantity_price_data actor_name
    end

    def actor_name
      instance_options[:actor_name]
    end

    def admin
      scope.instance_variable_get :@admin
    end

  end
end
