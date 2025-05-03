Rails.application.configure do
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

  config.i18n.available_locales = [:en, :fr]

  config.i18n.default_locale = :en

  config.i18n.fallbacks = true
end
