class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :team
  before_create :set_api_key

  def set_api_key
    self.api_key = Digest::MD5.base64digest(
      id.to_s + rand.to_s + Time.now.to_s
    )[0...20]
  end

  def display_name
    if name.present?
      name
    else
      email
    end
  end

  def email_with_name
    if name.present?
      "#{name} <#{email}>"
    else
      email
    end
  end
end
