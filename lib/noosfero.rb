require_relative 'noosfero/version'
require_relative 'noosfero/constants'

module Noosfero

  def self.root(default = nil)
    ENV.fetch('RAILS_RELATIVE_URL_ROOT', default)
  end

  def self.pattern_for_controllers_in_directory(dir)
    disjunction = controllers_in_directory(dir).join('|')
    pattern = disjunction.blank? ? '' : ('(' + disjunction + ')')
    Regexp.new(pattern)
  end

  mattr_accessor :locales
  self.locales = {
    'en' => 'English', # used by Rails and enforce_available_locales!
    'en_US' => 'English',
    'pt_BR' => 'Português',
    'fr_FR' => 'Français',
    'hy_AM' => 'հայերեն լեզու',
    'de_DE' => 'Deutsch',
    'ru_RU' => 'русский язык',
    'es_ES' => 'Español',
    #'eo' => 'Esperanto',
    'it_IT' => 'Italiano'
  }

  mattr_accessor :available_locales
  self.available_locales = self.locales.keys
  I18n.available_locales = self.available_locales

  mattr_accessor :default_locale
  self.default_locale = I18n.default_locale = FastGettext.default_locale = 'en_US'

  class << self

    def each_locale
      locales.keys.sort.each do |key|
        yield(key, locales[key])
      end
    end
    def with_locale(locale)
      orig_locale = FastGettext.locale
      FastGettext.set_locale(locale)
      yield
      FastGettext.set_locale(orig_locale)
    end

    def session_secret
      require 'fileutils'
      target_dir = File.join(File.dirname(__FILE__), '../tmp')
      FileUtils.mkdir_p(target_dir)
      file = File.join(target_dir, 'session.secret')
      if !File.exists?(file)
        secret = (1..128).map { %w[0 1 2 3 4 5 6 7 8 9 a b c d e f][rand(16)] }.join('')
        File.open(file, 'w') do |f|
          f.puts secret
        end
      end
      File.read(file).strip
    end
  end

  def self.identifier_format
    '[a-z0-9][a-z0-9~.*]*([_\-][a-z0-9~.|:*]+)*'
  end

  # All valid identifiers, plus ~ meaning "the current user". See
  # ApplicationController#redirect_to_current_user
  def self.identifier_format_in_url
    "(#{identifier_format}|~)"
  end

  def self.default_hostname
    Environment.table_exists? && Environment.default ? Environment.default.default_hostname : 'localhost'
  end

  private

  def self.controllers_in_directory(dir)
    app_controller_path = Dir.glob(Rails.root.join('app', 'controllers', dir, '*_controller.rb'))
    app_controller_path.map do |item|
      item.gsub(/^.*\/([^\/]+)_controller.rb$/, '\1')
    end
  end

  def self.url_options
    case Rails.env
    when 'development'
      development_url_options
    when 'cucumber'
      if Capybara.current_driver == :selenium
        { :host => Capybara.current_session.server.host, :port => Capybara.current_session.server.port }
      end
    end || { }
  end

  def self.development_url_options
    @development_url_options || {}
  end

end

