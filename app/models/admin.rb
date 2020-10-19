# frozen_string_literal: true

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

  # Invite a new user to join the team of the inviting admin. It sends out
  # an invitation email
  def self.invite_to_team!(email:, inviting_admin:, accept_url:)
    Admin.invite!(
      { email: email, team_id: inviting_admin.team_id },
      inviting_admin,
      accept_url: accept_url
    )
  end
end
