module ConsumersCoopPlugin::TranslationHelper

  protected

  # included here to be used on controller's t calls
  include TermsHelper

  def i18n_scope
    'consumers_coop_plugin'
  end

end
