# frozen_string_literal: true

require "spec_helper"

describe EmailDataCache do
  let(:cache) { described_class.new(Rails.env, 1000) }

  describe ".set" do
    it "persists the main part of the email in the filesystem" do
      cache.set(10, "This is a main data section")
      expect(
        File.read(File.join(cache.data_filesystem_directory, "10.eml"))
      ).to eq "This is a main data section"
    end

    it "only keeps the full data of a certain no of the emails around" do
      allow(cache).to receive(:max_no_emails_to_store_data).and_return(2)
      (1..4).each { |id| cache.set(id, "This a main section") }
      expect(
        Dir.glob(File.join(cache.data_filesystem_directory, "*")).count
      ).to eq 2
    end
  end

  describe ".get" do
    it "is able to read in the data again" do
      cache.set(10, "This is a main data section")
      expect(cache.get(10)).to eq "This is a main data section"
    end

    it "returns nil if nothing is stored on the filesystem" do
      expect(cache.get(10)).to be_nil
    end
  end

  describe ".safe_file_delete" do
    before do
      @filename = File.join(cache.data_filesystem_directory, "foo")
      cache.create_data_filesystem_directory
    end

    it "deletes a file" do
      FileUtils.touch(@filename)
      described_class.safe_file_delete(@filename)
      expect(File).not_to exist(@filename)
    end

    it "does not throw an error when the file doesn't exist" do
      described_class.safe_file_delete(@filename)
    end
  end
end
