# frozen_string_literal: true

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :team

  def display_name
    name.presence || email
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

  # Overriding the implementation provided by devise so that we can pass
  # extra options to the mailer
  # Attempt to find a user by its email. If a record is found, send new
  # password instructions to it. If user is not found, returns a new user
  # with an email not found error.
  # Attributes must contain the user's email
  def self.send_reset_password_instructions(attributes = {}, mailer_options = {})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions(mailer_options) if recoverable.persisted?
    recoverable
  end

  # Overriding the implementation provided by devise so that we can pass
  # extra options to the mailer
  # Resets reset password token and send reset password instructions by email.
  # Returns the token sent in the e-mail.
  def send_reset_password_instructions(mailer_options = {})
    token = set_reset_password_token
    send_reset_password_instructions_notification(token, mailer_options)

    token
  end

  protected

  # Overriding the implementation provided by devise so that we can pass
  # extra options to the mailer
  def send_reset_password_instructions_notification(token, mailer_options = {})
    send_devise_notification(:reset_password_instructions, token, mailer_options)
  end
end
