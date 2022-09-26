class RemoveBulkDiscountIdFromInvoiceItems < ActiveRecord::Migration[5.2]
  def change
    remove_column :invoice_items, :bulk_discount_id, :bigint
  end
end
