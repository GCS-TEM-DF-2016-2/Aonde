# type_expense_controller.rb
# Obtain and process the data of expenses associate to type expense
# of a public agency

class TypeExpenseController < ApplicationController
    def show
        find_agency_by_id(params[:id])
        params[:year] = '2015' unless params[:year]
        data_type_expense = get_expense_by_type(params[:id], params[:year])

        respond_to do |format|
            format.json { render json: data_type_expense }
        end
    end

    def get_expense_by_type(id_public_agency, year = '2015')
        all_expenses = HelperController
          .find_expenses_entity(year, id_public_agency,
            :type_expense, :description)

        list_type_expenses = []
        total_expense = 0

        all_expenses.each do |type_expense|
            list_type_expenses << { name: type_expense[0], value: type_expense[1] }
            total_expense += type_expense[1]
        end

        define_color(total_expense, list_type_expenses)
        list_type_expenses
    end

    def define_color(total_expense, list_type_expenses)
        list_type_expenses.each do |expense|
            expense_per_cent = expense[:value] * 100 / total_expense
            expense[:colorValue] = expense_per_cent.to_i
        end
    end
end
