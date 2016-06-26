######################################################################
# Class name: BudgetController
# File name: budget_controller.rb
# Description: Controller of budget to manage the data of expenses and
# budget
#######################################################################

class BudgetController < ApplicationController

    include Assertions

    # Description: Renders a page in JSon format containing the information of a
    # specific budget.
    # Parameters: none.
    # Return: none.
    def show
        expense_month = process_expense( params[ :year ],params[ :id ].to_i )
        budget_month = process_budget( params[ :year ],
                                       params[ :id ], expense_month )
        data_budget = { 'expenses' => expense_month, 'budgets' => budget_month }
        assert_object_is_not_null( data_budget )
        respond_to do |format|
          format.json { render json: data_budget }
        end
    end

    # Description: Prepares the expenses of a given public agency, by year, in
    # hash format.
    # Parameters: year, id_public_agency.
    # Return: expense_month.
    def process_expense( year,id_public_agency )
        assert_type_of_object( year, String)
        if (year.nil?)
            year ||= 2015
        else
            # Nothing to do.
        end
        expense_month = HelperController.expenses_year( id_public_agency, year )
        expense_month = initialize_hash( expense_month )
        expense_month = HelperController.int_to_month( expense_month )
        expense_month = 
                      expense_month.transform_values! {|value| value.to_f}.to_a
        assert_object_is_not_null( expense_month )
        return expense_month
    end

    # Description: Prepares the budget of a given public agency, by month, in
    # array format.
    # Parameters: year, id_public_agency, expense_month
    # Return: budget_month.
    def process_budget( year, id_public_agency, expense_month )
        assert_object_is_not_null( year )
        assert_type_of_object( year, String )
        assert_object_is_not_null( id_public_agency )
        assert_type_of_object( id_public_agency, String )
        assert_object_is_not_null( expense_month )
        assert_type_of_object( expense_month, Array )
        budget_month = [ ]
        begin
            budget_month = subtract_expenses_budget( id_public_agency, year,
                                                     expense_month )
        rescue Exception => error
            logger.error "#{error}"
        end
        assert_object_is_not_null( budget_month )
        return budget_month
    end

    # Description: Prepares a hash of expenses by month.
    # Parameters: expense_month.
    # Return: expenses_months.
    def initialize_hash( expense )
        assert_object_is_not_null( expense )
        assert_type_of_object( expense, Hash)
        expenses_months = {}
        # Iterates through numbers 1 to 12, each one representing a month.
        for month in 1..12
            # Assigns expense 0 to a month, if no value exists in the expense 
            # hash.
            if !expense[ month ]
                expenses_months[ month ] = 0
            else
                expenses_months[ month ] = expense[ month ]
            end
        end
        assert_object_is_not_null( expenses_months )
        return expenses_months
    end

    # Description: Subtracts the expenses by the budgets of a year.
    # Parameters: id_public_agency, year, expense.
    # Return: budget_array.
    def subtract_expenses_budget( id_public_agency, year, expense )
        assert_object_is_not_null( id_public_agency )
        assert_type_of_object( id_public_agency, String )
        assert_object_is_not_null( year )
        assert_type_of_object( id_public_agency, String )
        assert_object_is_not_null( expense )
        assert_type_of_object( expense, Array )
        budget_array = []
        begin
            budgets = BudgetAPI.get_budget( id_public_agency, year )
            if (!expense.empty?)
                budget_array = create_budget_array( expense, budgets, year )
            else
                # Nothing to do.
            end
           rescue Exception => error
               raise "Não foi possível obter o orçamento do ano #{year} do\
               Órgão Público desejado\n#{error}"
         end
         assert_object_is_not_null( budget_array )
        return budget_array
    end

    # Description: Creates an array of budgets.
    # Parameters: expenses, budgets, year.
    # Return: budget_array.
    def create_budget_array( expenses, budgets, year )
        assert_object_is_not_null( expenses )
        assert_type_of_object( expenses, Array )
        assert_object_is_not_null( budgets )
        assert_type_of_object( budgets, Array )
        assert_object_is_not_null( year )
        assert_type_of_object( year, String )
        budget_array = [ ]
        budget = budgets[ 0 ]
        if ( budget[ 'year' ] + 1 ) == year.to_i
            for i in 0..11
              value = expenses[ i ][ 1 ]
              budget[ 'value' ] -= value
              budget_array << budget[ 'value' ]
            end
        else
            # Nothing to do.
        end
        return budget_array
    end

    private :create_budget_array, :subtract_expenses_budget, :process_expense,
           :process_budget

end
