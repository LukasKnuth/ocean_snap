require 'date'

class Retention

  def initialize(daily_count, weekly_count, monthly_count)
    @daily = daily_count
    @weekly = weekly_count
    @monthly = monthly_count
  end

  def self.backup_type(date)
    if date.day == 10
      :monthly
    elsif date.friday?
      :weekly
    else
      :daily
    end
  end

  def retain(backups)
    slots = {daily: @daily, weekly: @weekly, monthly: @monthly}

    backups.sort do |a, b|
      date_a = a[:created_at].is_a?(Date) ? a[:created_at] : Date.parse(a[:created_at])
      date_b = b[:created_at].is_a?(Date) ? b[:created_at] : Date.parse(b[:created_at])
      date_b <=> date_a # Order is important here! Sort descending.
    end.map do |backup|
      date = backup[:created_at].is_a?(Date) ? backup[:created_at] : Date.parse(backup[:created_at]) 
      type = Retention.backup_type(date)
      slots[type] = slots[type] - 1
      {created_at: backup[:created_at], type: type, retain?: slots[type] >= 0, original: backup}
    end
  end

end