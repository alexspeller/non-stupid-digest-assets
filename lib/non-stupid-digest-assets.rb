module NonStupidDigestAssets
  mattr_accessor :whitelist
  @@whitelist = []

  class << self
    def files(files)
      return files if whitelist.empty?
      whitelisted_files(files)
    end

    private

    def whitelisted_files(files)
      files.select do |file, info|
        whitelist.any? do |item|
          case item
          when Regexp
            info['logical_path'] =~ item
          else
            info['logical_path'] == item
          end
        end
      end
    end
  end
end

module Sprockets
  class Manifest
    def compile_with_non_digest *args
      compile_without_non_digest *args

      NonStupidDigestAssets.files(files).each do |(digest_path, info)|
        full_digest_path = File.join dir, digest_path
        full_digest_gz_path = "#{full_digest_path}.gz"
        full_non_digest_path = File.join dir, info['logical_path']
        full_non_digest_gz_path = "#{full_non_digest_path}.gz"

        if File.exists? full_digest_path
          logger.debug "Writing #{full_non_digest_path}"
          FileUtils.cp full_digest_path, full_non_digest_path
        else
          logger.debug "Could not find: #{full_digest_path}"
        end
        if File.exists? full_digest_gz_path
          logger.debug "Writing #{full_non_digest_gz_path}"
          FileUtils.cp full_digest_gz_path, full_non_digest_gz_path
        else
          logger.debug "Could not find: #{full_digest_gz_path}"
        end
      end
    end

    alias_method_chain :compile, :non_digest
  end
end
