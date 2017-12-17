module ConsumersCoopPlugin
  class DeliveryMethodsController < DeliveryPlugin::AdminMethodController

    include ConsumersCoopPlugin::ControllerHelper
    include ConsumersCoopPlugin::TranslationHelper

    helper OrdersCyclePlugin::DisplayHelper
    helper ConsumersCoopPlugin::TranslationHelper

    protected

    # inherit routes from core skipping use_relative_controller!
    def url_for options
      options[:controller] = "/#{options[:controller]}" if options.is_a? Hash and options[:controller] and not options[:controller].to_s.starts_with? '/'
      super options
    end
    helper_method :url_for

  end
end
