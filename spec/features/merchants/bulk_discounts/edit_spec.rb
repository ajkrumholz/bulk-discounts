require 'rails_helper'

RSpec.describe 'bulk discount edit page' do

let!(:merchant_1) { Merchant.create!(name: Faker::Name.unique.name) }

  let!(:discount_1) { 
    merchant_1.bulk_discounts.create!(
      discount_percent: 10,
      quantity_threshold: 5
    )
  }
  let!(:discount_2) { 
    merchant_1.bulk_discounts.create!(
      discount_percent: 15,
      quantity_threshold: 8
    )
  }

  before :each do
    visit edit_merchant_bulk_discount_path(merchant_1, discount_1)
  end

  it 'has a pre-filled form to edit the current discount' do
    expect(page).to have_field(:bulk_discount_discount_percent, with: discount_1.discount_percent)
    expect(page).to have_field(:bulk_discount_quantity_threshold, with: discount_1.quantity_threshold)
  end

  describe 'when I changed a value in the form and click submit' do
    let(:new_percent) { Faker::Number.number(digits: 2) }
    let(:new_quantity) { Faker::Number.number(digits: 2) }

    it 'updates the form and returns me to the show page, where I see the updated values' do

      fill_in(:bulk_discount_discount_percent, with: new_percent)
      fill_in(:bulk_discount_quantity_threshold, with: new_quantity)
      click_on "Update Discount"

      expect(page).to have_current_path(merchant_bulk_discount_path(merchant_1, discount_1))
      expect(page).to have_content("#{new_percent}% Discount")
      expect(page).to have_content("On orders of #{new_quantity} or more items")
    end
    
  end


end