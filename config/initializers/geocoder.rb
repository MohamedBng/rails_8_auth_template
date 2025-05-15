Geocoder.configure(
  # Geocoding options
  timeout: 5,                 # geocoding service timeout (secs)
  lookup: :nominatim,         # name of geocoding service (symbol)
  # ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  language: I18n.locale,      # ISO-639 language code (utilise la locale actuelle)
  use_https: true,            # use HTTPS for lookup requests? (if supported)
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # api_key: nil,               # API key for geocoding service
  cache: Rails.cache,         # cache object (must respond to #[], #[]=, and #del)

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  always_raise: [Geocoder::OverQueryLimitError, Geocoder::RequestDenied, Geocoder::InvalidRequest, Geocoder::InvalidApiKey],

  # Calculation options
  units: :km,                 # :km for kilometers or :mi for miles
  distances: :linear,         # :spherical or :linear
  
  # Cache options
  cache_options: {
    expiration: 24.hours,     # Expire les résultats après 24 heures
    prefix: 'geocoder:'
  }
)
