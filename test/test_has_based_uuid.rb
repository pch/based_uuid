require "test_helper"
require "ostruct"

class FakeActiveRecordBase < OpenStruct
  include BasedUUID::HasBasedUUID

  class RecordNotFound < StandardError; end

  class_attribute :primary_key
  self.primary_key = "id"

  class_attribute :fake_datastore
  self.fake_datastore = {}

  def self.create(attrs)
    fake_datastore[attrs[primary_key.to_sym]] = new(attrs)
  end

  def self.find_by(attrs)
    fake_datastore[attrs[primary_key]]
  end

  def self.find_by!(attrs)
    fake_datastore[attrs[primary_key]] or raise RecordNotFound
  end

  def [](key)
    send(key)
  end
end

class User < FakeActiveRecordBase
  has_based_uuid prefix: :user
end

class Article < FakeActiveRecordBase
  has_based_uuid prefix: :article
end

class Transaction < FakeActiveRecordBase
  self.primary_key = "txid"

  has_based_uuid prefix: :tx
end

class Session < FakeActiveRecordBase
  has_based_uuid prefix: :sid, uuid_column: :session_id
end

class TestHasBasedUUID < Minitest::Test
  def setup
    @user = User.create(id: "59a9608b-bbbf-4d1a-9adc-2dc34875e423")
  end

  def test_generic_lookup
    assert_equal @user, BasedUUID.find(@user.based_uuid)

    article = Article.create(id: SecureRandom.uuid)
    assert_equal article, BasedUUID.find(article.based_uuid)
    assert_raises(BasedUUID::Error) { BasedUUID.find("wrong_#{article.based_uuid(prefix: false)}") }
  end

  def test_based_uuid
    assert_equal "user_2sn5g8qexz9md9nq1drd47bs13", @user.based_uuid
    assert_equal "2sn5g8qexz9md9nq1drd47bs13", @user.based_uuid(prefix: false)

    assert_raises(ArgumentError) { User.new.based_uuid }
  end

  def test_based_uuid_for_custom_primary_keys
    assert_equal "tx_34swbe3m298v4sarc4vpppsvja",
                 Transaction.new(txid: "64cf16e1-d049-46c9-9561-84ddad6cee4a").based_uuid
  end

  def test_based_uuid_for_custom_uuid_columns
    assert_equal "sid_5akm5ysprd930remqpbbhc0pca",
                 Session.new(session_id: "aa9d0bec-db0d-48c1-8752-f65ae2c0598a").based_uuid
  end

  def test_find_by_based_uuid
    assert_nil User.find_by_based_uuid(random_user.based_uuid)

    assert_raises(FakeActiveRecordBase::RecordNotFound) do
      User.find_by_based_uuid!(random_user.based_uuid)
    end
    assert_raises(ArgumentError) { User.find_by_based_uuid!("wrong_#{@user.based_uuid(prefix: false)}") }

    User.find_by_based_uuid(@user.based_uuid).tap do |found_user|
      assert_equal @user, found_user
    end
  end

  def test_find_by_based_uuid_for_custom_primary_keys
    tx = Transaction.create(txid: SecureRandom.uuid)

    Transaction.find_by_based_uuid(tx.based_uuid).tap do |found_tx|
      assert_equal tx, found_tx
    end
  end

  def test_find_by_based_uuid_for_custom_uuid_columns
    session = Session.create(session_id: SecureRandom.uuid)

    Session.find_by_based_uuid(session.based_uuid).tap do |found_session|
      assert_equal session, found_session
    end
  end

  private

  def random_user
    User.new(id: SecureRandom.uuid)
  end
end
