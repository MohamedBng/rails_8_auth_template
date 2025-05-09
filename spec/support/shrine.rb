require "logger"
require "shrine"
require "shrine/storage/memory"

Shrine.logger.level = Logger::FATAL

Shrine.storages = {
  cache:  Shrine::Storage::Memory.new,
  store:  Shrine::Storage::Memory.new,
}

Shrine.plugin :activerecord
