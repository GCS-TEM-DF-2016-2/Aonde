######################################################################
# Class name: SuperiorPublicAgency
# File name: superiror_public_agency.rb
# Description: Represents all superior public agencys in application
######################################################################

class SuperiorPublicAgency < ActiveRecord::Base
  	has_many :public_agencies
  	validates :name, presence: true
end
