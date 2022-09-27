require './app/services/holiday_service'
require './app/poros/holiday'
require 'json'

class HolidayFacade
  def self.next_three_holidays
    response = get_url('https://date.nager.at/api/v3/NextPublicHolidays/US')
    full_list = response.map { |holiday| Holiday.new(holiday) }
    full_list.first(3)
  end

  def self.get_url(url)
    response = HolidayService.request(url)
    JSON.parse(response.body, symbolize_names: true)
  end
end
