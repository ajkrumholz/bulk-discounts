require 'rails_helper'
RSpec.describe InvoiceItem, type: :model do
  describe 'relationships' do
    it { should belong_to(:invoice) }
    it { should belong_to(:item) }
  end

  describe 'instance methods' do

  

    describe '#discount' do
      let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}
      let!(:carly_silo) { Merchant.create!(name: "Carly Simon's Candy Silo")}
  
      let!(:gold_earrings) { jewlery_city.items.create!(name: "Gold Earrings", description: "14k Gold 12' Hoops", unit_price: 12000) }
      let!(:silver_necklace) { jewlery_city.items.create!(name: "Silver Necklace", description: "An everyday wearable silver necklace", unit_price: 22000) }
      let!(:licorice_funnels) { carly_silo.items.create!(name: "Licorice Funnel", description: "An everyday licorice funnel", unit_price: 3500) }
  
      let!(:alaina) { Customer.create!(first_name: "Alaina", last_name: "Kneiling")}
  
      let!(:alaina_invoice1) { alaina.invoices.create!(status: "completed")}
  
      let!(:invoice_item_1) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: gold_earrings.id, quantity: 10, unit_price: 1300, status:"packaged" )}
      let!(:invoice_item_2) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: silver_necklace.id, quantity: 15, unit_price: 1300, status:"packaged" )}
      let!(:invoice_item_3) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: licorice_funnels.id, quantity: 10, unit_price: 1100, status:"packaged" ) }

      it 'returns the undiscounted revenue if no discounts apply' do
        discount = jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 20)

        expect(invoice_item_1.invoice_item_revenue).to eq(13000)
        expect(invoice_item_2.invoice_item_revenue).to eq(19500)
      end

      it 'only discounts items that meet the quantity threshold' do
        discount = jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 12)

        expect(invoice_item_1.invoice_item_revenue).to eq(13000)
        expect(invoice_item_2.invoice_item_revenue).to eq(15600)
      end

      it 'applies multiple discounts correctly' do
        discount_1 = jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 12)
        discount_2 = jewlery_city.bulk_discounts.create!(discount_percent: 15, quantity_threshold: 8)

        expect(invoice_item_1.invoice_item_revenue).to eq(11050)
        expect(invoice_item_2.invoice_item_revenue).to eq(15600)
      end

      it 'never applies a lesser discount' do
        discount_1 = jewlery_city.bulk_discounts.create!(discount_percent: 25, quantity_threshold: 10)
        discount_2 = jewlery_city.bulk_discounts.create!(discount_percent: 15, quantity_threshold: 8)

        expect(invoice_item_1.invoice_item_revenue).to eq(9750)
        expect(invoice_item_2.invoice_item_revenue).to eq(14625)
      end

      it 'never discounts another merchants items' do
        discount_1 = jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 10)
        discount_2 = jewlery_city.bulk_discounts.create!(discount_percent: 30, quantity_threshold: 15)

        expect(invoice_item_1.invoice_item_revenue).to eq(10400)
        expect(invoice_item_2.invoice_item_revenue).to eq(13650)
        expect(invoice_item_3.invoice_item_revenue).to eq(11000)
      end

      describe 'applied_discount_pct' do
        it 'returns the discount percent of the applied discount' do
          discount_1 = jewlery_city.bulk_discounts.create!(discount_percent: 20, quantity_threshold: 10)

          expect(invoice_item_1.applied_discount_pct).to eq(20)
        end
      end

    end

    describe '#item_name' do
      let!(:jewlery_city) { Merchant.create!(name: "Jewlery City Merchant")}
      let!(:gold_earrings) { jewlery_city.items.create!(name: "Gold Earrings", description: "14k Gold 12' Hoops", unit_price: 12000) }
      let!(:alaina) { Customer.create!(first_name: "Alaina", last_name: "Kneiling")}
      let!(:alaina_invoice1) { alaina.invoices.create!(status: "completed")}
      let!(:invoice_item_1) { InvoiceItem.create!(invoice_id: alaina_invoice1.id, item_id: gold_earrings.id, quantity: 10, unit_price: 1300, status:"packaged" )}

      it 'returns the string name of the item it represents' do
        expect(invoice_item_1.item_name).to eq("Gold Earrings")
      end
    end
    
  end

end