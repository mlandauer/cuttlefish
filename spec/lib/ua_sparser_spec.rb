require "spec_helper"

describe UASparser do
  before :each do
    FileUtils::rm_rf("db/user_agents/test")
    FileUtils::mkdir_p("db/user_agents/test")
  end

  after :each do
    FileUtils::rm_rf("db/user_agents/test")
  end

  let(:parser) { @parser = UASparser.new("db/user_agents/test") }

  context "The main user-agent website has too many connections when accessing the version" do
    before :each do
      Net::HTTP.should_receive(:get_response).with(URI.parse("http://user-agent-string.info/rpc/get_data.php?key=free&format=ini&ver=y")).and_return(mock(:body => "<h1>Error - Connect failed:<br /> <u>Too many connections</u></h1>"))
    end

    it "should raise an exception" do
      expect { parser.parse("foo") }.to raise_error RuntimeError, "Failed to get version of lastest data"
    end
  end

  context "The main user-agent website data is at version 12 but the actual data has too many connections" do
    before :each do
      Net::HTTP.should_receive(:get_response).with(URI.parse("http://user-agent-string.info/rpc/get_data.php?key=free&format=ini&ver=y")).and_return(mock(:body => "12"))
      Net::HTTP.should_receive(:get_response).with(URI.parse("http://user-agent-string.info/rpc/get_data.php?key=free&format=ini")).and_return(mock(:body => "<h1>Error - Connect failed:<br /> <u>Too many connections</u></h1>"))
    end

    it "should raise an exception" do
      expect { parser.parse("foo") }.to raise_error RuntimeError, "Failed to download cache data"
    end
  end
end