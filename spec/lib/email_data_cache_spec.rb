require "spec_helper"
require "mail_job"

describe EmailDataCache do
  let(:cache) { EmailDataCache.new(Rails.env, 1000) }

  describe ".set" do
    it "should persist the main part of the email in the filesystem" do
      cache.set(10, "This is a main data section")
      expect(File.read(File.join(cache.data_filesystem_directory, "10.eml"))).to eq "This is a main data section"
    end

    it "should handle strange characters in the email" do
      handler = <<-EOF
--- !ruby/object:MailJob
message: !ruby/object:OpenStruct
  table:
    :app_id: 12
    :sender: "<devteam@writeit.ciudadanointeligente.org> size=1881"
    :recipients:
      - "<luisfelipealvarez@gmail.com>"
    :data: !binary |-
      Q29udGVudC1UeXBlOiBtdWx0aXBhcnQvYWx0ZXJuYXRpdmU7CiBib3VuZGFy
      eT0iPT09PT09PT09PT09PT09NTA1MjE3NDkyOTQ2NzY2MjA2OT09IgpNSU1F
      LVZlcnNpb246IDEuMApTdWJqZWN0OiBDb25maXJtYXRpb24gZW1haWwgZm9y
      IGEgbWVzc2FnZSBpbiBXcml0ZUl0CkZyb206IGRldnRlYW1Ad3JpdGVpdC5j
      aXVkYWRhbm9pbnRlbGlnZW50ZS5vcmcKVG86IGx1aXNmZWxpcGVhbHZhcmV6
      QGdtYWlsLmNvbQpEYXRlOiBTYXQsIDEwIEphbiAyMDE1IDAwOjA3OjA5IC0w
      MDAwCk1lc3NhZ2UtSUQ6IDwyMDE1MDExMDAwMDcwOS43OTMzLjQwOTZAaXAt
      MTAtMTk5LTMzLTExOC51cy13ZXN0LTEuY29tcHV0ZS5pbnRlcm5hbD4KCi0t
      PT09PT09PT09PT09PT09NTA1MjE3NDkyOTQ2NzY2MjA2OT09Ck1JTUUtVmVy
      c2lvbjogMS4wCkNvbnRlbnQtVHlwZTogdGV4dC9wbGFpbjsgY2hhcnNldD0i
      dXRmLTgiCkNvbnRlbnQtVHJhbnNmZXItRW5jb2Rpbmc6IDhiaXQKCkhlbGxv
      IEZlbGlwZSDDgWx2YXJleiBkZSBGQ0k6CldlIGhhdmUgcmVjZWl2ZWQgYSBt
      ZXNzYWdlIHdyaXR0ZW4gYnkgeW91IGluIC4KVGhlIG1lc3NhZ2Ugd2FzOgpT
      dWJqZWN0OiAgYXNkYXNkIApDb250ZW50OiAgPHA+YXNkYXNkYTwvcD4KVG86
      IApGZWxpcGUgw4FsdmFyZXoKCgpQbGVhc2UgY29uZmlybSB0aGF0IHlvdSBo
      YXZlIHNlbnQgdGhpcyBtZXNzYWdlIGJ5IGNvcGl5aW5nIHRoZSBuZXh0IHVy
      bCBpbiB5b3VyIGJyb3dzZXIuCgoKL2NvbmZpcm1fbWVzc2FnZS85ZTdmNzBk
      Mjk4NWMxMWU0YWNhNjIyMDAwYWM3MjE3Ni4KCgpPbmNlIHlvdSBoYXZlIGNv
      bmZpcm1lZCwgeW91IHdpbGwgYmUgYWJsZSB0byBhY2Nlc3MgeW91ciBtZXNz
      YWdlIGlmIHlvdSBnbyB0byB0aGUgbmV4dCB1cmwKCgovZW4vd3JpdGVpdF9p
      bnN0YW5jZXMvZGV2dGVhbS9tZXNzYWdlcy9hc2Rhc2QtMTguCgoKClRoYW5r
      cy4KClRoZSB3cml0ZWl0IHRlYW0uCi0tPT09PT09PT09PT09PT09NTA1MjE3
      NDkyOTQ2NzY2MjA2OT09Ck1JTUUtVmVyc2lvbjogMS4wCkNvbnRlbnQtVHlw
      ZTogdGV4dC9odG1sOyBjaGFyc2V0PSJ1dGYtOCIKQ29udGVudC1UcmFuc2Zl
      ci1FbmNvZGluZzogOGJpdAoKSGVsbG8gRmVsaXBlIMOBbHZhcmV6IGRlIEZD
      STo8YnIgLz4KV2UgaGF2ZSByZWNlaXZlZCBhIG1lc3NhZ2Ugd3JpdHRlbiBi
      eSB5b3UgaW4gLjxiciAvPgpUaGUgbWVzc2FnZSB3YXM6PGJyIC8+CjxzdHJv
      bmc+U3ViamVjdDogPC9zdHJvbmc+IGFzZGFzZCA8YnIvPgo8c3Ryb25nPkNv
      bnRlbnQ6IDwvc3Ryb25nPiA8cD5hc2Rhc2RhPC9wPiA8YnIgLz4KPHN0cm9u
      Zz5UbzogPC9zdHJvbmc+Cjx1bD4KCQoJPGxpPkZlbGlwZSDDgWx2YXJlejwv
      bGk+CgkKPC91bD4KPGJyIC8+CgpQbGVhc2UgY29uZmlybSB0aGF0IHlvdSBo
      YXZlIHNlbnQgdGhpcyBtZXNzYWdlIGJ5IGNsaWNraW5nIG9uIHRoZSBuZXh0
      IGxpbms8YnIgLz4KPGJyIC8+CjxhIGhyZWY9Ii9jb25maXJtX21lc3NhZ2Uv
      OWU3ZjcwZDI5ODVjMTFlNGFjYTYyMjAwMGFjNzIxNzYiPi9jb25maXJtX21l
      c3NhZ2UvOWU3ZjcwZDI5ODVjMTFlNGFjYTYyMjAwMGFjNzIxNzY8L2E+Lgo8
      YnIgLz4KCjxiciAvPgpPbmNlIHlvdSBoYXZlIGNvbmZpcm1lZCwgeW91IHdp
      bGwgYmUgYWJsZSB0byBhY2Nlc3MgeW91ciBtZXNzYWdlIGlmIHlvdSBnbyB0
      byB0aGUgbmV4dCB1cmw8YnIgLz4KPGJyIC8+CjxhIGhyZWY9Ii9lbi93cml0
      ZWl0X2luc3RhbmNlcy9kZXZ0ZWFtL21lc3NhZ2VzL2FzZGFzZC0xOCI+L2Vu
      L3dyaXRlaXRfaW5zdGFuY2VzL2RldnRlYW0vbWVzc2FnZXMvYXNkYXNkLTE4
      PC9hPi4KCjxiciAvPgoKVGhhbmtzCgpUaGUgd3JpdGVpdCB0ZWFtLgotLT09
      PT09PT09PT09PT09PTUwNTIxNzQ5Mjk0Njc2NjIwNjk9PS0t
    :received: true
    :completed_at: 2015-01-10 00:05:58.317911448 +00:00
  modifiable: true
      EOF
      d1 = YAML.load(handler).message.data
      cache.set(1, d1)
      d2 = cache.get(1)

      expect(d2).to eq d1.force_encoding("UTF-8")
    end

    it "should only keep the full data of a certain number of the emails around" do
      allow(cache).to receive(:max_no_emails_to_store_data).and_return(2)
      (1..4).each {|id| cache.set(id, "This a main section") }
      expect(Dir.glob(File.join(cache.data_filesystem_directory, "*")).count).to eq 2
    end
  end

  describe ".get" do
    it "should be able to read in the data again" do
      cache.set(10, "This is a main data section")
      expect(cache.get(10)).to eq "This is a main data section"
    end

    it "should return nil if nothing is stored on the filesystem" do
      expect(cache.get(10)).to be_nil
    end
  end

  describe ".safe_file_delete" do
    before :each do
      @filename = File.join(cache.data_filesystem_directory, "foo")
      cache.create_data_filesystem_directory
    end

    it "should delete a file" do
      FileUtils.touch(@filename)
      EmailDataCache.safe_file_delete(@filename)
      expect(File.exists?(@filename)).to be_falsy
    end

    it "should not throw an error when the file doesn't exist" do
      EmailDataCache.safe_file_delete(@filename)
    end
  end
end
