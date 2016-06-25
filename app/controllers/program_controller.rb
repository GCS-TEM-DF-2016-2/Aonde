#####################################################################
# Module name: ProgramController
# File name: program_controller.rb
# Description: program_controller.rb Process de data necessary to
# respond the requisitions of user in the view.
#####################################################################

# 
class ProgramController < ApplicationController

  def show_programs
    all_programs = HelperController.find_expenses_entity( params[ :year ],params[ :id ], :program, :name )
    respond_to do |format|
      format.json { render json: all_programs }
    end
  end

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

  def create_graph_nodes( program, field_entity, class_entity, id_graph )
    entity_related = [ [ { 'id' => "#{id_graph}_", 'label' => program.name } ], [ ] ]
    begin
      program_agency = create_data_program( program.id, field_entity,
                                           class_entity )
      Graph.create_nodes( program, program_agency, entity_related )
    rescue Exception => error
    end
    entity_related
  end

  def create_data_program( program_id, field_entity, class_entity )
    select_distinct = Expense.select( 'DISTINCT( ' + field_entity + ' )' )
                      .where( program_id: program_id )
    name_value = [ ]
    select_distinct.each do |select|
      entity_id = obtain_id( select, class_entity )
      unless entity_id.nil?
        value = Expense.where( program_id: program_id,
                              field_entity => entity_id ).sum( :value )
        name = class_entity.find( entity_id ).name.strip
        name_value << [ name, value, class_entity.name, entity_id ]
      end
    end
    name_value
  end

  def obtain_id( expense, class_entity )
    id = nil
    if class_entity.name == Company.name
      id = expense.company_id
    else
      id = expense.public_agency_id
    end
    id
  end
end
