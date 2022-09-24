class BulkDiscount < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  validates_presence_of :discount_percent, :quantity_threshold
  validates_numericality_of :discount_percent, :quantity_threshold
end