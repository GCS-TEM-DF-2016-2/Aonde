#####################################################################
# Class name: BudgetControllerTest.
# File name: budget_controller_test.rb.
# Description:  Test class that contains all functional tests for
# budget controller.
#####################################################################

require 'test_helper'
require 'database_cleaner'

class BudgetControllerTest < ActionController::TestCase
  def setup
    FakeWeb.allow_net_connect = false

    SuperiorPublicAgency.create( id: 1, name: 'valid SuperiorPublicAgency' )

    PublicAgency.create( id: 1, views_amount: 0, name: 'valid Agency',
                         superior_public_agency_id: 1 )
    PublicAgency.create( id: 2, views_amount: 0, name: 'valid Agency 2',
                         superior_public_agency_id: 1 )

    Expense.create( document_number: '0000', payment_date: Date.new( 2010, 1, 1 ),
                   public_agency_id: 1, value: 500 )
    Expense.create( document_number: '0001', payment_date: Date.new( 2010, 1, 2 ),
                   public_agency_id: 1, value: 500 )
    Expense.create( document_number: '0002', payment_date: Date.new( 2010, 1, 1 ),
                   public_agency_id: 1, value: 1000 )

    Expense.create( document_number: '0003', payment_date: Date.new( 2015, 1, 1 ),
                   public_agency_id: 2, value: 500 )
    Expense.create( document_number: '0004', payment_date: Date.new( 2015, 2, 1 ),
                   public_agency_id: 2, value: 500 )
    Expense.create( document_number: '0005', payment_date: Date.new( 2015, 3, 1 ),
                   public_agency_id: 2, value: 1000 )
  end

  def teardown
    FakeWeb.allow_net_connect = true
    FakeWeb.clean_registry
    DatabaseCleaner.clean
  end

  test 'Dont route to method show' do
    create_fake_budget
    assert_routing 'public_agency/2/budgets', controller: 'budget',
                   action: 'show', id: '2'
    get :show, id: 2, year: 2015, format: :json
    assert_response :success
  end

  test 'the subtract expense of expenses with budget' do
    create_fake_budget
    hash = [ [ 1, 29 ], [ 2, 0 ], [ 3, 0 ], [ 4, 0 ], [ 5, 0 ], [ 6, 0 ], [ 7, 23 ], [ 8, 0 ],
            [ 9, 0 ], [ 10, 0 ], [ 11, 0 ], [ 12, 0 ] ]

    expense_controller = @controller.send( :subtract_expenses_budget,2, 2015,hash )
    expected_array = [ 71, 71, 71, 71, 71, 71, 48, 48, 48, 48, 48, 48 ]
    assert_equal( expected_array, expense_controller )
  end

  test 'catch the raise of the subtract expense of expenses' do
    create_fake_budget_error
    hash = [ [ 1, 29 ], [ 2, 0 ], [ 3, 0 ], [ 4, 0 ], [ 5, 0 ], [ 6, 0 ], [ 7, 23 ], [ 8, 0 ],
            [ 9, 0 ], [ 10, 0 ], [ 11, 0 ], [ 12, 0 ] ]
    assert_raise( Exception ){

      expense_controller = @controller.send( :subtract_expenses_budget,2, 2015,hash )

    }
  end


  test "process the expense" do

    expense_month = @controller.send( :process_expense, 2015,1 )
    expense_expect = [ [ "Janeiro", 0 ], [ "Fevereiro", 0 ], [ "Março", 0 ],
                     [ "Abril", 0 ], [ "Maio", 0 ], [ "Junho", 0 ], [ "Julho", 0 ],
                     [ "Agosto", 0 ], [ "Setembro", 0 ], [ "Outubro", 0 ],
                     [ "Novembro", 0 ], [ "Dezembro", 0 ] ]
    assert_equal( expense_expect, expense_month )
  end
  test 'catch the raise of the process budget' do
    create_fake_budget_error
    hash = [ [ 1, 29 ], [ 2, 0 ], [ 3, 0 ], [ 4, 0 ], [ 5, 0 ], [ 6, 0 ], [ 7, 23 ], [ 8, 0 ],
            [ 9, 0 ], [ 10, 0 ], [ 11, 0 ], [ 12, 0 ] ]

    expense_controller = @controller.send( :process_budget, "2015", "1",hash )
    assert_empty( expense_controller )
  end
  test 'Should return a equals hashs' do

    hash_return = @controller.initialize_hash( {1 => 29,7 => 23} )
    hash = {1 => 29, 2 => 0, 3 => 0, 4 => 0, 5 => 0, 6 => 0, 7 => 23, 8 => 0, 9 => 0, 10 => 0,
           11 => 0, 12 => 0}
    assert_equal( hash_return, hash )
  end

  test 'Should return a array with budget by month' do
    expenses = [ [ '01/2015', 55 ], [ '02/2015', 100 ], [ '03/2015', 0 ],
               [ '04/2015', 0 ], [ '05/2015', 0 ], [ '06/2015', 0 ], [ '07/2015', 0 ],
               [ '08/2015', 0 ], [ '09/2015', 0 ], [ '10/2015', 0 ], [ '11/2015', 0 ],
               [ '12/2015', 0 ] ]
    budget = [ { 'year' => 2014, 'value' => 2055 } ]
    array_expect = [ 2000, 1900, 1900, 1900, 1900, 1900, 1900, 1900, 1900, 1900,
                   1900, 1900 ]
    array_return = @controller.send( :create_budget_array,expenses, budget, 2015 )
    assert_equal( array_expect, array_return )
  end

  def create_fake_budget
    url = 'http://aondebrasil.com:8890/sparql?default-graph-uri=&query='\
          'PREFIX%20rdf:%20%3Chttp://www.w3.org/1999/02/22-rdf-syntax-ns'\
          '%23%3E%20PREFIX%20loa:%20%3Chttp://vocab.e.gov.br/2013/09/loa'\
          '%23%3ESELECT%20?ano,%20( SUM( ?valorProjetoLei )%20AS%20?somaProje'\
          'toLei )%20WHERE%20%7B?itemBlankNode%20loa:temExercicio%20?exercic'\
          'ioURI%20.%20?exercicioURI%20loa:identificador%202014%20'\
          '.%20?exercicioURI%20loa:identificador%20?ano%20.%20?itemBlankNod'\
          'e%20loa:temUnidadeOrcamentaria%20?uoURI%20.%20?uoURI%20loa:codig'\
          'o%20%222%22%20.%20?itemBlankNode%20loa:valorProjetoLei%20?va'\
          'lorProjetoLei%20.%20%7D&debug=on&timeout=&format=application%2Fs'\
          'parql-results%2Bjson&save=display&fname='
    url_all = 'http://aondebrasil.com:8890/sparql?default-graph-uri=&query=PREFIX'\
          '%20rdf:%20%3Chttp://www.w3.org/1999/02/22-rdf-syntax-ns%23%3E%20PR'\
          'EFIX%20loa:%20%3Chttp://vocab.e.gov.br/2013/09/loa%23%3ESELECT%20?'\
          'ano,%20( SUM( ?valorProjetoLei )%20AS%20?somaProjetoLei )%20WHERE%20%7'\
          'B?itemBlankNode%20loa:temExercicio%20?exercicioURI%20.%20?exercici'\
          'oURI%20loa:identificador%20?ano%20.%20?itemBlankNode%20loa:temUnid'\
          'adeOrcamentaria%20?uoURI%20.%20?uoURI%20loa:codigo%20%222%22%2'\
          '0.%20?itemBlankNode%20loa:valorProjetoLei%20?valorProjetoLei%20.%2'\
          '0%7D&debug=on&timeout=&format=application%2Fsparql-results%2Bjson&'\
          'save=display&fname='
    content_body = '{"results":{"bindings":[ '\
          '{"ano": {"value": "2014"},"somaProjetoLei":{"value":"100"}} ]}}'
    FakeWeb.register_uri( :get, url, body: content_body )
    FakeWeb.register_uri( :get, url_all, body: content_body )
  end

  def create_fake_budget_error
    url_error = 'http://aondebrasil.com:8890/sparql?default-graph-uri=&query=PREFIX'\
          '%20rdf:%20%3Chttp://www.w3.org/1999/02/22-rdf-syntax-ns%23%3E%20PR'\
          'EFIX%20loa:%20%3Chttp://vocab.e.gov.br/2013/09/loa%23%3ESELECT%20?'\
          'ano,%20( SUM( ?valorProjetoLei )%20AS%20?somaProjetoLei )%20WHERE%20%7'\
          'B?itemBlankNode%20loa:temExercicio%20?exercicioURI%20.%20?exercici'\
          'oURI%20loa:identificador%20?ano%20.%20?itemBlankNode%20loa:temUnid'\
          'adeOrcamentaria%20?uoURI%20.%20?uoURI%20loa:codigo%20%222%22%2'\
          '0.%20?itemBlankNode%20loa:valorProjetoLei%20?valorProjetoLei%20.%2'\
          '0%7D&debug=on&timeout=&format=application%2Fsparql-results%2Bjson&'\
          'save=display&fname='
    FakeWeb.register_uri( :get, url_error, body: "{'results: {}'}" )
  end
end
