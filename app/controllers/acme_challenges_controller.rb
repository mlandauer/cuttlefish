# frozen_string_literal: true

class AcmeChallengesController < ApplicationController
  def show
    challenge = AcmeChallenge.find_by!(token: params[:token])
    render plain: challenge.content
  end
end
