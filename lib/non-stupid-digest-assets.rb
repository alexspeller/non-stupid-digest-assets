module NonStupidDigestAssets
  mattr_accessor :whitelist
  @@whitelist = []
end

module Sprockets
  class Manifest
    def compile_with_non_digest *args
      compile_without_non_digest *args
      if NonStupidDigestAssets.whitelist.empty?
        files_to_copy = files
      else
        files_to_copy = files.select do |file, info|
          !NonStupidDigestAssets.whitelist.detect do |item|
            info['logical_path'] =~ /#{item}/
          end.nil?
        end
      end
      files_to_copy.each do |(digest_path, info)|
        full_digest_path = File.join dir, digest_path
        full_digest_gz_path = "#{full_digest_path}.gz"
        full_non_digest_path = File.join dir, info['logical_path']
        full_non_digest_gz_path = "#{full_non_digest_path}.gz"
        logger.info "Writing #{full_non_digest_path}"
        FileUtils.cp full_digest_path, full_non_digest_path
        if File.exists? full_digest_gz_path
          logger.info "Writing #{full_non_digest_gz_path}"
          FileUtils.cp full_digest_gz_path, full_non_digest_gz_path
        end
      end
    end

    alias_method_chain :compile, :non_digest
  end
end
