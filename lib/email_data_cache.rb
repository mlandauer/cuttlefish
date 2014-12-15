class EmailDataCache
  attr_reader :scope

  def initialize(scope)
    @scope = scope
  end

  def set(id, data)
    EmailDataCache.set(scope, id, data)
  end

  def get(id)
    EmailDataCache.get(scope, id)
  end

  def data_filesystem_directory
    EmailDataCache.data_filesystem_directory(scope)
  end

  def create_data_filesystem_directory
    EmailDataCache.create_data_filesystem_directory(scope)
  end
  
  #####

  def self.set(scope, id, data)
    save_data_to_filesystem(scope, id, data)
    cleanup_filesystem_data_store(scope)
  end

  def self.get(scope, id)
    File.read(data_filesystem_path(scope, id)) if is_data_on_filesystem?(scope, id)
  end

  def self.max_no_emails_to_store_data
    # By default keep the full content of the last 1000 emails
    1000
  end

  def self.data_filesystem_directory(scope)
    File.join("db", "emails", scope)
  end

  # Won't throw an exception when filename doesn't exist
  def self.safe_file_delete(filename)
    begin
      File.delete filename
    rescue Errno::ENOENT
      # Do nothing if the file doesn't exist
    end
  end

  def self.create_data_filesystem_directory(scope)
    FileUtils::mkdir_p(data_filesystem_directory(scope))
  end

  private

  def self.data_filesystem_path(scope, id)
    File.join(data_filesystem_directory(scope), "#{id}.eml")
  end

  def self.is_data_on_filesystem?(scope, id)
    File.exists?(data_filesystem_path(scope, id))
  end

  def self.save_data_to_filesystem(scope, id, data)
    # Don't overwrite the data that's already on the filesystem
    unless is_data_on_filesystem?(scope, id)
      # Save the data part of the email to the filesystem
      create_data_filesystem_directory(scope)
      File.open(data_filesystem_path(scope, id), "w") do |f|
        f.write(data)
      end
    end
  end

  def self.cleanup_filesystem_data_store(scope)
    # If there are more than a certain number of stored emails on the filesystem
    # remove the oldest ones
    entries = Dir.glob(File.join(data_filesystem_directory(scope), "*"))
    no_to_remove = entries.count - max_no_emails_to_store_data
    if no_to_remove > 0
      # Oldest first
      entries.sort_by {|f| File.mtime f}[0...no_to_remove].each {|f| safe_file_delete f}
    end
  end
end
