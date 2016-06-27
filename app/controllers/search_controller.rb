#####################################################################
# Module name: SearchController
# File name: search_controller.rb
# Description: Contains all the methods to make search work.
#####################################################################

class SearchController < ApplicationController
    def index
        search = params[:search]
        @results = {}
        if search.tr( ' ', '' ).length > 4
            @results = find_entities( search )
        else
            logger.warn 'Try search with less the 5 characters'
        end
    end

    # Description: Recovers an array with all the object for each
    # types of entities.
    # Parameters: keyword.
    # Return: entities.
    def find_entities( keyword )
        public_agencies = search_entities( PublicAgency, :public_agency_id, keyword )
        programs = search_entities( Program, :program_id, keyword )
        companies = search_entities( Company, :company_id, keyword )
        entities = { agency: public_agencies, program: programs, company: companies }

        return entities
    end

    # Description: Returns all the expenses for a specific entity.
    # Parameters: class_entity,name_field,keyword.
    # Return: total_expense_entity.
    def search_entities( class_entity, name_field, keyword )
        entities = class_entity.select( :name, :id ).where( 'name LIKE ?', "%#{keyword}%" )
        total_expense_entity = {}
        entities.each do |entity|
            total_expense_entity[entity] = expense_entities( name_field, entity.id )
        end

        return total_expense_entity.to_a
    end

    # Description: Returns all the expenses for a type of entity.
    # Parameters: name_field,entity_id.
    # Return: total_expense.
    def expense_entities( name_field, entity_id )
        total_expense = Expense.where( name_field => entity_id ).sum( :value )

        return total_expense
    end

    private :expense_entities, :search_entities, :find_entities
end
