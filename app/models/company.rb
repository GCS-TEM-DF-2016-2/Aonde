######################################################################
# Class name: Company
# File name: company.rb
# Description: Represents all companies in application
######################################################################

class Company < ActiveRecord::Base
	has_many :expense
end
