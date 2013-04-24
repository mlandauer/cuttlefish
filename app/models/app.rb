class App < ActiveRecord::Base
  # A big fat WARNING: if you ever decide to expose the Cuttlefish SMTP server to the internet
  # the smtp_password needs to be hashes with a salt and all that.
  before_create :set_smtp_password

  private

  # There really is no need to encrypt the password as it's only intended to make
  # it slightly harder to send emails from the wrong application
  def set_smtp_password
    self.smtp_password = RandomWord.adjs.next + " " + RandomWord.nouns.next
  end
end