require "test_helper"

class TestBasedUUID < Minitest::Test
  class DummyModel1; end
  class DummyModel2; end

  def teardown
    BasedUUID.delimiter = "_"
  end

  def test_that_it_has_a_version_number
    refute_nil ::BasedUUID::VERSION
  end

  def test_encoding
    uuid = "018c3b49-560c-719f-9daf-bae405f6ffca"
    base32 = "01hgxmjngce6fsvbxtwg2zdzya"

    assert_equal "example_#{base32}", BasedUUID.encode(uuid:, prefix: "example")
    assert_equal base32, BasedUUID.encode(uuid:, prefix: nil)

    BasedUUID.delimiter = "-"

    assert_equal "example-#{base32}", BasedUUID.encode(uuid:, prefix: "example")
  end

  def test_decoding
    base32 = "01hgxmjngce6fsvbxtwg2zdzya"

    assert_equal "018c3b49-560c-719f-9daf-bae405f6ffca", BasedUUID.decode(base32)
    assert_equal "018c3b49-560c-719f-9daf-bae405f6ffca", BasedUUID.decode("example_#{base32}")
    assert_equal "018c3b49-560c-719f-9daf-bae405f6ffca", BasedUUID.decode("anyprefixwillworkhere_#{base32}")
  end

  def test_splitting_tokens_with_prefixes
    BasedUUID.split("example_01hgxpfwgfexf87n5rxge96jkm").tap do |prefix, uuid_base32|
      assert_equal "example", prefix
      assert_equal "01hgxpfwgfexf87n5rxge96jkm", uuid_base32
    end

    BasedUUID.delimiter = "-"
    BasedUUID.split("example-01hgxpfwgfexf87n5rxge96jkm").tap do |prefix, uuid_base32|
      assert_equal "example", prefix
      assert_equal "01hgxpfwgfexf87n5rxge96jkm", uuid_base32
    end
  end

  def test_splitting_tokens_without_prefixes
    BasedUUID.split("01hgxpfwgfexf87n5rxge96jkm").tap do |prefix, uuid_base32|
      assert_nil prefix
      assert_equal "01hgxpfwgfexf87n5rxge96jkm", uuid_base32
    end

    BasedUUID.split("01hgxmmp16fpfrpdfhk8zgak7t").tap do |prefix, uuid_base32|
      assert_nil prefix
      assert_equal "01hgxmmp16fpfrpdfhk8zgak7t", uuid_base32
    end
  end

  def test_that_it_registeres_models
    BasedUUID.register_model_prefix("dummy1", DummyModel1)
    BasedUUID.register_model_prefix("dummy2", DummyModel2)

    assert_equal DummyModel1, BasedUUID.registered_models["dummy1"]
    assert_equal DummyModel2, BasedUUID.registered_models["dummy2"]
    assert_nil BasedUUID.registered_models["dummy3"]
  end
end
