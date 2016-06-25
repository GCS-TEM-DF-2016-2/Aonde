######################################################################
# Class name: PublicAgency
# File name: public_agency.rb
# Description: Represents all public agencys in application
######################################################################

class PublicAgency < ActiveRecord::Base
  belongs_to :superior_public_agency
  has_many :expenses
  has_many :budgets

#including validation.
  validates :name, presence: true
  validates :views_amount, numericality: {greater_than: -1}

end
