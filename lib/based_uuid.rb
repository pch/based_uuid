require "active_support/core_ext/module/attribute_accessors"

require_relative "based_uuid/version"
require_relative "based_uuid/base32_uuid"
require_relative "based_uuid/has_based_uuid"

module BasedUUID
  class Error < StandardError; end

  mattr_accessor :delimiter, default: "_"

  class << self
    def find(token)
      prefix, = split(token)
      registered_models.fetch(prefix.to_sym).find_by_based_uuid(token)
    rescue KeyError
      raise Error, "Unable to find model for `#{prefix}`. Registered prefixes: #{registered_models.keys.join(", ")}"
    end

    def register_model_prefix(prefix, model)
      registered_models[prefix] = model
    end

    def registered_models
      @registered_models ||= {}
    end

    def split(token)
      prefix, _, uuid_base32 = token.to_s.rpartition(delimiter)
      [prefix.presence, uuid_base32]
    end

    def encode(uuid:, prefix: nil)
      uuid_base32 = Base32UUID.encode(uuid)
      return uuid_base32 unless prefix

      "#{prefix}#{delimiter}#{uuid_base32}"
    end

    def decode(token)
      _, uuid_base32 = split(token)
      Base32UUID.decode(uuid_base32)
    end
  end
end
