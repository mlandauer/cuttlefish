# frozen_string_literal: true

Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder

# Monkey patching this old version of formtastic so that it works with ruby 3.0
# We're stuck on this old version because the bootstrap-formtastic gem that still works
# with bootstrap 2 doesn't work with later formtastic. Ugh...
# I guess this is what you get when you're stuck on old versions of things.
module Formtastic
  module I18n
    class << self
      def translate(*args)
        key = args.shift.to_sym
        options = args.extract_options!
        options.reverse_merge!(:default => DEFAULT_VALUES[key])
        options[:scope] = [DEFAULT_SCOPE, options[:scope]].flatten.compact
        ::I18n.translate(key, *args, **options)
      end
      alias :t :translate
    end
  end
end