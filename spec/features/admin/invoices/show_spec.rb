require 'rails_helper'

RSpec.describe 'admin invoice show' do
    let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}
    let!(:carly_silo) { Merchant.create!(name: "Carly Simon's Candy Silo")}

    let!(:gold_earrings) { jewlery_city.items.create!(name: "Gold Earrings", description: "14k Gold 12' Hoops", unit_price: 12244) }
    let!(:silver_necklace) { jewlery_city.items.create!(name: "Silver Necklace", description: "An everyday wearable silver necklace", unit_price: 12425) }
    let!(:studded_bracelet) { jewlery_city.items.create!(name: "Gold Studded Bracelet", description: "A bracet to make others jealous", unit_price: 1512) } 
    let!(:licorice) { carly_silo.items.create!(name: "Licorice Funnels", description: "Licorice Balls", unit_price: 9292, enabled: true) }
    let!(:bronzinos) { carly_silo.items.create!(name: "Peanut Bronzinos", description: "Peanut coated fish", unit_price: 1422, enabled: true) }
    
    
    let!(:alaina) { Customer.create!(first_name: "Alaina", last_name: "Kneiling")}

    let!(:alaina_invoice1) { alaina.invoices.create!(status: "completed")}
    let!(:alaina_invoice2) { alaina.invoices.create!(status: "in_progress")}

    let!(:invoice_item_1) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: gold_earrings.id, quantity: 5, unit_price: 122421, status:"packaged" )}
    let!(:invoice_item_2) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: silver_necklace.id, quantity: 10, unit_price: 2122552, status:"packaged" )}
    let!(:invoice_item_3) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: licorice.id, quantity: 15, unit_price: 52122, status:"packaged" )}

    let!(:invoice_item_4) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: licorice.id, quantity: 5, unit_price: 12221, status:"packaged" )}
    let!(:invoice_item_5) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: bronzinos.id, quantity: 10, unit_price: 1242, status:"packaged" )}


    let!(:invoice_item_6) { InvoiceItem.create!(invoice_id: alaina_invoice2.id, item_id: studded_bracelet.id, quantity: 40, unit_price: 1500, status:"shipped" )}

    it 'shows all invoice info' do
        visit admin_invoice_path(alaina_invoice1)
        expect(page).to have_content("##{alaina_invoice1.id}")
        expect(page).to have_content("#{alaina_invoice1.status}")
        expect(page).to have_content("Created at: #{alaina_invoice1.created_at.strftime("%A, %B %d, %Y")}")
        expect(page).to have_content("#{alaina.name}")
        expect(page).to_not have_content("#{alaina_invoice2.id}")
        expect(page).to have_content(sprintf("%.2f",alaina_invoice1.invoice_revenue/100.to_f))
    end

    describe 'both total invoice revenue and total revenue after discounts are displayed' do
        it 'shows total revenue for the invoice before discounts' do
            
            visit admin_invoice_path(alaina_invoice1)

            expect(page).to have_content("Total Revenue: $#{sprintf("%.2f", alaina_invoice1.invoice_revenue/100.to_f)}")
        end

        it 'shows total revenue after discounts from all merchants are applied' do
            discount_1 = jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 10)
            discount_2 = jewlery_city.bulk_discounts.create!(discount_percent: 25, quantity_threshold: 15)
            discount_3 = carly_silo.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 10)

            visit admin_invoice_path(alaina_invoice1)

            expect(page).to have_content("Total Discounted Revenue: $#{sprintf("%.2f", alaina_invoice1.invoice_discount_revenue/100.to_f)}")
        end
    end

    describe 'invoice items' do
        it 'shows all invoice items' do
            visit admin_invoice_path(alaina_invoice1)
            within "#invoice_items" do
                expect(page).to have_content(invoice_item_1.item.name)
                expect(page).to have_content(invoice_item_2.item.name)
                expect(page).to_not have_content(invoice_item_6.item.name)
            end
        end

        it 'shows all item info' do
            visit admin_invoice_path(alaina_invoice1)
            expect(page).to have_content(invoice_item_1.item.name)
            expect(page).to have_content("#{invoice_item_1.quantity}")
            expect(page).to have_content(sprintf("%.2f",invoice_item_1.unit_price/100.to_f))
            expect(page).to have_content("#{invoice_item_1.status}")
            expect(page).to_not have_content(sprintf('%.2f',invoice_item_6.unit_price/100.to_f))
        end
    end

    it 'invoice status is a select field and can be updated' do
        visit admin_invoice_path(alaina_invoice1)

        expect(alaina_invoice1.status).to eq('completed')
        within("#invoice_info") do
            select "in_progress", from: "invoice_status"
            click_button('Update Invoice')
            alaina_invoice1.reload
            expect(alaina_invoice1.status).to eq('in_progress')
        end
    end
end