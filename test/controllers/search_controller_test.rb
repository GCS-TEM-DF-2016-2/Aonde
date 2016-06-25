#####################################################################
# Class name: SearchControllerTest.
# File name: search_controller_test.rb.
# Description: Test class that contains all functional tests for
# search controller.
#####################################################################

require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test 'Should sum value expense of company' do
    create_entities
    id_company = 1
    company_expense = @controller.send( :expense_entities,:company_id, id_company )
    assert_equal( company_expense, 400 )
  end

  test 'Should sum value expense of program' do
    create_entities
    id_program = 1
    program_expense = @controller.send( :expense_entities,:company_id, id_program )
    assert_equal( program_expense, 400 )
  end

  test 'Should return a especific entity' do
    entities_for_search
    entity = @controller.send( :search_entities,PublicAgency, :public_agency_id, 'ministerio da educacao' )
    entity_compare = PublicAgency.find( 2 )
    expected_result = [[entity_compare, 0]]
    assert_equal( expected_result, entity )
  end

  test 'Should return a array of public agencies' do
    entities_for_search
    entity = @controller.send( :search_entities,PublicAgency, :public_agency_id, 'minis' )
    entity_compare_first = PublicAgency.find( 1 )
    entity_compare_seccond = PublicAgency.find( 2 )
    entity_compare_third = Company.find( 3 )
    expected_result = [[entity_compare_first, 0], [entity_compare_seccond, 0]]
    assert_equal( expected_result, entity )
  end

  test 'Should sum value expense of agency' do
    create_entities
    id_public_agency = 1
    agency_expense = @controller.send( :expense_entities,:company_id, id_public_agency )
    assert_equal( agency_expense, 400 )
  end

  test 'Routes to method index' do
    create_entities

    get :index, id: 1, search: 'valid', entity: 'Todos'

    assert_response :success

    assert assigns( :results )
  end

  test 'Should not search' do
    create_entities
    get :index, id: 1, search: 'Nv', entity: 'Todos'
  end

  def entities_for_search
    PublicAgency.create( id: 1, views_amount: 0, name: 'ministerio da saude' )
    PublicAgency.create( id: 2, views_amount: 0, name: 'ministerio da educacao' )
    Company.create( id: 3, name: 'ministro John' )
    PublicAgency.create( id: 4, views_amount: 0, name: 'agency' )
  end

  def create_entities
    PublicAgency.create( id: 1, views_amount: 0, name: 'valid Agency' )
    Program.create( id: 1, name: 'valid Program' )
    Company.create( id: 1, name: 'valid Company' )

    for i in 1..4

      Expense.create( document_number: '0000', payment_date: Date.new( 2013, i, 1 ),
                     public_agency_id: 1, program_id: 1, company_id: 1, value: 100 )

    end
  end
end
