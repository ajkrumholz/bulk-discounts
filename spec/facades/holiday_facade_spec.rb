require 'rails_helper'

RSpec.describe HolidayFacade do
  describe 'class methods' do
    # let(:json_response) { 
    #   File.open("./fixtures/next_three_holidays.json") 
    # }
    # let(:uri) { "https://date.nager.at/api/v3/NextPublicHolidays/US" }

    # before :each do
    #   stub_request(:get, uri).with(headers: {
    #     'Accept'=>'*/*',
    #     'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
    #     'User-Agent'=>'Ruby'
    #     }).to_return(status: 200, body: json_response, headers: {})
    # end

    describe '.get_url' do
      it 'calls on the HolidayService and returns a formatted json response body' do
        response = HolidayFacade.get_url("https://date.nager.at/api/v3/NextPublicHolidays/US")
        expect(response).to be_an(Array)
        expect(response.first[:name]).to eq("Columbus Day")
      end
    end

    describe '.next_three_holidays' do
      it 'returns an array of the next three holidays in the USA' do
        next_three = HolidayFacade.next_three_holidays
        expect(next_three.first).to be_a(Holiday)
        expect(next_three.first.name).to eq("Columbus Day")
      end
    end
  end
end