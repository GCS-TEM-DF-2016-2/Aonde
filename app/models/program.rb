######################################################################
# Class name: Program
# File name: program.rb
# Description: Represents all programs in application
######################################################################

class Program < ActiveRecord::Base

  has_many :expense
  validates :name, presence: true
  
end
