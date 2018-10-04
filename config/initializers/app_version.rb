# frozen_string_literal: true

unless defined?(APP_VERSION)
  APP_VERSION = Rails.env.production? ? File.read(File.join(Rails.root, "REVISION"))[0..6] : `git describe --always`
end
