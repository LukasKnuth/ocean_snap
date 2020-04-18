require 'date'

class Retention

  def initialize(dailyCount, weeklyCount, monthlyCount)
    @daily = dailyCount
    @weekly = weeklyCount
    @monthly = monthlyCount
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

    backups.map do |backup|
      type = Retention.backup_type(backup[:created_at])
      slots[type] = slots[type] - 1
      {created_at: backup[:created_at], type: type, retain?: slots[type] >= 0}
    end
  end

end