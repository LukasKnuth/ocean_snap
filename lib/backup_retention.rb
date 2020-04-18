require 'date'

require "backup_retention/version"
require 'backup_retention/retention'
require 'backup_retention/digital_ocean'

module BackupRetention
  
  # Fetches DigitalOcean information about targated volumes
  def BackupRetention.print_info_volumes(ocean_token)
    puts "The following Volumes are considered for the automatic retention"
    puts "Condition: They must be attached to a Droplet"

    DigitalOcean.new(ocean_token).find_volumes.each do |vol|
      puts "#{vol.name} (ID: #{vol.id}) in #{vol.region.name}"
    end
  end

  # Fetches DigitalOcean information about targated snapshots
  def BackupRetention.print_info_snapshots(ocean_token)
    puts "The following Snapshots are considered for the automatic retention"
    puts "Condition: They belong to a Volume attached to a Droplet"

    ocean = DigitalOcean.new(ocean_token)
    ocean.find_volumes.each do |vol|
      puts "Volume #{vol.name} (ID: #{vol.id}) with:"
      ocean.list_backups(vol.id).each do |snap|
        puts "  - #{snap.name} (ID: #{snap.id}) from #{snap.created_at}"
      end
    end
  end

  # Creates new Snapshots for all targated volumes
  def BackupRetention.create_backup(ocean_token)
    ocean = DigitalOcean.new(ocean_token)
    ocean.find_volumes.each do |vol|
      puts "Creating Snapshot for Volume #{vol.name} (ID: #{vol.id})..."
      snap = ocean.create_backup(vol.id, "daily") # TODO do we even set type here? Not necessary, since we look at created_at only
      puts "Done. Created #{snap.name} (ID: #{snap.id})"
    end
  end

  def BackupRetention.retain_backups(ocean_token, daily, weekly, monthly)
    retention = Retention.new(daily, weekly, monthly)
    ocean = DigitalOcean.new(ocean_token)
    ocean.find_volumes.each do |vol|
      puts "Retaining Snapshots for Volume #{vol.name} (ID: #{vol.id})..."
      
      snapshots = ocean.list_backups(vol.id)
      retention.retain(snapshots).each do |operation|
        snap = operation[:original]
        if operation[:retain?]
          puts "  - Retaining #{snap.name} (ID: #{snap.id}) as #{operation[:type]}"
        else 
          puts "  - Deleting #{snap.name} (ID: #{snap.id})"
          ocean.delete_backup(snap.id)
        end
      end
      puts "Done."
    end
  end

end
