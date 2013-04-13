class EmailDataCache
  def self.set(id, data)
    save_data_to_filesystem(id, data)
    cleanup_filesystem_data_store
  end

  def self.get(id)
    File.read(data_filesystem_path(id)) if is_data_on_filesystem?(id)
  end

  def self.max_no_emails_to_store_data
    # By default keep the full content of the last 100 emails
    100
  end

  def self.data_filesystem_directory
    File.join("db", "emails", Rails.env)
  end

  private

  def self.data_filesystem_path(id)
    File.join(data_filesystem_directory, "#{id}.txt")
  end

  def self.is_data_on_filesystem?(id)
    File.exists?(data_filesystem_path(id))
  end

  def self.save_data_to_filesystem(id, data)
    # Don't overwrite the data that's already on the filesystem
    unless is_data_on_filesystem?(id)
      # Save the data part of the email to the filesystem
      FileUtils::mkdir_p(data_filesystem_directory)
      File.open(data_filesystem_path(id), "w") do |f|
        f.write(data)
      end
    end
  end

  def self.cleanup_filesystem_data_store
    # If there are more than a certain number of stored emails on the filesystem
    # remove the oldest ones
    entries = Dir.glob(File.join(data_filesystem_directory, "*"))
    no_to_remove = entries.count - max_no_emails_to_store_data
    if no_to_remove > 0
      # Oldest first
      entries.sort_by {|f| File.mtime f}[0...no_to_remove].each {|f| File.delete f}
    end
  end
end
