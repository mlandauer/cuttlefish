require 'spec_helper'

describe BlackList do
  describe "#has_record_of_black_list_cause?" do
    context "when the caused_by_delivery is missing" do
      let(:black_list) { create(:black_list, caused_by_delivery: nil ) }

      it { expect(black_list.has_record_of_cause?).to be false }
    end

    context "when the caused_by_delivery present but has no subject" do
      let(:black_list) do
        delivery = create(:delivery, email: create(:email, subject: nil))
        create(:black_list, caused_by_delivery: delivery)
      end

      it { expect(black_list.has_record_of_cause?).to be false }
    end

    context "when the caused_by_delivery present and has a subject" do
      let(:delivery) { create(:delivery) }
      let(:black_list) { create(:black_list, caused_by_delivery: delivery) }

      before do
        allow(delivery).to receive(:subject).and_return("foo")
      end

      it do
        expect(black_list.has_record_of_cause?).to be true
      end
    end
  end
end
