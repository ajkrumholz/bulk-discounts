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

  def item_discount(merchant)
    Invoice.joins(items: [merchant: :bulk_discounts]).where(id: self.id, items: { merchant_id: merchant.id}).select('items.id as item_id, bulk_discounts.id, invoice_items.unit_price, quantity, quantity_threshold, discount_percent')
  end

  def calculate_discounted_revenue(merchant)
    discounted = item_discount(merchant).where.not('quantity < quantity_threshold')
    discounted_items = discounted.map { |item| item.item_id }
    discounted_revenue = discounted.sum('(quantity*invoice_items.unit_price)*(100-discount_percent)/100')
    full_price_revenue = item_discount(merchant).where('quantity < quantity_threshold').where.not(items: { id: discounted_items} ).select("items_id").distinct.sum('quantity*invoice_items.unit_price')
    discounted_revenue + full_price_revenue
  end
end
