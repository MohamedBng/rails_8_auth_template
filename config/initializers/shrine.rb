require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads")
}

Shrine.plugin :activerecord
Shrine.plugin :cached_attachment_data
Shrine.plugin :restore_cached_data
Shrine.plugin :determine_mime_type
Shrine.plugin :instrumentation, logger: Rails.logger
Shrine.plugin :derivatives
Shrine.plugin :validation_helpers
Shrine.plugin :url_options, store: { host: "http://localhost:3000" }
Shrine.plugin :derivatives, delete: true
