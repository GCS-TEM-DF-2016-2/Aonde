#####################################################################
# Class name: TypeExpenseController
# File name: search_controller.rb
# Description: Process the request of search for a key word for
# public agency, programs or companies.
#####################################################################

class SearchController < ApplicationController

    # Description: This method is called to make view of this class.
    # Parameters: none.
    # Return: none.
    def index
        search = params[:search]
        @results = {}
        if search.tr( ' ', '' ).length > 4
          @results = find_entities( search )
        else
          logger.warn 'Try search with less the 5 characters'
        end
    end

    # Description: This method find public agencys with one string to search.
    # Parameters: keyword.
    # Return: entities.
    def find_entities( keyword )
        public_agencies = search_entities( PublicAgency, :public_agency_id,
         keyword )
        programs = search_entities( Program, :program_id, keyword )
        companies = search_entities( Company, :company_id, keyword )
        entities = { agency: public_agencies, program: programs, 
          company: companies }
        return entities
    end

    # Description: This method search expenses of an especifuc public agency.
    # Parameters: class_entity, name_field, keyword.
    # Return: array_total_expense_entity.
    def search_entities( class_entity, name_field, keyword )
        entities = class_entity.select( :name, :id ).where( 'name LIKE ?',
         "%#{keyword}%" )
        total_expense_entity = {}
        entities.each do |entity|
          total_expense_entity[entity] = expense_entities( name_field,
           entity.id )
        end

        array_total_expense_entity = total_expense_entity.to_a

        return array_total_expense_entity
    end

    # Description: This method take the sum of all expenses with an especific
    # id.
    # Parameters: name_field, entity_id.
    # Return: total_expense.
    def expense_entities( name_field, entity_id )
        total_expense = Expense.where( name_field => entity_id ).sum( :value )
        return total_expense
    end

    private :expense_entities, :search_entities, :find_entities
end
