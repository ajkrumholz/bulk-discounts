class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :items, through: :merchant

  validates_presence_of :discount_percent, :quantity_threshold
  validates_numericality_of :discount_percent, :quantity_threshold

  def invoices_in_progress?
    InvoiceItem.joins(:invoice, :item)
      .select('items.merchant_id, invoices.status, invoice_items.*')
      .where(
        items: {merchant_id: self.merchant_id}, 
        invoices: {status: :in_progress})
        .any? do |invoice_item|
      invoice_item.applied_discount == self
    end
  end
end