#####################################################################
# Class name: FunctionController
# File name: function_controller.rb
# Description: Process the information of functions only for 
# federation
#####################################################################

class FunctionController < ApplicationController

  include Assertions

  # Description: Prepares data to be shown in the Function page, where a graph
  # is displayed.
  # Parameters: none.
  # Return: none.
  def show
    dates = HelperController.create_date
    assert_object_is_not_null( dates )
    datas = insert_expenses_functions( dates[ :begin ], dates[ :end ] )
    datas.transform_values! {|value| value.to_i}
    ordered_data = datas.sort_by { |_description, sumValue| -sumValue }
    @correct_datas = datas.to_json
    @top_10_data = get_top_10_data( ordered_data ).to_h.to_json
  end

  # Description: filters the data on the graph by year or month.
  # Parameters: none.
  # Return: none.
  def filter
    dates = find_dates( params[ :year ], params[ :month ] )
    assert_object_is_not_null( dates )
    expenses = get_expenses( dates )
    assert_object_is_not_null( expenses )
    expenses.transform_values! {|value| value.to_i}
    @correct_datas = expenses.to_json
    ordered_data = expenses.sort_by { |_description, sumValue| -sumValue }
    @top_10_data = get_top_10_data( ordered_data ).to_h.to_json
    render 'show'
  end

  # Description: gets 10 of the highest previously ordered data 
  # Parameters: ordered_data
  # Return: none
  def get_top_10_data( ordered_data )
    assert_object_is_not_null( ordered_data )
    assert_type_of_object( ordered_data, Hash )
    @data_not_sort = filter_top_n( ordered_data, 10 )
    @top_10_data = sort_by_description( @data_not_sort )
  end

  # Description: sorts a hash of data alphabetically by description.
  # Parameters: data.
  # Return: sorted_data.
  def sort_by_description( data )
    assert_object_is_not_null( data )
    assert_type_of_object( data, Hash )
    sorted_data = data.sort_by { |description, _sumValue| description }
    return sorted_data
  end

  # Description: filters a determined amount of elements at the top of a data
  # hash.
  # Parameters: hash, amount_of_elements_to_filter
  # Return: new_hash
  def filter_top_n( hash, amount_of_elements_to_filter )
    assert_object_is_not_null( hash )
    assert_type_of_object( hash, Hash )
    assert_object_is_not_null( amount_of_elements_to_filter )
    assert_type_of_object( amount_of_elements_to_filter, Fixnum )
    new_hash = {}

    hash.each_with_index do |( description, sumValue ), index|
      break if ( index >= amount_of_elements_to_filter )
      new_hash[ description ] = sumValue
    end
    assert_object_is_not_null( new_hash )
    new_hash
  end

  # Description: Finds the data related to the provided dates, and filters them
  # to show in the graph.
  # Parameters: year, month
  # Return: dates
  def find_dates( year = 'Até hoje!', month = 'Todos' )
    assert_type_of_object( year, String )
    assert_type_of_object( month, String )
    dates = {}
    if year == 'Até hoje!'
      dates = HelperController.create_date
    elsif month == 'Todos'
      dates = HelperController.create_date(
        from_month: 'Janeiro', end_month: 'Dezembro',
        from_year: year, end_year: year )
    else

      year_filter = year.to_i
      if month == 'Todos'
        date_hash = { from_month: 'Janeiro', end_month: 'Dezembro',
         from_year: year_filter, end_year: year_filter }
        dates = HelperController.create_date( date_hash )
      else
        date_hash = { from_month: month, end_month: month,
         from_year: year_filter, end_year: year_filter }
        dates = HelperController.create_date( date_hash )
      end
    end
    assert_object_is_not_null( dates )
    dates
  end

  # Description: Prepares a hash of expenses existing in a determined time
  # interval.
  # Parameters: dates.
  # Return: expenses.
  def get_expenses( dates )
    assert_object_is_not_null( dates )
    assert_type_of_object( dates, Hash )
    expenses = insert_expenses_functions( dates[ :begin ], dates[ :end ] )
    assert_object_is_not_null( expenses )
    expenses
  end

  # Description: Calls methods to convert an array of expenses into a hash of
  # expenses.
  # Parameters: begin_date, end_date.
  # Return: exp.
  def insert_expenses_functions( begin_date,end_date )
    assert_object_is_not_null( begin_date )
    assert_type_of_object( begin_date, String )
    assert_object_is_not_null( end_date )
    assert_type_of_object( end_date, String )
    expenses = find_functions_values( begin_date,end_date )
    exp = convert_to_a_hash( expenses )
    assert_object_is_not_null( exp )
    exp
  end

  # Description: Finds values and descriptions of expenses to display in the 
  # graph.
  # Parameters: begin_date, end_date.
  # Return: functions_expenses.
  def find_functions_values( begin_date, end_date )
    assert_object_is_not_null( begin_date )
    assert_type_of_object( begin_date, String )
    assert_object_is_not_null( end_date )
    assert_type_of_object( end_date, String )
    functions_expenses = FunctionGraph.where( year: 
      ( begin_date.year..end_date.year ) )
    .select( :description ).group( :description ).sum( :value ).to_json
  end

  # Description: Converts an array of expenses into a hash of expenses.
  # Parameters: expenses.
  # Return: expense_hash.
  def convert_to_a_hash( expenses )
    assert_object_is_not_null( expenses )
    assert_type_of_object( expenses, Array )
    expense_hash = JSON.parse( expenses )
  end

end
