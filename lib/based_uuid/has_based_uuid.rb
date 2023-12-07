require "active_support/lazy_load_hooks"
require "active_support/concern"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/class/attribute"
require "active_record"

module BasedUUID
  module HasBasedUUID
    extend ActiveSupport::Concern

    included do
      class_attribute :_based_uuid_prefix
      class_attribute :_based_uuid_column
    end

    class_methods do
      def has_based_uuid(prefix: nil, uuid_column: primary_key)
        include ModelExtensions

        self._based_uuid_prefix = prefix
        self._based_uuid_column = uuid_column

        BasedUUID.register_model_prefix(prefix, self) if prefix
      end
    end
  end

  module ModelExtensions
    extend ActiveSupport::Concern

    class_methods do
      def find_by_based_uuid(token)
        prefix, uuid_base32 = BasedUUID.split(token)
        raise ArgumentError, "Invalid prefix" if prefix && prefix.to_sym != _based_uuid_prefix

        find_by(_based_uuid_column => Base32UUID.decode(uuid_base32))
      end

      def find_by_based_uuid!(token)
        find_by_based_uuid(token) or raise ActiveRecord::RecordNotFound
      end
    end

    def based_uuid(prefix: true)
      raise ArgumentError, "UUID is empty" if _uuid_column_value.blank?

      BasedUUID.encode(uuid: _uuid_column_value, prefix: prefix ? self.class._based_uuid_prefix : nil)
    end

    private

    def _uuid_column_value
      self[self.class._based_uuid_column]
    end
  end
end

ActiveSupport.on_load :active_record do
  include BasedUUID::HasBasedUUID
end
