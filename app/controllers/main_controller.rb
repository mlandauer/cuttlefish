class MainController < ApplicationController
  def index
    @from = "contact@openaustraliafoundation.org.au"
    @to = "Matthew Landauer <matthew@openaustralia.org>"
    @subject = "This is a test email from Cuttlefish"
    @text = <<-EOF
Hello folks. Hopefully this should have worked and you should
be reading this. So, all is good.

Love,
The Awesome Cuttlefish
    EOF
  end

  def status_counts
    render :partial => "status_counts"
  end

  def reputation
    if request.xhr?
      render :partial => "reputation"
      return
    end
  end

end
