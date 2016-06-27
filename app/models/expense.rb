######################################################################
# Class name: Expense
# File name: expense.rb
# Description: Represents all expenses in application
######################################################################

class Expense < ActiveRecord::Base

    belongs_to :program
    belongs_to :public_agency
    belongs_to :function
    belongs_to :type_expense
    belongs_to :company
    validates :document_number, presence: true
    validates :payment_date, presence: true
    validates :value, numericality: {greater_than: -1}
    
end
