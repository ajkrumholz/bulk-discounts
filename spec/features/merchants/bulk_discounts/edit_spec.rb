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

  describe 'when I try to submit invalid data' do
    it 'gives a helpful error message and reloads the page' do
      fill_in(:bulk_discount_discount_percent, with: "")
      fill_in(:bulk_discount_quantity_threshold, with: "abcdef")

      click_on "Update Discount"

      expect(page).to have_current_path(edit_merchant_bulk_discount_path(merchant_1, discount_1))
      expect(page).to have_content("Discount percent can't be blank, Discount percent is not a number, and Quantity threshold is not a number")
    end
  end

  describe 'when I try to change data in a way that the discount can never be applied' do
    it 'gives a helpful error message and reloads the page' do
      fill_in(:bulk_discount_discount_percent, with: 5)
      fill_in(:bulk_discount_quantity_threshold, with: 30)

      click_on "Update Discount"

      expect(page).to have_current_path(edit_merchant_bulk_discount_path(merchant_1, discount_1))
      expect(page).to have_content("Can't edit a discount so that it will never be applied")
    end
  end

  describe 'when I changed a value in the form and click submit' do
    let(:new_percent) { Faker::Number.number(digits: 2) }
    let(:new_quantity) { Faker::Number.number(digits: 2) }

    it 'updates the form and returns me to the show page, where I see the updated values' do

      fill_in(:bulk_discount_discount_percent, with: 30)
      fill_in(:bulk_discount_quantity_threshold, with: 15)
      click_on "Update Discount"

      expect(page).to have_current_path(merchant_bulk_discount_path(merchant_1, discount_1))
      expect(page).to have_content("#{30}% Discount")
      expect(page).to have_content("On orders of #{15} or more items")
    end
    
  end


end