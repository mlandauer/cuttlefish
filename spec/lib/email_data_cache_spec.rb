require "spec_helper"

describe EmailDataCache do
  describe "#set" do
    it "should persist the main part of the email in the filesystem" do
      cache = EmailDataCache.new(mock(id: 10, data: "This is a main data section"))
      cache.set
      File.read(File.join(EmailDataCache.data_filesystem_directory, "10.txt")).should == "This is a main data section"
    end

    it "should only keep the full data of a certain number of the emails around" do
      EmailDataCache.stub!(:max_no_emails_to_store_data).and_return(2)
      (1..4).each {|id| EmailDataCache.new(mock(id: id, data: "This a main section")).set }
      Dir.glob(File.join(EmailDataCache.data_filesystem_directory, "*")).count.should == 2
    end    
  end

  describe "#get" do
    it "should be able to read in the data again" do
      EmailDataCache.new(mock(id: 10, data: "This is a main data section")).set
      EmailDataCache.new(mock(id: 10)).get.should == "This is a main data section"
    end

    it "should return nil if nothing is stored on the filesystem" do
      EmailDataCache.new(mock(id: 10)).get.should be_nil
    end
  end
end