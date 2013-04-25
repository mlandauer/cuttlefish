class App < ActiveRecord::Base
  has_many :emails
  
  validates :name, presence: true, format: {with: /\A[a-zA-Z0-9_ ]+\z/, message: "Only letters, numbers, spaces and underscores"}

  before_create :set_smtp_password
  after_create :set_smtp_username

  def new_password!
    unless smtp_password_locked?
      set_smtp_password
      save!
    end
  end

  # Singleton for returning special App used for sending mail from Cuttlefish itself
  def self.cuttlefish
    App.find_or_create_by(name: "Cuttlefish", cuttlefish: true)
  end

  private

  def set_smtp_password
    self.smtp_password = Digest::MD5.base64digest(rand.to_s + Time.now.to_s)[0...20]
  end

  def set_smtp_username
    # By appending the id we can be confident that this name is globally unique
    update_attributes(smtp_username: name.downcase.gsub(" ", "_") + "_" + id.to_s)
  end
end