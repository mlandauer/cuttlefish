class Admin < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :team

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
