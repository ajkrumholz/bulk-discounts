require 'rails_helper'

RSpec.describe HolidayFacade do
  describe 'class methods' do
    describe '.next_three_holidays' do
      it 'returns an array of the next three holidays in the USA' do
        next_three = HolidayFacade.next_three_holidays
        # expect(next_three.first.name).to eq("Colombus Day")
        # expect(next_three.second.name).to eq("Veterans Day")
        # expect(next_three.third.name).to eq("Thanksgiving Day")
      end
    end
  end
end