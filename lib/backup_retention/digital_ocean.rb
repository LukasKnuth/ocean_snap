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

  def create_backup(volume_id, type)
    today = Date.today
    name = "#{AUTO_BACKUP_IDENTIFIER}_#{today.day}.#{today.month}.#{today.year}_#{type}"
    @client.volumes.create_snapshot(id: volume_id, name: name)
  end

  def delete_backup(snapshot_id)
    @client.snapshots.delete(id: snapshot_id)
  end

end