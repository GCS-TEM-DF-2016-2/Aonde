######################################################################
# Class name: Budget
# File name: budget.rb
# Description: Represents all budgets in application
######################################################################

class Budget < ActiveRecord::Base

	  belongs_to :public_agency
	  
end
