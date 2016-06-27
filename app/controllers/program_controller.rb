#####################################################################
# Module name: ProgramController
# File name: program_controller.rb
# Description: program_controller.rb Process de data necessary to
# respond the requisitions of user in the view.
#####################################################################

class ProgramController < ApplicationController

    # Description: This methos is called in the view to show the expenses
    # especified from the values passed by params.
    # Parameters: none.
    # Return: none.
    def show_programs
        all_programs = HelperController.find_expenses_entity( params[ :year ],
            params[ :id ], :program, :name )
        respond_to do |format|
            format.json { render json: all_programs }
        end
    end

    # Description: This is the main method used to show values in view about
    # programs in public agencys.
    # Parameters: none.
    # Return: none.
    def show
        program_id = params[ :id ].to_i
        @program = Program.find( program_id )

        agency_related = create_graph_nodes( @program, 'public_agency_id',
                                            PublicAgency, 1 )
        last_id = Graph.id_node( agency_related[ 0 ].last[ 'id' ] )

        company_related = create_graph_nodes( @program, 'company_id',
                                             Company, last_id )
        company_related[ 0 ].delete_at( 0 )

        program_related = agency_related + company_related
        @data_program = program_related.to_json
    end

    # Description: This method make a chart of programs from public agencys.
    # Parameters: program, field_entity, class_entity, id_graph.
    # Return: entity_related.
    def create_graph_nodes( program, field_entity, class_entity, id_graph )
        entity_related = [ [ { 'id' => "#{id_graph}_",
            'label' => program.name } ], [ ] ]
        begin
            program_agency = create_data_program( program.id, field_entity,
                                               class_entity )
            Graph.create_nodes( program, program_agency, entity_related )
            rescue Exception => error
        end
        return entity_related
    end

    # Description: This method return an array thats contain the name, value,
    # type and id of an expense.
    # Parameters: program_id, field_entity, class_entity.
    # Return: name_value.  
    def create_data_program( program_id, field_entity, class_entity )
        select_distinct = Expense.select( 'DISTINCT( ' + field_entity + ' )' )
                          .where( program_id: program_id )
        name_value = [ ]
        select_distinct.each do |select|
          entity_id = obtain_id( select, class_entity )
          if !entity_id.nil?
            value = Expense.where( program_id: program_id,
                                  field_entity => entity_id ).sum( :value )
            name = class_entity.find( entity_id ).name.strip
            name_value << [ name, value, class_entity.name, entity_id ]
          end
        end

        return name_value
    end

    # Description: This method returns an id of a company or the id of a
    # public agency.
    # Parameters: expense, class_entity.
    # Return: id.
    def obtain_id( expense, class_entity )
        id = nil
        if class_entity.name == Company.name
          id = expense.company_id
        else
          id = expense.public_agency_id
        end
        return id
    end
end
