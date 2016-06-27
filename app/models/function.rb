######################################################################
# Class name: Function
# File name: function.rb
# Description: Represents all functions in application
######################################################################

class Function < ActiveRecord::Base

	has_many :expense
	
end
