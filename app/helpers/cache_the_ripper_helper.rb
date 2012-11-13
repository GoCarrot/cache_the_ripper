module CacheTheRipperHelper
  def cache_version(identifier)
    @@cache_version ||= JSON.parse(File.read(File.join(Rails.root, "app", "views", "cache_version.json"))).symbolize_keys
    @@cache_version[identifier]
  end
end
