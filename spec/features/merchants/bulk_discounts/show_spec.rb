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

      describe 'if the discount is active on any in progress invoices' do
        it 'will display and error and stay on the show page' do
          alaina = Customer.create!(first_name: "Alaina", last_name: "Kneiling")
          licorice = merchant_1.items.create!(name: "Licorice Funnels", description: "Licorice Balls", unit_price: 1200)
          invoice = alaina.invoices.create!(status: :in_progress, created_at: "2012-01-30 14:54:09")
          invoice_item = InvoiceItem.create!(invoice_id: invoice.id, item_id: licorice.id, quantity: 5, unit_price: 2700, status:"shipped" )

          visit merchant_bulk_discount_path(merchant_1, discount_1)

          click_link("Edit this discount")

          expect(current_path).to eq(merchant_bulk_discount_path(merchant_1, discount_1))

          expect(page).to have_content("This discount is cannot be edited while active on an in-progress invoice!")
        end
      end
    end
  end
end