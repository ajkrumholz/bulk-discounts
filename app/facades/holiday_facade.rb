require './app/services/holiday_service'
require 'json'


class HolidayFacade
  def self.next_three_holidays
    response = get_url('https://date.nager.at/api/v3/NextPublicHolidays/US')
    response[0..2]
  end

  private

  def self.get_url(url)
    response = HolidayService.request(url)
    JSON.parse(response.body, symbolize_names: true)
  end
end