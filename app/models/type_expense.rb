######################################################################
# Class name: TypeExpense
# File name:type_expense.rb
# Description: Represents all types expense in application
######################################################################

class TypeExpense < ActiveRecord::Base
  	belongs_to :expense
  	validates :description, presence: true
end
