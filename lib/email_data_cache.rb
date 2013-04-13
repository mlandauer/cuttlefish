class EmailDataCache
  attr_reader :email
  
  def initialize(email)
    @email = email
  end

  def update
    save_data_to_filesystem
    cleanup_filesystem_data_store
  end

  def data
    File.read(data_filesystem_path) if is_data_on_filesystem?
  end

  def save_data_to_filesystem
    # Don't overwrite the data that's already on the filesystem
    unless is_data_on_filesystem?
      # Save the data part of the email to the filesystem
      FileUtils::mkdir_p(EmailDataCache.data_filesystem_directory)
      File.open(data_filesystem_path, "w") do |f|
        f.write(email.data)
      end
    end
  end

  def cleanup_filesystem_data_store
    # If there are more than a certain number of stored emails on the filesystem
    # remove the oldest ones
    entries = Dir.glob(File.join(EmailDataCache.data_filesystem_directory, "*"))
    no_to_remove = entries.count - EmailDataCache.max_no_emails_to_store_data
    if no_to_remove > 0
      # Oldest first
      entries.sort_by {|f| File.mtime f}[0...no_to_remove].each {|f| File.delete f}
    end
  end

  def data_filesystem_path
    File.join(EmailDataCache.data_filesystem_directory, "#{email.id}.txt")
  end

  def is_data_on_filesystem?
    File.exists?(data_filesystem_path)
  end

  def self.max_no_emails_to_store_data
    # By default keep the full content of the last 100 emails
    100
  end

  def self.data_filesystem_directory
    File.join("db", "emails", Rails.env)
  end
end
