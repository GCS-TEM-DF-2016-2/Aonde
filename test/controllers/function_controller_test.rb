#####################################################################
# Class name: FunctionControllerTest.
# File name: function_controller_test.rb.
# Description: Test class that contains all functional tests for
# function controller.
#####################################################################

require 'test_helper'
require 'database_cleaner'

class FunctionControllerTest < ActionController::TestCase
  def teardown
    DatabaseCleaner.clean
  end

  test 'Should sort by sumValue' do
    hash = { 'C terceira' => 3, 'B segunda' => 2, 'A primeira' => 1 }
    hash = @controller.sort_by_description( hash )
    expected_hash = [ [ 'A primeira', 1 ], [ 'B segunda', 2 ], [ 'C terceira', 3 ] ]
    assert_equal( expected_hash, hash )
  end

  test 'Should find all dates until today' do
    first_date = Date.new( 2009, 1, 1 )
    last_date = Date.new( 2020, 12, 31 )
    expected_date = { begin: first_date, end: last_date }
    dates = @controller.find_dates
    assert_equal( dates, expected_date )
  end

  test 'Should find dates in a year' do
    first_date = Date.new( 2015, 1, 1 )
    last_date = Date.new( 2015, 12, 31 )
    expected_date = { begin: first_date, end: last_date }
    dates = @controller.find_dates( '2015' )
    assert_equal( dates, expected_date )
  end

  test 'Should find dates in a month' do
    first_date = Date.new( 2015, 12, 1 )
    last_date = Date.new( 2015, 12, 31 )
    expected_date = { begin: first_date, end: last_date }
    dates = @controller.find_dates( year = '2015', month = 'Dezembro' )
    assert_equal( dates, expected_date )
  end

  test 'Empty return of method to insert expenses' do
    begin_date = Date.new( 2015, 1, 12 )
    end_date = Date.new( 2015, 1, 31 )
    expenses_function = @controller
                        .insert_expenses_functions( begin_date, end_date )
    assert_empty( expenses_function )
  end

  test 'Route to method show' do
    assert_routing '/functions', controller: 'function', action: 'show'
    get :show
    assert_response :success
  end

  test 'Route to method filter' do
    get :filter, year: '2015', month: 'Todos'
    assert_response :success
  end

  test 'Should convert to a hash' do
    hash_to_json = [ { 'key1' => 1 }, { 'key2' => 2 } ].to_json
    expected_hash = [ { 'key1' => 1 }, { 'key2' => 2 } ]
    returned_hash = @controller.convert_to_a_hash( hash_to_json )
    assert_equal( expected_hash, returned_hash )
  end

  test 'Should not convert to a hash' do
    hash = [ { 'key1' => 1 }, { 'key2' => 2 } ].to_json
    expected_hash = { { 'key1' => 1 } => { 'key2' => 2 } }
    returned_hash = @controller.convert_to_a_hash( hash )
    assert_not_equal( expected_hash, returned_hash )
  end

  test 'Should return the n first elements of a hash' do
    hash_with_11 = { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11 }

    hash_result = @controller.filter_top_elements( hash_with_11, 4 )
    hash_with_4 = { a: 1, b: 2, c: 3, d: 4 }
    assert_equal( hash_result, hash_with_4 )
  end

  test 'Should return the hash if its length < n' do
    hash_with_2 = { a: 1, b: 2 }

    hash_result = @controller.filter_top_elements( hash_with_2, 900 )
    assert_equal( hash_result, hash_with_2 )
  end

  test 'Should return empty hash' do
    hash_empty = {}

    hash_result = @controller.filter_top_elements( hash_empty, 4 )
    assert_equal( hash_result, hash_empty )
  end
end
