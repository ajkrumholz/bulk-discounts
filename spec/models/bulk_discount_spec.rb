require 'rails_helper'

RSpec.describe BulkDiscount do
  describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of :discount_percent }
    it { should validate_numericality_of :discount_percent }
    it { should validate_presence_of :quantity_threshold }
    it { should validate_numericality_of :quantity_threshold }
  end
end