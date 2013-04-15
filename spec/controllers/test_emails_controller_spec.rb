require 'spec_helper'

describe TestEmailsController do
  describe "#new" do
    it "should give some default text" do
      get :new
      assigns(:text).should == "Hello folks. Hopefully this should have worked and you should\nbe reading this. So, all is good.\n\nLove,\nThe Awesome Cuttlefish\n"
    end
  end
end
