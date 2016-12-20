require "sprockets/manifest"

module NonStupidDigestAssets
  mattr_accessor :whitelist, :destupidify_mode
  @@whitelist = []
  @@destupidify_mode = :copy

  class << self
    def assets(assets)
      return assets if whitelist.empty?
      whitelisted_assets(assets)
    end

    private

    def whitelisted_assets(assets)
      assets.select do |logical_path, digest_path|
        whitelist.any? do |item|
          item === logical_path
        end
      end
    end
  end

  module CompileWithNonDigest
    def compile *args
      paths = super
      NonStupidDigestAssets.assets(assets).each do |(logical_path, digest_path)|
        full_digest_path = File.join dir, digest_path
        full_digest_gz_path = "#{full_digest_path}.gz"
        full_non_digest_path = File.join dir, logical_path
        full_non_digest_gz_path = "#{full_non_digest_path}.gz"

        destupidify_digest_asset full_digest_path, full_non_digest_path
        destupidify_digest_asset full_digest_gz_path, full_non_digest_gz_path
      end
      paths
    end

    private

    def destupidify_digest_asset(digest_path, non_digest_path)
      if File.exists? digest_path
        logger.debug "Writing #{non_digest_path}"
        if NonStupidDigestAssets.destupidify_mode == :move
          FileUtils.mv digest_path, non_digest_path
        else
          FileUtils.copy_file digest_path, non_digest_path, :preserve_attributes
        end
      else
        logger.debug "Could not find: #{digest_path}"
      end
    end
  end
end

Sprockets::Manifest.send(:prepend, NonStupidDigestAssets::CompileWithNonDigest)
