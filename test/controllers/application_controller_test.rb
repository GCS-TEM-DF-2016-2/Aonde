#####################################################################
# Class name: ApplicationControllerTest.
# File name: application_controller_test.rb.
# Description: Test class that contains all functional tests for
# application controller.
#####################################################################

require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
		test "Should find public agency" do
				create_entities
				@controller.find_agency_by_id( 1 )
				assert assigns( :public_agency )
		end

		test "Should find superior public agency" do
				create_entities
				@controller.find_agency_by_id( 1 )
				assert assigns( :superior_public_agency )
		end

		def create_entities
				SuperiorPublicAgency.create( id: 1, name: 'valid SuperiorPublicAgency' )
		   		PublicAgency.create( id: 1, views_amount: 0, name: 'valid Agency', superior_public_agency_id: 1 )
		end
end
