require 'rails_helper'

RSpec.describe 'admin invoice index' do

    let!(:customer) { Customer.create!(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name)}

    let!(:invoice_1) { customer.invoices.create!(status: :completed) }
    let!(:invoice_2) { customer.invoices.create!(status: :in_progress) }
    let!(:invoice_3) { customer.invoices.create!(status: :cancelled) }
    let!(:invoice_4) { customer.invoices.create!(status: :cancelled) }
    
    it 'shows all invoices' do
        visit admin_invoices_path
        expect(page).to have_content(invoice_1.id)
        expect(page).to have_content(invoice_2.id)
        expect(page).to have_content(invoice_3.id)
        expect(page).to have_content(invoice_4.id)
    end
end