module Sprockets
  class Manifest
    def compile_with_non_digest *args
      compile_without_non_digest *args

      files.each do |(digest_path, info)|
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
