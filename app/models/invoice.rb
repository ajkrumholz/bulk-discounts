class Invoice < ApplicationRecord
  enum status: [:cancelled, :completed, :in_progress]
  
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.incomplete_invoices
    where("status = 2").order(:created_at)
  end

  def merchant_items(merchant)
    self.items.where(items: { merchant_id: merchant.id } ).distinct
  end

  def calculate_invoice_revenue(merchant)
    Invoice.joins(:items).where(id: self.id, items: { merchant_id: merchant.id }).sum('quantity*invoice_items.unit_price')
  end

  def calculate_discounted_revenue(merchant)
    require 'pry'; binding.pry
    Invoice.joins(items: [merchant: :bulk_discounts])
  end
end
