class Transaction < ApplicationRecord
  enum result: %i[failed success]

  belongs_to :invoice
end
