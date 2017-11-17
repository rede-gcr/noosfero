module StoresAppPlugin
  class OrderSerializer < ApplicationSerializer

    alias_method :order, :object

    attribute :currency_unit

    attribute :admin
    attribute :actor_name
    attribute :errors
    attribute :self_supplier

    attribute :may_edit
    attribute :view_only

    attribute :status
    attribute :total_price
    attribute :remaining_total

    has_many :items

    def currency_unit
      return unless scope.respond_to? :environment, true
      scope.send(:environment).currency_unit
    end

    def admin
      scope.instance_variable_get :@admin
    end

    def actor_name
      instance_options[:actor_name]
    end

    def errors
      instance_options[:errors]
    end

    def self_supplier
      order.self_supplier?
    end

    def may_edit
      order.may_edit? user, admin
    end

    def view_only
      scope.instance_variable_get :@view
    end

    def total_price
      order.total_price actor_name, admin
    end

    def remaining_total
      order.remaining_total actor_name, admin
    end

    def items
      order.items.map do |item|
        ItemSerializer.new(item, scope: scope, actor_name: actor_name).to_hash
      end
    end

    protected

    def user
      return unless scope.respond_to? :user, true
      scope.send :user
    end

  end
end

