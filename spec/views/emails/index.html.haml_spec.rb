require 'spec_helper'

describe "emails/index" do
  before(:each) do
    emails = [
      stub_model(Email, :created_at => Time.now, :status => "unknown"),
      stub_model(Email, :created_at => Time.now, :status => "unknown")
    ]
    emails.stub!(:total_pages).and_return(1)
    assign(:emails, emails)
  end

  it "renders a list of emails" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
