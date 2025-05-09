require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("public", prefix: "uploads/cache"), # temporary
  store: Shrine::Storage::FileSystem.new("public", prefix: "uploads")       # permanent
}

Shrine.plugin :activerecord           # loads Active Record integration
Shrine.plugin :cached_attachment_data # enables retaining cached file across form redisplays
Shrine.plugin :restore_cached_data    # extracts metadata for assigned cached files
Shrine.plugin :determine_mime_type    # determines MIME type from file content
Shrine.plugin :instrumentation, logger: Rails.logger
Shrine.plugin :derivatives            # enables processing worker & versions
Shrine.plugin :validation_helpers     # provides common validation helpers
Shrine.plugin :url_options, store: { host: "http://localhost:3000" } # Set your host

# Optional: If you want to process derivatives in the background using something like Sidekiq
# Shrine.plugin :backgrounding
# Shrine::Attacher.promote_block do
#   # Replace with your background job worker, e.g., PromoteJob.perform_async(self.class.name, record.class.name, record.id, name.to_s, file_data)
#   # For now, we'll do it synchronously for simplicity
#   self.promote
# end
# Shrine::Attacher.destroy_block do
#   # Replace with your background job worker, e.g., DestroyJob.perform_async(self.class.name, data)
#   # For now, we'll do it synchronously for simplicity
#   self.destroy
# end
