class ProgramController < ApplicationController
  def show
    find_agencies(params[:id])
    @all_programs = find_expenses(@public_agency.id)
    @all_programs.to_json
  end

  def find_expenses(public_agency_id)
    expenses_public_agency = Expense.where(public_agency_id: public_agency_id)
    list_expenses = find_program(expenses_public_agency).to_a
    list_expenses
  end

  def find_program(find_expenses_public_agency)
    programs_expense = {}

    find_expenses_public_agency.each do |expense|
      # PROBLEMA AQUI
      program = Program.where(id: expense.program_id)
      sum_expense_program(program, expense, programs_expense)
      # puts "#{programs_expense}"
    end
    programs_expense
  end

  def sum_expense_program(program, expense, programs_expense)
    if !program.empty? && program.length == 1
      program = program[0]
      add_expense_program(program, expense, programs_expense)
    end
  end

  def add_expense_program(program, expense, programs_expense)
    if !programs_expense [program.name]
      programs_expense [program.name] = expense.value
    else
      programs_expense [program.name] += expense.value
    end
  end

  ###########################################################
  def show_program
    program_id = params[:id]
    program_id = program_id.to_i
    program = Program.find(program_id)
    program_related = [[{'id'=>program_id,'label'=>program.name}],[]]
    create_nodes(program_id, program_related, "public_agency_id",PublicAgency)
    create_nodes(program_id, program_related, "public_agency_id",PublicAgency)
    @data_program = program_related
  end

  def create_nodes(program_id, program_related, field_entity, class_entity)
    #puts "#{program_related}"
    begin
      name_entities = find_names(program_id, field_entity, class_entity)
      name_entities.each do |agency|

        add_node(agency, program_related)    
        add_edge(program_related)
      end
    rescue Exception => e
      puts "\n#{e}"
    end
  end

  def find_names(program_id, field_entity, class_entity)
    entities = Expense.select('DISTINCT(' + field_entity + ')')
               .where(program_id: program_id)
    name_entities = []

    if !entities.nil? && !entities.empty?
      add_names(entities, class_entity, name_entities)
    else
      fail "Entities not found! \n #{program_id} with field #{field_entity}"
    end
    name_entities
  end

  def add_names(entities, class_entity, name_entities)
    entities.each do |entity|
      entity_id = obtain_id(entity, class_entity)
      name_entities << class_entity.find(entity_id).name unless entity_id.nil?
    end
  end
  def obtain_id(entity, class_entity)
    id = nil
    if class_entity == PublicAgency
      id = entity.public_agency_id
    elsif class_entity == Company
      id = entity.company_id
    else
      id
    end
  end

  def add_node(name, data_program)
    node = 0
    next_id = data_program[node].last['id'] + 1
    data_program[node] << { 'id' => next_id, 'label' => name }
  end

  def add_edge(data_program)
    node = 0
    last_id = data_program[node].last['id']
    edge = 1
    data_program[edge] << { 'from' => 1, 'to' => last_id }
  end
end
