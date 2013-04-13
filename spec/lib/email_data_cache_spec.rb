require "spec_helper"

describe EmailDataCache do
  describe ".set" do
    it "should persist the main part of the email in the filesystem" do
      EmailDataCache.set(10, "This is a main data section")
      File.read(File.join(EmailDataCache.data_filesystem_directory, "10.txt")).should == "This is a main data section"
    end

    it "should only keep the full data of a certain number of the emails around" do
      EmailDataCache.stub!(:max_no_emails_to_store_data).and_return(2)
      (1..4).each {|id| EmailDataCache.set(id, "This a main section") }
      Dir.glob(File.join(EmailDataCache.data_filesystem_directory, "*")).count.should == 2
    end    
  end

  describe ".get" do
    it "should be able to read in the data again" do
      EmailDataCache.set(10, "This is a main data section")
      EmailDataCache.get(10).should == "This is a main data section"
    end

    it "should return nil if nothing is stored on the filesystem" do
      EmailDataCache.get(10).should be_nil
    end
  end
end