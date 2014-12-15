require "spec_helper"

describe EmailDataCache do
  let(:cache) { EmailDataCache.new(Rails.env) }

  describe ".set" do
    it "should persist the main part of the email in the filesystem" do
      cache.set(10, "This is a main data section")
      File.read(File.join(cache.data_filesystem_directory, "10.eml")).should == "This is a main data section"
    end

    it "should only keep the full data of a certain number of the emails around" do
      cache.stub(:max_no_emails_to_store_data).and_return(2)
      (1..4).each {|id| cache.set(id, "This a main section") }
      Dir.glob(File.join(cache.data_filesystem_directory, "*")).count.should == 2
    end
  end

  describe ".get" do
    it "should be able to read in the data again" do
      cache.set(10, "This is a main data section")
      cache.get(10).should == "This is a main data section"
    end

    it "should return nil if nothing is stored on the filesystem" do
      cache.get(10).should be_nil
    end
  end

  describe ".safe_file_delete" do
    before :each do
      @filename = File.join(cache.data_filesystem_directory, "foo")
      cache.create_data_filesystem_directory
    end

    it "should delete a file" do
      FileUtils.touch(@filename)
      EmailDataCache.safe_file_delete(@filename)
      File.exists?(@filename).should be_falsy
    end

    it "should not throw an error when the file doesn't exist" do
      EmailDataCache.safe_file_delete(@filename)
    end
  end
end
