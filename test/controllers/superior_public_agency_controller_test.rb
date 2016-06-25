#####################################################################
# Class name: SuperiorPublicAgencyControllerTest.
# File name: superior_public_agency_controller_test.rb.
# Description: Test class that contains all functional tests for
# superior public agency controller.
#####################################################################

require 'test_helper'

class SuperiorPublicAgencyControllerTest < ActionController::TestCase
  test 'Routes to method show' do
    create_entities

    get :show, id: 1

    assert_response :success

    assert assigns( :superior_agency )
    assert assigns( :data_superior_agency )
  end
  test 'find All public agencies with superior id' do
    create_entities
    public_agencies = @controller.find_public_agencies( 1 )
    assert_not_empty( public_agencies )
  end

  def create_entities
    SuperiorPublicAgency.create( id: 1, name: 'valid SuperiorPublicAgency' )
    PublicAgency.create( id: 1, name: 'Public Agency1', views_amount: 1, superior_public_agency_id: 1 )
    PublicAgency.create( id: 2, name: 'Public Agency2', views_amount: 1, superior_public_agency_id: 1 )
  end
end
