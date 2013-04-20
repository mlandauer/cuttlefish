class Admins::InvitationsController < Devise::InvitationsController
  layout "login", :only => :edit
end