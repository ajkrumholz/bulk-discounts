class Invoice < ApplicationRecord
  enum status: [:cancelled, :completed, :in_progress]
  
  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items

  def self.incomplete_invoices
    where("status = 2").order(:created_at)
  end

  def customer_name
    customer.name
  end

  def merchant_invoice_items(merchant)
    invoice_items.where( invoice_items: { item_id: merchant.items.ids})
  end

  def invoice_revenue
    invoice_items.sum('quantity*invoice_items.unit_price')
  end

  def invoice_discount_revenue
    invoice_items.sum do |invoice_item|
      invoice_item.invoice_item_revenue
    end
  end

  def merchant_invoice_revenue(merchant)
    invoice_items.where(item_id: merchant.items.ids)
    .sum('quantity*unit_price')
  end
  
  def merchant_discount_revenue(merchant)
    merchant_invoice_items(merchant).sum do |invoice_item|
      invoice_item.invoice_item_revenue
    end
  end

  def set_invoice_item_discount
    items.each do |item|
      invoice_item = InvoiceItem.find_by(invoice_id: self.id, item_id: item.id)
      discount = invoice_item.applied_discount_pct
      invoice_item.update(discount: discount)
    end
  end
end
  # def item_discount(merchant)
  #   Invoice.joins(items: [merchant: :bulk_discounts]).where(id: self.id, items: { merchant_id: merchant.id}).select('items.id as item_id, bulk_discounts.id, invoice_items.unit_price, quantity, quantity_threshold, discount_percent')
  # end

  # def merchant_discount_revenue(merchant)
  #   require 'pry'; binding.pry
  #   discounted = item_discount(merchant).where.not('quantity < quantity_threshold')
  #   discounted_items = discounted.map { |item| item.item_id }
  #   discounted_revenues_ary = discounted.select('(quantity*invoice_items.unit_price)*(100-discount_percent)/100 as revenue').map { |item| [item.item_id, item.revenue] }
  #   hash = Hash.new { |h,k| h[k] = [] }
  #   discounted_revenues_ary.each do |element|
  #     hash[element[0]] << element[1]
  #   end
  #   biggest_discounts = hash.values.map { |array| array.min }
  #   full_price_revenue = item_discount(merchant).where('quantity < quantity_threshold').where.not(items: { id: discounted_items} ).select("items_id").distinct.sum('quantity*invoice_items.unit_price')
  #   biggest_discounts.sum + full_price_revenue
  # end


  # def merchant_discount_revenue(merchant)
  #   merchant_invoice_revenue(merchant) - merchant_discount(merchant)
  # end