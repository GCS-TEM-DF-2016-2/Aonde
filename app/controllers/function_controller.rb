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
        time_interval = HelperController.create_date
        assert_object_is_not_null( time_interval )
        function_expenses_by_date = insert_expenses_functions( 
                                      time_interval[ :begin ], 
                                      time_interval[ :end ] )
        function_expenses_by_date.transform_values! {|value| value.to_i}
        ordered_function_expenses_by_date = 
        function_expenses_by_date.sort_by { |_description, sumValue| -sumValue }
        @FUNCTION_EXPENSES = function_expenses_by_date.to_json
        @TOP_10_DATA = get_top_10_data( 
                                ordered_function_expenses_by_date ).to_h.to_json
    end

    # Description: Filters the data on the graph by selected year and month.
    # Parameters: none.
    # Return: none.
    def filter
        time_interval = find_dates( params[ :year ], params[ :month ] )
        assert_object_is_not_null( time_interval )
        expenses = get_expenses( time_interval )
        assert_object_is_not_null( expenses )
        expenses.transform_values! {|value| value.to_i}
        @FUNCTION_EXPENSES = expenses.to_json
        ordered_expenses = 
                        expenses.sort_by { |_description, sumValue| -sumValue }
        @TOP_10_DATA = get_top_10_data( ordered_expenses ).to_h.to_json
        render 'show'
    end

    # Description: Gets 10 of the highest previously ordered data 
    # Parameters: ordered_data
    # Return: none
    def get_top_10_data( ordered_data )
        assert_object_is_not_null( ordered_data )
        assert_type_of_object( ordered_data, Hash )
        @UNSORTED_DATA = filter_top_elements( ordered_data, 10 )
        @TOP_10_DATA = sort_by_description( @UNSORTED_DATA )
    end

    # Description: sorts a hash of data alphabetically by description.
    # Parameters: data.
    # Return: data_sorted_by_description.
    def sort_by_description( data )
        assert_object_is_not_null( data )
        assert_type_of_object( data, Hash )
        data_sorted_by_description = 
                          data.sort_by { |description, _sumValue| description }
        return data_sorted_by_description
    end

    # Description: filters a determined amount of elements at the top of a data
    # hash.
    # Parameters: hash, amount_of_elements_to_filter
    # Return: ordered_data_in_hash
    def filter_top_elements( data_in_hash, amount_of_elements_to_filter )
        assert_object_is_not_null( data_in_hash )
        assert_type_of_object( data_in_hash, Hash )
        assert_object_is_not_null( amount_of_elements_to_filter )
        assert_type_of_object( amount_of_elements_to_filter, Fixnum )
        ordered_data_in_hash = {}

        data_in_hash.each_with_index do |( description, summed_value ), index|
            if ( index >= amount_of_elements_to_filter )
                break
            else
                ordered_data_in_hash[ description ] = summed_value
            end
        end
        assert_object_is_not_null( ordered_data_in_hash )
        return ordered_data_in_hash
    end

    # Description: Finds the data related to the provided dates, and filters 
    # them to show in the graph.
    # Parameters: year, month
    # Return: dates
    def find_dates( year = 'Até hoje!', month = 'Todos' )
        assert_type_of_object( year, String )
        assert_type_of_object( month, String )
        time_interval = {}
        if year == 'Até hoje!'
            time_interval = HelperController.create_date
        elsif month == 'Todos'
            time_interval = HelperController.create_date(
                        from_month: 'Janeiro', end_month: 'Dezembro',
                        from_year: year, end_year: year )
        else
            year_filter = year.to_i
            if month == 'Todos'
                date_hash = { from_month: 'Janeiro', end_month: 'Dezembro',
                              from_year: year_filter, end_year: year_filter }
                time_interval = HelperController.create_date( date_hash )
          else
              date_hash = { from_month: month, end_month: month,
                                from_year: year_filter, end_year: year_filter }
              time_interval = HelperController.create_date( date_hash )
          end
        end
        assert_object_is_not_null( time_interval )
        return time_interval
    end

    # Description: Prepares a hash of expenses existing in a determined time
    # interval.
    # Parameters: time_interval.
    # Return: expenses.
    def get_expenses( time_interval )
        assert_object_is_not_null( time_interval )
        assert_type_of_object( time_interval, Hash )
        expenses = insert_expenses_functions( time_interval[ :begin ], 
                                              time_interval[ :end ] )
        assert_object_is_not_null( expenses )
        return expenses
    end

    # Description: Calls methods to convert an array of expenses into a hash of
    # expenses.
    # Parameters: begin_date, end_date.
    # Return: exp.
    def insert_expenses_functions( begin_date, end_date )
        assert_object_is_not_null( begin_date )
        assert_type_of_object( begin_date, String )
        assert_object_is_not_null( end_date )
        assert_type_of_object( end_date, String )
        expenses = find_functions_values( begin_date,end_date )
        hashed_expenses = convert_to_a_hash( expenses )
        assert_object_is_not_null( hashed_expenses )
        return hashed_expenses
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
        return functions_expenses
    end

    # Description: Converts an array of expenses into a hash of expenses.
    # Parameters: expenses.
    # Return: hashed_expenses.
    def convert_to_a_hash( expenses )
        assert_object_is_not_null( expenses )
        assert_type_of_object( expenses, Array )
        hashed_expenses = JSON.parse( expenses )
        return hashed_expenses
    end

end
