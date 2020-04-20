# frozen_string_literal: true

require 'droplet_kit'
require 'date'

AUTO_BACKUP_IDENTIFIER = 'autobackup'

class DigitalOcean

  def initialize(token)
    @client = DropletKit::Client.new(access_token: token)
  end

  def find_volumes
    @client.volumes.all.filter do |v|
      !v.droplet_ids.empty?
    end
  end

  def list_backups(volume_id)
    @client.volumes.snapshots(id: volume_id).filter do |s|
      s.name.start_with?(AUTO_BACKUP_IDENTIFIER)
    end
  end

  def create_backup(volume_id, date)
    date = date.is_a?(Date) ? date : Date.parse(date)
    name = "#{AUTO_BACKUP_IDENTIFIER}_#{date.day}.#{date.month}.#{date.year}"
    @client.volumes.create_snapshot(id: volume_id, name: name)
  end

  def backup_exists?(volume_id, date)
    target = date.is_a?(Date) ? date : Date.parse(date)
    list_backups(volume_id).any? do |snap|
        Date.parse(snap.created_at) == target
    end
  end

  def delete_backup(snapshot_id)
    @client.snapshots.delete(id: snapshot_id)
  end

end