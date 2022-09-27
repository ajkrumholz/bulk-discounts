require 'httparty'

class HolidayService
  def self.request(path)
    HTTParty.get(path)
  end
end

# different method
