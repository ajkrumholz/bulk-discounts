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
                 items: { merchant_id: merchant_id },
                 invoices: { status: :in_progress }
               )
               .any? do |invoice_item|
      invoice_item.applied_discount == self
    end
  end

  def valid_discount?
    superceding = BulkDiscount.where(merchant_id: merchant_id)
                              .where('discount_percent > ?', discount_percent)
                              .where('quantity_threshold <= ?', quantity_threshold)
    if superceding.empty?
      true
    else
      false
    end
  end
end
