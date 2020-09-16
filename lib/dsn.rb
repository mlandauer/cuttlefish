# frozen_string_literal: true

require "csv"

module DSN
  def self.read_csv
    @read_csv ||= read_csv_no_caching
  end

  def self.read_csv_no_caching
    # This CSV file has been downloaded from the registry of DSN codes at
    # https://www.iana.org/assignments/smtp-enhanced-status-codes/smtp-enhanced-status-codes.xhtml
    r = CSV.read("lib/smtp-enhanced-status-codes-3.csv", headers: true).map do |row|
      [
        row["Code"],
        {
          short_description: row["Sample Text"],
          long_description: row["Description"]
        }
      ]
    end
    Hash[r]
  end

  def self.hard_bounce_data
    read_csv.transform_keys { |code| code.tr("X", "5") }
  end

  def self.hard_bounce_codes
    hard_bounce_data.keys
  end

  def self.hard_bounce_codes_short_descriptions
    hard_bounce_data.transform_values { |v| v[:short_description] }
  end
end
