# frozen_string_literal: true

require "csv"

module DSN
  def self.read_csv
    # This CSV file has been downloaded from the registry of DSN codes at
    # https://www.iana.org/assignments/smtp-enhanced-status-codes/smtp-enhanced-status-codes.xhtml
    # Note that we're also caching result so we don't need to read the file twice
    @read_csv ||= CSV.read("lib/smtp-enhanced-status-codes-3.csv", headers: true).map do |row|
      {
        code: row["Code"],
        short_description: row["Sample Text"],
        long_description: row["Description"]
      }
    end
  end

  def self.hard_bounce_data
    read_csv.map do |row|
      row[:code] = row[:code].tr("X", "5")
      row
    end
  end

  def self.hard_bounce_codes
    hard_bounce_data.map { |row| row[:code] }
  end

  def self.hard_bounce_codes_short_descriptions
    Hash[hard_bounce_data.map { |row| [row[:code], row[:short_description]] }]
  end
end
