require 'rails_helper'

RSpec.describe HolidayService do
  describe 'class methods' do
    describe 'request' do
      it 'returns a response via HTTParty' do
        json_response = File.open("./fixtures/next_three_holidays.json")
        uri = "https://date.nager.at/api/v3/NextPublicHolidays/US"

        stub_request(:get, uri).
         with(
           headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent'=>'Ruby'
           }).
         to_return(status: 200, body: json_response, headers: {})

        response = HolidayService.request(uri)
        expect(response).to be_a(HTTParty::Response)
      end
    end
  end
end