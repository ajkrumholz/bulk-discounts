require 'rails_helper'

RSpec.describe Holiday do
  it 'has a name and a date' do
    holiday = Holiday.new({name: "Today Day", date: Date.today})
    expect(holiday.name).to eq("Today Day")
    expect(holiday.date).to eq(Date.today)
  end
end