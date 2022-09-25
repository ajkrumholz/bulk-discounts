require 'rails_helper'
require 'webmock'

RSpec.describe 'merchant bulk items index' do
  let!(:merchant_1) { Merchant.create!(name: Faker::Name.unique.name) }
  let!(:merchant_2) { Merchant.create!(name: Faker::Name.unique.name) }

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
  let!(:discount_3) { 
    merchant_1.bulk_discounts.create!(
      discount_percent: 20,
      quantity_threshold: 10
    )
  }

  let!(:discount_4) { 
    merchant_2.bulk_discounts.create!(
      discount_percent: 30,
      quantity_threshold: 20
    )
  }
  let!(:discount_5) { 
    merchant_2.bulk_discounts.create!(
      discount_percent: 25,
      quantity_threshold: 10
    )
  }

  before :each do
    visit merchant_bulk_discounts_path(merchant_1)
  end

  it 'displays all of my bulk discounts with their info' do

    expect(page).to have_content(merchant_1.name)

    within "#discount-#{discount_1.id}" do
      expect(page).to have_content("#{discount_1.discount_percent}% off #{discount_1.quantity_threshold} or more items!")
    end

    within "#discount-#{discount_2.id}" do
      expect(page).to have_content("#{discount_2.discount_percent}% off #{discount_2.quantity_threshold} or more items!")
    end

    within "#discount-#{discount_3.id}" do
      expect(page).to have_content("#{discount_3.discount_percent}% off #{discount_3.quantity_threshold} or more items!")
    end

    expect(page).to_not have_content(merchant_2.name)
    expect(page).to_not have_css("#discount-#{discount_4.id}")
    expect(page).to_not have_css("#discount-#{discount_5
.id}")
  end

  describe 'when I click on a particular discount' do
    it 'links to that discount show page' do
      click_link "#{discount_2.discount_percent}% off #{discount_2.quantity_threshold} or more items!"

      expect(page).to have_current_path(merchant_bulk_discount_path(merchant_1, discount_2))

      expect(page).to have_content("#{discount_2.discount_percent}% Discount")
      expect(page).to have_content("On orders of #{discount_2.quantity_threshold} or more items")

      expect(page).to_not have_content("#{discount_3.discount_percent}% Discount")
      expect(page).to_not have_content("On orders of #{discount_3.quantity_threshold} or more items")
    end
  end

  describe 'link to create a new discount' do
    it 'links to a page allowing us to create a new discount' do
      expect(page).to have_link "Create a new discount"

      click_link "Create a new discount"

      expect(current_path).to eq(new_merchant_bulk_discount_path(merchant_1))
    end
  end

  describe 'link to delete an existing discount' do
    describe 'next to each discount listed in the index' do
      it 'displays a link to delete that discount' do
        within "#discount-#{discount_2.id}" do
          expect(page).to have_link("Delete #{discount_2.discount_percent}% Discount")
        end
    
        within "#discount-#{discount_3.id}" do
          expect(page).to have_content("Delete #{discount_3.discount_percent}% Discount")
        end
      end

      describe 'when I click the link to delete' do
        it 'deletes the discount and redirects back to the index' do
          within "#discount-#{discount_2.id}" do
            expect(page).to have_link("Delete #{discount_2.discount_percent}% Discount")
          end

          click_link "Delete #{discount_2.discount_percent}% Discount"

          expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1))
          expect(page).to_not have_css("#discount-#{discount_2.id}")
        end

        it 'will not delete a bulk discount applied to an invoice with status pending' do
          alaina = Customer.create!(first_name: "Alaina", last_name: "Kneiling")
          licorice = merchant_1.items.create!(name: "Licorice Funnels", description: "Licorice Balls", unit_price: 1200)
          invoice = alaina.invoices.create!(status: "pending", created_at: "2012-01-30 14:54:09")
          invoice_item = InvoiceItem.create!(invoice_id: invoice.id, item_id: licorice.id, quantity: 5, unit_price: 2700, status:"shipped" )

          visit merchant_bulk_discounts_path(merchant_1)

          click_link("Delete #{discount_1.discount_percent}% Discount")

          expect(current_path).to eq(merchant_bulk_discounts_path(merchant_1))

          expect(page).to have_content("#{discount_2.discount_percent}% Discount")
          expect(page).to have_content("On orders of #{discount_2.quantity_threshold} or more items")

          expect(page).to have_content("Unable to delete a bulk discount applied to a pending invoice")
        end
      end
    end
  end

  describe 'upcoming holidays section' do
    it 'displays a list of the next three upcoming US holidays' do
      expect(page).to have_css("#upcoming_holidays")
    end
  end
end