#####################################################################
# Class name: ProgramControllerTest.
# File name: program_controller_test.rb.
# Description: Test class that contains all functional tests for
# program controller.
#####################################################################

require 'test_helper'
require 'database_cleaner'

class ProgramControllerTest < ActionController::TestCase
  def setup
    SuperiorPublicAgency.create( id: 1, name: 'SuperiorPublicAgency' )
    PublicAgency.create( id: 1, name: 'PublicAgency1', views_amount: 10,
                        superior_public_agency_id: 1 )
    name_program = %w( Programa1 Programa2 )
    j = 0
    for i in 1..2
      j += 1
      date = Date.new( 2015, i, i )
      program = Program.create( id: i, name: name_program[i - 1],
                               description: 'Outros' )
      2.times do
        Expense.create( document_number: j, payment_date: date,
                       value: i + 5, program_id: i, public_agency_id: 1 )
        j += 1
      end
    end
    Expense.create( id: 10, document_number: 100,
                   payment_date: Date.new( 2015, 1, 1 ), value: 0, program_id: 1,
                   public_agency_id: 1 )
  end

  def teardown
    DatabaseCleaner.clean
  end

  test "Should route show_programs" do

    assert_routing 'public_agency/1/programs',controller: 'program',id:'1',
                    action: 'show_programs'
    get :show_programs,id:1,year: 2015,format: :json
    assert_response :success

  end
  test 'Exception on create graph nodes' do
    program = Program.new
    @controller.create_graph_nodes( program, nil, nil, nil )
  end

  test 'Verify method show' do
    assert_routing '/public_agency/1/programs', controller: 'program',
                                                action: 'show_programs', id: '1'
  end

  test 'create related entities of programs' do
    program = Program.new( name: 'Programa1', id: 1 )
    graph_nodes = @controller.create_graph_nodes( program, 'public_agency_id', PublicAgency, 1 )
    expected_sizes = [2, 1]

    find_sizes = [graph_nodes[0].size, graph_nodes[1].size]

    assert_equal( expected_sizes, find_sizes )
  end

  test 'not include entitie in the association' do
    expected_related = [[{ 'id' => '1_', 'label' => 'Programa1' }], []]

    program = Program.new( name: 'Programa1', id: 1 )
    program_related = @controller.create_graph_nodes( program, 'company_id', Company, 1 )

    assert_equal( expected_related, program_related )
  end

  test 'return valid public_agency_id' do
    entity = Expense.new( public_agency_id: 3 )
    id = @controller.obtain_id( entity, PublicAgency )
    id_expected = 3

    assert_equal( id_expected, id )
  end

  test 'return valid company_id' do
    entity = Expense.new( company_id: 2 )
    id = @controller.obtain_id( entity, Company )
    id_expected = 2

    assert_equal( id_expected, id )
  end

  test 'return invalid' do
    entity = Expense.new( company_id: 4 )
    id = @controller.obtain_id( entity, Expense )

    assert_nil( id )
  end

  test 'management of nodes' do
    get :show, id: 1

    assert_response :success

    assert assigns( :data_program )
    assert assigns( :program )
  end

  test 'route to program' do
    assert_routing 'program/1', controller: 'program', action: 'show',
                                id: '1'
  end

  test 'Create data program to public agencies' do
    process_data = @controller.create_data_program( 2, 'public_agency_id', PublicAgency )
    expected_data = [['PublicAgency1', 14, PublicAgency.name, 1]]
    assert_equal( expected_data, process_data )
  end
  test 'Empty array to not create id of program' do
    process_data = @controller.create_data_program( 3, 'public_agency_id', PublicAgency )
    assert_empty( process_data )
  end
end
