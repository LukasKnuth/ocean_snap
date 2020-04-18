require "test_helper"
require "date"

class BackupRetentionTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BackupRetention::VERSION
  end

  def test_retention_month
    retention = Retention.new(5, 4, 2)

    backups = (1..30).reverse_each.map {|day| {created_at: Date.new(2020, 4, day)} }
    result = retention.retain(backups)

    expected = [
        {created_at: Date.new(2020, 4, 30), type: :daily},
        {created_at: Date.new(2020, 4, 29), type: :daily},
        {created_at: Date.new(2020, 4, 28), type: :daily},
        {created_at: Date.new(2020, 4, 27), type: :daily},
        {created_at: Date.new(2020, 4, 26), type: :daily},
        {created_at: Date.new(2020, 4, 24), type: :weekly},
        {created_at: Date.new(2020, 4, 17), type: :weekly},
        {created_at: Date.new(2020, 4, 10), type: :monthly},
        {created_at: Date.new(2020, 4, 3), type: :weekly},
    ]
    result.each do |res|
      test = expected.detect { |e| e[:created_at] == res[:created_at] }
      if res[:retain?]
        assert test != nil
        assert_equal test[:type], res[:type], "The expected retention type should match"
      else
        assert_nil test, "There should be no expectation if the backup isn't retained"
      end
    end
  end

  def test_retention_day
    retention = Retention.new(5, 4, 2)

    backups = [{created_at: Date.new(2020, 4, 1)}]
    result = retention.retain(backups)

    assert_equal result[0][:created_at], backups[0][:created_at]
    assert_equal result[0][:retain?], true
    assert_equal result[0][:type], :daily
  end

  def test_retention_week
    retention = Retention.new(5, 4, 2)

    backups = (13..19).reverse_each.map {|day| {created_at: Date.new(2020, 7, day)} }
    result = retention.retain(backups)

    expected = [
        {created_at: Date.new(2020, 7, 19), type: :daily},
        {created_at: Date.new(2020, 7, 18), type: :daily},
        {created_at: Date.new(2020, 7, 17), type: :weekly},
        {created_at: Date.new(2020, 7, 16), type: :daily},
        {created_at: Date.new(2020, 7, 15), type: :daily},
        {created_at: Date.new(2020, 7, 14), type: :daily},
    ]
    result.each do |res|
      test = expected.detect { |e| e[:created_at] == res[:created_at] }
      if res[:retain?]
        assert test != nil
        assert_equal test[:type], res[:type], "The expected retention type should match"
      else
        assert_nil test, "There should be no expectation if the backup isn't retained"
      end
    end
  end

end
