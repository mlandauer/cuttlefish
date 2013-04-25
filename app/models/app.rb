class App < ActiveRecord::Base
  validates :name, presence: true, format: {with: /\A[a-zA-Z0-9_ ]+\z/, message: "Only letters, numbers, spaces and underscores"}

  # A big fat WARNING: if you ever decide to expose the Cuttlefish SMTP server to the internet
  # the smtp_password needs to be hashes with a salt and all that.
  before_create :set_smtp_password
  after_create :set_smtp_username

  def new_password!
    unless smtp_password_locked?
      set_smtp_password
      save!
    end
  end

  private

  # There really is no need to encrypt the password as it's only intended to make
  # it slightly harder to send emails from the wrong application
  def set_smtp_password
    self.smtp_password = RandomWord.adjs.next + "_" + RandomWord.nouns.next
  end

  def set_smtp_username
    # By appending the id we can be confident that this name is globally unique
    update_attributes(smtp_username: name.downcase.gsub(" ", "_") + "_" + id.to_s)
  end
end