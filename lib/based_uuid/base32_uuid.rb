module BasedUUID
  class Base32UUID
    CROCKFORDS_ALPHABET = "0123456789abcdefghjkmnpqrstvwxyz".freeze
    CHARACTER_MAP = CROCKFORDS_ALPHABET.bytes.freeze

    ENCODED_LENGTH = 26
    BITS_PER_CHAR = 5
    ZERO = "0".ord
    MASK = 0x1f
    UUID_LENGTH = 32

    UUID_VALIDATION_REGEXP = /\A[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\z/
    UUID_REGEXP = /\A(.{8})(.{4})(.{4})(.{4})(.{12})\z/
    BASE32_VALIDATION_REGEXP = /\A[#{CROCKFORDS_ALPHABET}]{26}\z/

    class << self
      def encode(uuid)
        raise ArgumentError, "Invalid UUID" if uuid !~ UUID_VALIDATION_REGEXP

        input = uuid.delete("-").to_i(16)
        encoded = Array.new(ENCODED_LENGTH, ZERO)
        i = ENCODED_LENGTH - 1

        while input > 0
          encoded[i] = CHARACTER_MAP[input & MASK]
          input >>= BITS_PER_CHAR
          i -= 1
        end

        encoded.pack("c*")
      end

      def decode(str)
        raise ArgumentError, "Invalid base32 string" if str !~ BASE32_VALIDATION_REGEXP

        decoded = 0

        str.each_byte do |byte|
          value = CHARACTER_MAP.index(byte)
          decoded = (decoded << BITS_PER_CHAR) | value
        end

        uuid = decoded.to_s(16)
        uuid.rjust(UUID_LENGTH, "0").scan(UUID_REGEXP).join("-")
      end
    end
  end
end
