#####################################################################
# Class name: PublicAgencyController
# File name: public_agency_controller.rb
# Description: Controller used for doing communication between the
# views of public_agency and the model PublicAgency.
#####################################################################

# public_agency.rb
# Create a class to handle the data related with public agencies
class PublicAgencyController < ApplicationController
    # list of all public agencies in DB
    def index
        @public_agencies = PublicAgency.all
        @total_expense_agency = {}
        @public_agencies.each do |agency|
            @total_expense_agency[ agency.id ] = PublicAgencyGraph
              .where( id_public_agency: agency.id ).sum( :value )
        end
    end

    # Find the data of one public agency to show in the view with chart
    def show
        find_agency_by_id( params[ :id ] )
        increment_views_amount( @public_agency )
    end

    public

    def agency_chart
        params[ :year ] = '2015' unless params[ :year ]
        get_expenses_for_public_agency = HelperController.expenses_year( params[ :id ]
          .to_i, params[ :year ] )
        list_expenses = change_type_list_expenses( get_expenses_for_public_agency,
          params[ :year ] )

        respond_to do |format|
            format.json { render json: list_expenses }
        end
    end

    # methods that's need to be private
    private

    def increment_views_amount( public_agency )
        views_amount = public_agency.views_amount
        views_amount += 1
        public_agency.update( views_amount: views_amount )
    end

    def get_expenses_for_public_agency( id_public_agency )
        total_expense = Expense.where( public_agency_id: id_public_agency ).sum( :value )

        return total_expense
    end

    def change_type_list_expenses( expenses_month, year )
        HelperController.int_to_month( expenses_month )
        temporary_expense = { year => expenses_month }

        return temporary_expense
    end
end
