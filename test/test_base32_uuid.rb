require "test_helper"
require "securerandom"

class TestBase32UUID < Minitest::Test
  UUIDS_V7 = {
    "018c3b49-560c-719f-9daf-bae405f6ffca" => "01hgxmjngce6fsvbxtwg2zdzya",
    "018c3b49-f34a-7e22-90af-13b6f0a69d47" => "01hgxmkwtafrh91brkpvrad7a7",
    "018c3b4a-093a-7072-b1ae-0170b310000e" => "01hgxmm29te1sb3bg1e2sh000e",
    "018c3b4a-22fd-7cbe-8223-68f65e9168d0" => "01hgxmm8qxfjz848v8ysf92t6g",
    "018c3b4a-5826-7d9f-8b35-f19a3f054cfa" => "01hgxmmp16fpfrpdfhk8zgak7t",
    "018c3b4a-6ef7-77cf-a5f6-21e488347729" => "01hgxmmvqqez7tbxh1wj438xs9",
    "018c3b4a-869e-7a10-a397-2fb54a0055d1" => "01hgxmn1myf88a75sfpn500neh",
    "018c3b4a-9a9f-7de7-a77f-9da02aa6da1e" => "01hgxmn6mzfqktezwxm0nadpgy",
    "018c3b4a-ae68-7421-a992-9026a8fc60cb" => "01hgxmnbk8eggtk4mg4tmfrr6b",
    "018c3b4e-44f4-77c9-b226-8e4b2d99166a" => "01hgxmwh7mez4v49me9cpsj5ka"
  }.freeze

  def test_that_it_encodes_uuids_to_base32
    UUIDS_V7.each do |uuid, base32|
      assert_equal base32, BasedUUID::Base32UUID.encode(uuid)
    end
  end

  def test_that_it_decodes_base32_to_uuids
    UUIDS_V7.each do |uuid, base32|
      assert_equal uuid, BasedUUID::Base32UUID.decode(base32)
    end
  end

  def test_that_it_encodes_and_decodes_random_uuids
    100.times do
      uuid = SecureRandom.uuid
      assert_equal uuid, BasedUUID::Base32UUID.decode(BasedUUID::Base32UUID.encode(uuid))
    end
  end

  def test_that_it_handles_invalid_uuids
    assert_raises(ArgumentError) { BasedUUID::Base32UUID.encode("i am not a valid uuid") }
  end

  def test_that_it_handles_invalid_base32
    assert_raises(ArgumentError) { BasedUUID::Base32UUID.decode("i am not a valid base32 string") }
    assert_raises(ArgumentError) { BasedUUID::Base32UUID.decode("ASDFASDFASDFASDFASDF") }
  end
end
