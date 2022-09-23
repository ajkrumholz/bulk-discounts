require 'rails_helper'

RSpec.describe "merchant bulk discount show page" do
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
    visit merchant_bulk_discount_path(merchant_1, discount_1)
  end

  describe 'when i visit the page' do

    it 'shows me only info for the current discount' do
      expect(page).to have_content("#{discount_1.discount_percent}% Discount")
      expect(page).to have_content("On orders of #{discount_1.quantity_threshold} or more items")
  
      expect(page).to_not have_content("#{discount_2.discount_percent}% Discount")
      expect(page).to_not have_content("On orders of #{discount_2.quantity_threshold} or more items")
    end

    it 'displays a link to edit the discount' do
      expect(page).to have_link("Edit this discount")
    end

    describe 'when I click on this link' do
      it 'takes me to the discount edit page' do
        click_link("Edit this discount")

        expect(current_path).to eq(edit_merchant_bulk_discount_path(merchant_1, discount_1))
      end
    end
  end
end