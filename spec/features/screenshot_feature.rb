require 'spec_helper'

describe "getting a bunch of screenshots", js: true do

  def screenshot(path)
    page.driver.browser.manage.window.resize_to(1024,640)
    page.save_screenshot(path)
    i = Magick::ImageList.new(path)
    small = i.resize_to_fit(1024 / 1.5)
    small.write(path)
    #exec("open #{path}")
  end

  before :each do
    ApplicationController.any_instance.stub(force_ssl?: false)
  end

  context "no users" do
    it "sign up page" do
      visit new_admin_registration_path
      screenshot("app/assets/images/screenshot1.png")
    end
  end

  context "users" do
    before :each do
      Admin.create!(email: 'matthew@openaustralia.org', password: 'caplin')
      visit new_admin_session_path
      fill_in "Email", with: "matthew@openaustralia.org"
      fill_in "Password", with: "caplin"
      click_button "Login"
    end

    it "landing page" do
      screenshot("app/assets/images/screenshot2.png")
    end

    context "an email" do
      before :each do
        mail = Mail.new do
          text_part do
            body "This can be anything because it isn't actually seen in the screenshot"
          end

          html_part do
            content_type 'text/html; charset=UTF-8'
            body <<-EOF 
<div>
  It's pretty good to be able to wake up and go for a walk in place like this five minutes from where you live.
</div>
<div>
  <br>
</div>
<img src="https://pbs.twimg.com/media/BGUKkJ2CEAAIQWI.jpg:large" alt="Inline image 1" width="564" height="423">
<div>
  <br>
</div>
<div>
  I know this an automated email and all but can you please take a look at the
  <a href="http://github.com/mlandauer/cuttlefish">latest code on Github</a>?
  Thanks!
</div>
<br>
<div>
  <br>
</div>
-- <br>
<div>
  Your friendly Cuttlefish<br>
  <br>
  <a href="mailto:hello@cuttlefish.io">hello@cuttlfish.io</a>
</div>
            EOF
          end
        end
        @email = Email.create!(from: "hello@cuttlefish.io", to: "matthew@openaustralia.org", data: mail.encoded)
        @delivery = @email.deliveries.first
        @delivery.update_attributes(sent: true)
        FactoryGirl.create(:postfix_log_line, delivery: @delivery,
            time: 5.minutes.ago, dsn: "2.0.0", extended_status: "sent (250 2.0.0 r6ay1l02Y4aTF9m016ayyY mail accepted for delivery)")
        FactoryGirl.create(:open_event, delivery: @delivery, created_at: 2.minutes.ago, user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31",
          ip: "1.2.3.4")
      end

      it "email" do
        visit delivery_path(@delivery)
        click_link "Delivered"
        click_link "Opened"
        # Wait until jquery animation finishes
        page.evaluate_script('$(":animated").length') == 0 
        screenshot("app/assets/images/screenshot3.png")
      end
    end
  end

end