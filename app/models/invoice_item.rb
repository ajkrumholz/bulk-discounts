class InvoiceItem < ApplicationRecord
  enum status: [ :pending, :packaged, :shipped ]
  belongs_to :invoice
  belongs_to :item

  def invoice_item_revenue
    revenue = quantity * unit_price
    if self.applicable_discounts == []
      revenue
    else
      discount = self.applied_discount.discount_percent
      revenue * ((100 - discount) / 100.to_f)
    end
  end

  def applied_discount
    applicable_discounts.order(discount_percent: :desc).first
  end

  def applicable_discounts
    item.merchant.bulk_discounts.where('quantity_threshold <= ?', quantity)
  end

  def applied_discount_pct
    applied_discount.discount_percent
  end

  def item_name
    item.name
  end
end