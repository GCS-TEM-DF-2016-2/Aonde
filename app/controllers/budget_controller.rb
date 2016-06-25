# Controller of budget to manage the data of expenses and budget
class BudgetController < ApplicationController
  def show
    expense_month = process_expense( params[ :year ],params[ :id ].to_i )
    budget_month = process_budget( params[ :year ], params[ :id ],expense_month )
    data_budget = { 'expenses' => expense_month, 'budgets' => budget_month }
    respond_to do |format|
      format.json { render json: data_budget }
    end
  end

  def process_expense( year,id_public_agency )
    year ||= 2015
    expense_month = HelperController.expenses_year( id_public_agency, year )
    expense_month = initialize_hash( expense_month )
    expense_month = HelperController.int_to_month( expense_month ).transform_values! {|v| v.to_f}.to_a
    return expense_month
  end

  def process_budget( year, id_public_agency, expense_month )

    budget_month = [ ]
    begin
      budget_month = subtract_expenses_budget( id_public_agency, year,
                                                 expense_month )
    rescue Exception => error
      logger.error "#{error}"
    end
    return budget_month
  end
  def initialize_hash( expense_month )
    expenses_months = {}
    for month in 1..12
      if !expense_month[ month ]
        expenses_months[ month ] = 0
      else
        expenses_months[ month ] = expense_month[ month ]
      end
    end
    expenses_months
  end

  def subtract_expenses_budget( id_public_agency, year, expense )
    budget_array = [ ]
    begin
      budgets = BudgetAPI.get_budget( id_public_agency, year )
      unless expense.empty?
        budget_array = create_budget_array( expense, budgets, year )
      end
     rescue Exception => error
       raise "Não foi possível obter o orçamento do ano #{year} do Órgão Público desejado\n#{error}"
     end
    budget_array
  end

  def create_budget_array( expenses, budgets, year )
    budget_array = [ ]
    budget = budgets[ 0 ]
    if ( budget[ 'year' ] + 1 ) == year.to_i
      for i in 0..11
        value = expenses[ i ][ 1 ]
        budget[ 'value' ] -= value
        budget_array << budget[ 'value' ]
      end
    end

    budget_array
   end
   private :create_budget_array, :subtract_expenses_budget, :process_expense,
           :process_budget
end
