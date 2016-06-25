#####################################################################
# Class name: BudgetAPITest.
# File name: budget_api_test.rb.
# Description: Test class that contains all functional tests for
# budget api.
#####################################################################

require 'test_helper'

class BudgetAPITest < ActiveSupport::TestCase
  def setup
    FakeWeb.allow_net_connect = false
  end

  def teardown
    FakeWeb.clean_registry
    FakeWeb.allow_net_connect = true
  end
  test 'the budgets not null' do
    create_fake_web
    budgets_not_nil = BudgetAPI.get_budget( 20_000 )
    assert_not_nil( budgets_not_nil )
  end

  test 'the empty return result of budgets' do
    create_fake_web

    not_exist_id = -1
    assert_raises( Exception ) do
      budget_epmty = BudgetAPI.get_budget( not_exist_id )
    end

  end

  test 'create the query of an year' do
    correct_query = '?exercicioURI loa:identificador 2012 . '
    query = BudgetAPI.send( :query_for_year, 2013 )
    assert_equal( correct_query, query )
  end

  test 'the result empty of a year' do
    query_empty = BudgetAPI.send( :query_for_year, 'Todos' )
    assert_empty( query_empty )
  end

  test 'the valid hash with budget' do
    budgets_data = {'results' => {'bindings' => [0]}}
    assert( BudgetAPI.send( :valid_data?, budgets_data ) )
  end

  test 'the empty bindings' do
    budgets_data = {'results' => {'bindings' => []}}
    assert_not( BudgetAPI.send( :valid_data?, budgets_data ) )
  end

  test 'the empty results' do
    budgets_data = {'results' => {}}
    assert_not( BudgetAPI.send( :valid_data?, budgets_data ) )
  end

  test 'the null results' do
    budgets_data = {'results' => nil}
    assert_not( BudgetAPI.send( :valid_data?, budgets_data ) )
  end

  test 'the null bindings' do
    budgets_data = {'results' => {'bindings' => nil}}
    assert_not( BudgetAPI.send( :valid_data?, budgets_data ) )
  end

  test 'error to obtain value of data' do
    url = create_url_all_years
    FakeWeb.register_uri( :get, url, body: '{"results":{"binding":[]}}' )
    assert_raise( Exception ) do
      BudgetAPI.send( :get_budget, 20_000 )
    end
  end

  test 'the size grow of budget by year' do
    budget_hash = { 'results' => { 'bindings' => [create_budget, create_budget]}}
    budget_years = []
    BudgetAPI.send( :add_budget_array, budget_years, budget_hash )
    expected_size = 2
    assert_equal( expected_size, budget_years.size )
  end
  test 'not grow size of array budget by year' do
    whithout_budget_hash = {'results' => {'bindings' => []}}
    budget_empty = []
    BudgetAPI.send( :add_budget_array, budget_empty, whithout_budget_hash )
    assert_empty( budget_empty )
  end
  test 'insertion of one budget in the array' do
    one_budget_hash = {'results' => {'bindings' => [create_budget]}}
    budget_years = []
    BudgetAPI.send( :add_budget_array, budget_years, one_budget_hash )
    expected_array = [{'year' => 2011, 'value' => 123_456}]
    assert_equal( expected_array, budget_years )
  end

  test 'the create of hash with budget' do
    budget_hash = create_budget
    budget_correct = BudgetAPI.send( :create_budget_year, budget_hash )
    expected_budget = {"year" => 2011, "value" => 123_456 }
    assert_equal( expected_budget, budget_correct )
  end
  test 'not null budget return' do
    budget_hash = create_budget
    budget_correct = BudgetAPI.send( :create_budget_year, budget_hash )
    assert_not_nil( budget_correct )
  end
  test 'empty budget return' do
    budget_hash = {"ano" => {"value" => nil}, "somaProjetoLei" => {"value" => "123456"}}
    budget_epmty = BudgetAPI.send( :create_budget_year, budget_hash )
    assert_empty( budget_epmty )
  end

  test 'the budget query encode' do
    year = 2015
    public_agency_id = '1'

    query_encode_expected = URI.encode( create_query( public_agency_id, year - 1 ) )
    query_encode = BudgetAPI.send( :generate_query, public_agency_id, year )

    assert_equal( query_encode_expected, query_encode )
  end

  test 'the budget query not encode' do
    year = 2012
    public_agency_id = '2'
    query_not_encode = create_query( public_agency_id, year )
    query_encode = BudgetAPI.send( :generate_query, public_agency_id, year )

    assert_not_equal( query_not_encode, query_encode )
  end
  test 'generate get correct url' do
    correct_url = create_url( 2014 )
    url_to_get = BudgetAPI.send( :get_url, '20000', 2015 )
    assert_equal( correct_url, url_to_get )
  end

  test 'generate get nil url' do
    url_not_nil = BudgetAPI.send( :get_url, '20202', 2015 )
    assert_not_nil( url_not_nil )
  end
  test 'exception parse json' do
    assert_raises( Exception ) do
      data_json = '{"first_key",test wrong hash}'
      BudgetAPI.send( :parse_json_to_hash, data_json )
    end
  end

  test 'correct parse json to ruby hash' do
    data_json = '{"first_key": [{"first_secondary":123},'\
                 '{"second_secondary":321},{"third":654}],'\
                 '"second_key": [{"first_secondary": "MarceloViado"}]}'

    data_hash = { 'first_key' => [{ 'first_secondary' => 123 },
                                  { 'second_secondary' => 321 }, { 'third' => 654 }],
                  'second_key' => [{ 'first_secondary' => 'MarceloViado' }] }

    json_changed = BudgetAPI.send( :parse_json_to_hash, data_json )
    assert_equal( data_hash, json_changed )
  end

  test 'nil parse json to ruby hash' do
    data_json = '{"first_key": [{"first_secondary":123},'\
                 '{"second_secondary":321},{"third":654}],'\
                 '"second_key": [{"first_secondary": "MarceloViado"}]}'

    json_changed = BudgetAPI.send( :parse_json_to_hash, data_json )

    assert_not_nil( json_changed )
  end

  test 'the get to API of budget' do
    create_fake_web

    public_agency_id = 20_000
    year = 2013
    data_api = BudgetAPI.send( :obtain_api_data, public_agency_id, year )

    assert_not_empty data_api
  end

  test 'the fail connection with API of budget' do
    create_fake_web
    assert_raise( Exception ) do

      year = 1000
      public_agency_id = 20_000
      data_api = BudgetAPI.send( :obtain_api_data, public_agency_id, year )

    end

  end

  private

  def create_query( public_agency_id, year )
    year_query = ''
    year = year.to_s
    year_query = '?exercicioURI loa:identificador ' + year + ' . ' unless year.nil?
    test_query =  'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> '\
                  'PREFIX loa: <http://vocab.e.gov.br/2013/09/loa#>'\
                  'SELECT ?ano, ( SUM( ?valorProjetoLei ) AS ?somaProjetoLei )'\
                  ' WHERE {?itemBlankNode loa:temExercicio ?exercicioURI . '\
                   + year_query + '?exercicioURI loa:identificador ?ano . '\
                  '?itemBlankNode loa:temUnidadeOrcamentaria ?uoURI . '\
                  '?uoURI loa:codigo "' + public_agency_id + '" . '\
                  '?itemBlankNode loa:valorProjetoLei ?valorProjetoLei . }'
    test_query
 end

  def create_fake_web
    for year in 2011..2014
      url = create_url( year )
      FakeWeb.register_uri( :get, url, body: '{"results":{"bindings":['\
        '{"ano": {"value":' + year.to_s + '},"somaProjetoLei":{"value":"1000"}}]}}' )
    end
    url_query = create_url_all_years
    FakeWeb.register_uri( :get, url_query, body: '{"results":{"bindings":['\
        '{"ano": {"value": "2014"},"somaProjetoLei":{"value":"1000"}}]}}' )
  end

  def create_url( year )
    url = 'http://aondebrasil.com:8890/sparql?default-graph-uri=&query='\
          'PREFIX%20rdf:%20%3Chttp://www.w3.org/1999/02/22-rdf-syntax-ns'\
          '%23%3E%20PREFIX%20loa:%20%3Chttp://vocab.e.gov.br/2013/09/loa'\
          '%23%3ESELECT%20?ano,%20( SUM( ?valorProjetoLei )%20AS%20?somaProje'\
          'toLei )%20WHERE%20%7B?itemBlankNode%20loa:temExercicio%20?exercic'\
          'ioURI%20.%20?exercicioURI%20loa:identificador%20' + year.to_s + '%20'\
          '.%20?exercicioURI%20loa:identificador%20?ano%20.%20?itemBlankNod'\
          'e%20loa:temUnidadeOrcamentaria%20?uoURI%20.%20?uoURI%20loa:codig'\
          'o%20%2220000%22%20.%20?itemBlankNode%20loa:valorProjetoLei%20?va'\
          'lorProjetoLei%20.%20%7D&debug=on&timeout=&format=application%2Fs'\
          'parql-results%2Bjson&save=display&fname='
   end

  def create_url_all_years
    url = 'http://aondebrasil.com:8890/sparql?default-graph-uri=&query=PREFIX'\
          '%20rdf:%20%3Chttp://www.w3.org/1999/02/22-rdf-syntax-ns%23%3E%20PR'\
          'EFIX%20loa:%20%3Chttp://vocab.e.gov.br/2013/09/loa%23%3ESELECT%20?'\
          'ano,%20( SUM( ?valorProjetoLei )%20AS%20?somaProjetoLei )%20WHERE%20%7'\
          'B?itemBlankNode%20loa:temExercicio%20?exercicioURI%20.%20?exercici'\
          'oURI%20loa:identificador%20?ano%20.%20?itemBlankNode%20loa:temUnid'\
          'adeOrcamentaria%20?uoURI%20.%20?uoURI%20loa:codigo%20%2220000%22%2'\
          '0.%20?itemBlankNode%20loa:valorProjetoLei%20?valorProjetoLei%20.%2'\
          '0%7D&debug=on&timeout=&format=application%2Fsparql-results%2Bjson&'\
          'save=display&fname='
  end

  def create_budget
    budget_hash = {"ano" => {"value" => "2011"}, "somaProjetoLei" => {"value" => "123456"}}
    budget_hash
  end
end
