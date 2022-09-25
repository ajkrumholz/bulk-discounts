require 'rails_helper'

RSpec.describe BulkDiscount do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:items).through(:merchant)}
  end

  describe 'validations' do
    it { should validate_presence_of :discount_percent }
    it { should validate_numericality_of :discount_percent }
    it { should validate_presence_of :quantity_threshold }
    it { should validate_numericality_of :quantity_threshold }
  end

  describe 'instance methods' do
    describe '#invoices_in_progress?' do
      it 'returns a boolean true if any invoices have a discount applied to them' do
        merchant_1 = Merchant.create!(name: Faker::Name.unique.name)
        discount_1 = merchant_1.bulk_discounts.create!(
            discount_percent: 10,
            quantity_threshold: 5
          )
        
        discount_2 = merchant_1.bulk_discounts.create!(
            discount_percent: 15,
            quantity_threshold: 8
          )
        customer = Customer.create!(first_name: Faker::Name.unique.first_name, last_name: Faker::Name.unique.last_name)
        licorice = merchant_1.items.create!(name: "Licorice Funnels", description: "Licorice Balls", unit_price: 1200)
        invoice_1 = customer.invoices.create!(status: "in_progress", created_at: "2012-01-30 14:54:09")
        invoice_2 = customer.invoices.create!(status: "in_progress", created_at: "2012-01-30 14:54:09")
        invoice_3 = customer.invoices.create!(status: "completed", created_at: "2012-01-30 14:54:09")
        invoice_item_1 = InvoiceItem.create!(invoice_id: invoice_1.id, item_id: licorice.id, quantity: 5, unit_price: 2700, status:"shipped" )
        invoice_item_2 = InvoiceItem.create!(invoice_id: invoice_2.id, item_id: licorice.id, quantity: 3, unit_price: 2700, status:"shipped" )
        invoice_item_3 = InvoiceItem.create!(invoice_id: invoice_3.id, item_id: licorice.id, quantity: 8, unit_price: 2700, status:"shipped" )
        
        expect(discount_1.invoices_in_progress?).to eq(true)
        expect(discount_2.invoices_in_progress?).to eq(false)
      end
    end

  end
end