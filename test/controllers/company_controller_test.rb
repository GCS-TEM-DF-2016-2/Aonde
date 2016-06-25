#####################################################################
# Class name: CompanyControllerTest.
# File name: company_controller_test.rb.
# Description: Test class that contains all functional tests for
# company controller.
#####################################################################

require 'test_helper'
require 'database_cleaner'

class CompanyControllerTest < ActionController::TestCase
  def setup
    SuperiorPublicAgency.create( id: 1, name: 'valid SuperiorPublicAgency' )
    PublicAgency.create( id: 1, views_amount: 0, name: 'orgao3', superior_public_agency_id: 1 )
    PublicAgency.create( id: 2, views_amount: 0, name: 'orgao2', superior_public_agency_id: 1 )
    date = Date.new( 2015, 1, 2 )
    public_agency_first = PublicAgency.first
    public_agency_second = PublicAgency.second
    Expense.create( document_number: 1, payment_date: date, value: 5, public_agency_id: 1 )
    Expense.create( document_number: 2, payment_date: date, value: 9, public_agency_id: 1 )
    Expense.create( document_number: 3, payment_date: date, value: 13, public_agency_id: 2 )

    nome_company = %w( CIA Comercial )
    array = []
    i = 1
    2.times do
      date = Date.new( 2015, i, i )
      company = Company.create( id: i, name: nome_company[i - 1] )
      2.times do
        Expense.create( document_number: i, payment_date: date, value: i + 5, company_id: company.id )
        i += 1
      end
      i -= 1
    end
  end

  def teardown
    DatabaseCleaner.clean
  end

  #   test 'Route to method show and the result of the request' do
  #
  #     get :show, id: 1
  #     assert_response :success
  #
  #   end

  test 'Route to method find and the result of the request' do
    assert_routing '/company/1', controller: 'company', action: 'find', id: '1'
    get :find, id: 1
    assert_response :success
  end

  test 'Route to method show and the result of the request on company controller' do
    assert_routing 'public_agency/1/companies',
                   controller: 'company', action: 'show', id: '1'
    get :show, id: 1,year: '2014', format: :json
    assert_response :success
  end

  test 'should return a node' do
    node = [
      { 'data' => { 'id' => 'empresa' }, 'position' => { 'x' => 0, 'y' => 400 } },
      { 'data' => { 'id' => 'Órgãos Públicos' } }, { 'data' => { 'id' => 'qtde Contratações' } }
    ]

    node_test = @controller.send( :generate_company_node,'empresa' )

    assert_equal( node, node_test )
  end

  test 'should return a especific expense' do
    public_agency = PublicAgency.new( id: 1 )
    expense = Expense.where( public_agency_id: public_agency.id ).count

    test_expense = @controller.send( :find_hiring_count,public_agency )

    assert_equal( expense, test_expense )
  end

  test 'should return a public_agency node' do
    few_hash = { 'nome2' => 2, 'nome3' => 3, 'nome1' => 1
               }

    company_node = [
      { 'data' => { 'id' => 'empresa' }, 'position' =>
      { 'x' => 0, 'y' => 400 } },
      { 'data' => { 'id' => 'Órgãos Públicos' } },
      { 'data' => { 'id' => 'qtde Contratações' } }
    ]

    node = [[{ 'data' => { 'id' => 'empresa' }, 'position' => { 'x' => 0, 'y' => 400 }
    }, { 'data' => { 'id' => 'Órgãos Públicos' } }, { 'data' =>     { 'id' => 'qtde Contratações' } }, { 'data' =>     { 'id' => 'nome2', 'parent' => 'Órgãos Públicos' }, 'position' =>     { 'x' => 400, 'y' => 50 } }, { 'data' => { 'id' => 2, 'parent' => 'qtde Contratações'
    }, 'position' => { 'x' => 700, 'y' => 50 } }, { 'data' =>     { 'id' => 'nome3', 'parent' => 'Órgãos Públicos' }, 'position' =>     { 'x' => 400, 'y' => 100 } }, { 'data' => { 'id' => 3, 'parent' => 'qtde Contratações'
    }, 'position' => { 'x' => 700, 'y' => 100 } }, { 'data' =>     { 'id' => 'nome1', 'parent' => 'Órgãos Públicos' }, 'position' =>     { 'x' => 400, 'y' => 150 } }, { 'data' => { 'id' => 1, 'parent' => 'qtde Contratações'
    }, 'position' => { 'x' => 700, 'y' => 150 } }], [{ 'data' =>     { 'source' => 'nome2', 'target' => 'empresa' } }, { 'data' =>     { 'source' => 2, 'target' => 'nome2' } }, { 'data' =>     { 'source' => 'nome3', 'target' => 'empresa' } }, { 'data' =>     { 'source' => 3, 'target' => 'nome3' } }, { 'data' =>     { 'source' => 'nome1', 'target' => 'empresa' } }, { 'data' =>     { 'source' => 1, 'target' => 'nome1' } }]]

    test_node = @controller.send( :generate_public_agency_node,'empresa', few_hash, company_node )

    assert_equal( node, test_node )
  end

  test 'should find public agencies' do
    expenses = Expense.all
    expected_hash = [['orgao2', 1], ['orgao3', 2]]
    hash_returned = @controller.send( :find_public_agencies,expenses )

    assert_equal( expected_hash, hash_returned )
  end

  test 'should find hiring count' do
    public_agency = PublicAgency.first
    counting = @controller.send( :find_hiring_count,public_agency )
    expected_counting = 2

    assert_equal( counting, expected_counting )
  end
end
