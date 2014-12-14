unless defined?(APP_VERSION)
  APP_VERSION = Rails.env.production? ? File.read(File.join(Rails.root, "REVISION")) : `git describe --always`
end
