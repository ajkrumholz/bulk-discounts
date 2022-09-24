require 'rails_helper'

RSpec.describe 'Merchant Index Show Page' do

  # test data collapsed here
  let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}
  let!(:carly_silo) { Merchant.create!(name: "Carly Simon's Candy Silo")}

  let!(:gold_earrings) { jewlery_city.items.create!(name: "Gold Earrings", description: "14k Gold 12' Hoops", unit_price: 12000) }
  let!(:silver_necklace) { jewlery_city.items.create!(name: "Silver Necklace", description: "An everyday wearable silver necklace", unit_price: 220000) }
  let!(:things) { jewlery_city.items.create!(name: "Things", description: "Things n stuff", unit_price: 400000) }
  let!(:studded_bracelet) { jewlery_city.items.create!(name: "Gold Studded Bracelet", description: "A bracet to make others jealous", unit_price: 2900) }

  let!(:licorice) { carly_silo.items.create!(name: "Licorice Funnels", description: "Licorice Balls", unit_price: 1200, enabled: true) }

  let!(:alaina) { Customer.create!(first_name: "Alaina", last_name: "Kneiling")}

  let!(:invoice_1) { alaina.invoices.create!(status: "completed")}
  let!(:invoice_2) { alaina.invoices.create!(status: "in_progress")}

  # let!(:invoice_item_1) { InvoiceItem.create!(invoice_id: invoice_1.id, item_id: gold_earrings.id, quantity: 4, unit_price: 1300, status:"packaged" )}
  let!(:invoice_item_1) { InvoiceItem.create!(invoice_id: invoice_1.id, item_id: gold_earrings.id, quantity: 10, unit_price: 1111, status:"packaged" )}
  let!(:invoice_item_2) { InvoiceItem.create!(invoice_id: invoice_1.id, item_id: things.id, quantity: 34, unit_price: 2014, status:"packaged" )}
  let!(:invoice_item_3) { InvoiceItem.create!(invoice_id: invoice_1.id, item_id: silver_necklace.id, quantity: 7, unit_price: 1500, status:"packaged" )}
  let!(:invoice_item_4) { InvoiceItem.create!(invoice_id: invoice_1.id, item_id: licorice.id, quantity: 4, unit_price: 1300, status:"packaged" )}

  let!(:invoice_item_5) { InvoiceItem.create!(invoice_id: invoice_2.id, item_id: studded_bracelet.id, quantity: 40, unit_price: 1500, status:"shipped" )}
  
  describe 'when I visit a merchant invoice show page' do
    describe 'I see information related to the invoice' do
      it 'displays id number, status, date of creation, customer full name' do
        visit merchant_invoice_path(jewlery_city, invoice_1)

        expect(page).to have_content("Invoice ##{invoice_1.id}")
        expect(page).to have_content("Status: #{invoice_1.status}")
        expect(page).to have_content("Created at: #{invoice_1.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{alaina.name}")
      end
    end

    describe 'I see all of MY items on the invoice' do

      it 'displays the name of each merchant item on the invoice' do
        visit merchant_invoice_path(jewlery_city, invoice_1)
        within("#invoice_items") do
          expect(page).to have_content(silver_necklace.name)
          expect(page).to have_content(gold_earrings.name)
        end
        expect(page).to have_content("Invoice ##{invoice_1.id}")

        within("#invoice_items") do
          expect(page).to have_content(gold_earrings.name)
          expect(page).to have_content(silver_necklace.name)
          expect(page).to_not have_content(studded_bracelet.name)
          expect(page).to_not have_content(licorice.name)
        end
      end

      it 'displays the quantity, sale price, and status for each item' do
        visit merchant_invoice_path(jewlery_city, invoice_1)
        within("#item_#{gold_earrings.id}") do
          expect(page).to have_content("#{invoice_item_1.quantity}")
          expect(page).to have_content("#{((invoice_item_1.unit_price)/100.to_f).round(2)}")
          expect(page).to have_field("Status", with: invoice_item_1.status)
        end

        within("#item_#{silver_necklace.id}") do
          expect(page).to have_content("#{invoice_item_3.quantity}")
          expect(page).to have_content("#{((invoice_item_3.unit_price)/100.to_f).round(2)}")
          expect(page).to have_field("Status", with: invoice_item_3.status)
        end
      end
      
      describe 'when I change an items status and click the submit button' do
        it 'takes me back to the merchant invoice show page and shows the updated status' do
          visit merchant_invoice_path(jewlery_city, invoice_1)

          within("#item_#{gold_earrings.id}") do
            expect(page).to have_field("Status", with: "packaged")
            select "shipped", from: :status
            click_on "Update Item Status"
          end

          expect(current_path).to eq merchant_invoice_path(jewlery_city, invoice_1)

          within("#item_#{gold_earrings.id}") do
            expect(page).to have_field("Status", with: "shipped")
          end
        end
      end

      it 'Then I see the total revenue that will be generated from all of my items on the invoice' do
        visit merchant_invoice_path(jewlery_city, invoice_1)

        within("#total_invoice_revenue") do
          expect(page).to have_content("Total Revenue From This Invoice: $#{sprintf("%.2f",invoice_1.merchant_invoice_revenue(jewlery_city)/100.to_f)}")
        end
      end

      it 'also shows the total revenue after bulk discounts are applied' do
        jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 5)
        jewlery_city.bulk_discounts.create!(discount_percent: 25, quantity_threshold: 6)
        
        visit merchant_invoice_path(jewlery_city, invoice_1)
        
        expect(page).to have_content("Total Revenue After Bulk Discount: $#{sprintf("%.2f",invoice_1.merchant_discount_revenue(jewlery_city)/100.to_f)}")
      end

      it 'shows a link to the bulk discount show page for the discount that was applied, if any' do
        discount_1 = jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 11)
        discount_2 = jewlery_city.bulk_discounts.create!(discount_percent: 25, quantity_threshold: 35)
        visit merchant_invoice_path(jewlery_city, invoice_1)
        within("#item_#{gold_earrings.id}") do
          expect(page).to_not have_link ("Applied #{discount_1.discount_percent}% Discount")
        end

        within("#item_#{things.id}") do
          expect(page).to have_link ("Applied #{discount_1.discount_percent}% Discount")
        end
      end
    end
  end
end


