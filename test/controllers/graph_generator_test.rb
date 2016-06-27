#####################################################################
# Class name: GraphGeneratorTest.
# File name: graph_test.rb.
# Description: Test class that contains all functional tests for
# graph generator.
#####################################################################

require 'test_helper'

class GraphGeneratorTest < ActiveSupport::TestCase
  test 'return color to PublicAgency' do
    color_agency = Graph.send( :color_edge, 'PublicAgency' )
    color_expected = '#43BFC5'

    assert_equal( color_expected, color_agency )
  end
  test 'return color to Company' do
    color_company = Graph.send( :color_edge, 'Company' )
    color_expected = '#FFBC82'

    assert_equal( color_expected, color_company )
  end

  test 'null result of entity is not Agency or Company' do
    assert_nil( Graph.send( :color_edge, Program ) )
  end

  test 'add edge to array' do
    data_graph = [ [ { 'id' => '1_', 'label' => 'Programa1' },
                   { 'id' => '2_2', 'label' => 'Company1' } ], [  ] ]
    Graph.add_edge( data_graph, Company.name )

    data_expected = [ [ { 'id' => '1_', 'label' => 'Programa1' },
                      { 'id' => '2_2', 'label' => 'Company1' } ],
                     [ { 'from' => '1_', 'to' => '2_2', 'color' => '#FFBC82' } ] ]

    assert_equal( data_expected, data_graph )
  end

  test 'Addition of one node to graph' do
    data_graph = [ [ { 'id' => '1_', 'label' => 'Programa1' } ], [  ] ]
    name_value = { name: 'valid name', class_entity: PublicAgency.name }
    Graph.add_node( name_value[ :name ], data_graph, name_value[ :class_entity ], name_value[ :id ] )
    data_expected = [ [ { 'id' => '1_', 'label' => 'Programa1' },
                      { 'id' => '2_', 'label' => 'valid name',
                        'group' => PublicAgency.name } ], [  ] ]

    assert_equal( data_expected, data_graph )
  end
  test 'Addition of one node with value' do
    data_graph = [ [ { 'id' => '1_', 'label' => 'Programa1' } ], [  ] ]
    name_value = { name: 'valid name', value: 500, class_entity: PublicAgency.name, id: 1 }
    Graph.create_node( data_graph, name_value )
    data_expected = [ [ { 'id' => '1_', 'label' => 'Programa1' },
                      { 'id' => '2_1', 'label' => 'valid name',
                        'group' => PublicAgency.name } ],
                     [ { 'from' => '1_', 'to' => '2_1', 'color' => '#43BFC5',
                        'title' => 'R$500,00', 'value' => 500 } ] ]

    assert_equal( data_expected, data_graph )
  end

  test 'Rescue for a negative value' do
    data_graph = [ [ { 'id' => '1_', 'label' => 'Programa1' } ], [  ] ]
    name_value = { name: 'valid name', value: -500, class_entity: PublicAgency.name }
    Graph.create_node( data_graph, name_value )
    data_expected = [ [ { 'id' => '1_', 'label' => 'Programa1' },
                      { 'id' => '2_', 'label' => 'valid name',
                        'group' => PublicAgency.name } ],
                     [ { 'from' => '1_', 'to' => '2_', 'color' => '#43BFC5' } ] ]

    assert_equal( data_expected, data_graph )
  end

  test 'Obtain name of program entities' do
    data = [ 'Company1', 100, Company.name, 1 ]
    name_value = Graph.obtain_name_value( Program.name, data )
    expected_name_value = { name: 'Company1', value: 100, class_entity: Company.name, id: 1 }
    assert_equal( expected_name_value, name_value )
  end
  test 'Obtain name of superior public agency entities' do
    data = PublicAgency.new( name: 'Public Agency', id: 1 )
    name_value = Graph.obtain_name_value( SuperiorPublicAgency.name, data )
    expected_name_value = { name: 'Public Agency', class_entity: PublicAgency.name, id: 1 }
    assert_equal( expected_name_value, name_value )
  end

  test 'Empty return to other class of obtain name value' do
    assert_empty( Graph.obtain_name_value( PublicAgency.name, nil ) )
  end

  test 'Create nodes of program' do
    program = Program.new
    data_array = [ [ 'name', 100, PublicAgency.name, 3 ] ]
    data_graph = [ [ { 'id' => '1_', 'label' => 'Programa1' } ], [  ] ]
    Graph.create_nodes( program, data_array, data_graph )
    size = [ data_graph[ 0 ].size, data_graph[ 1 ].size ]
    expected_sizes = [ 2, 1 ]
    assert_equal( expected_sizes, size )
  end

  test 'Addition of value' do
    value = 0
    data_graph = [ [  ], [ {} ] ]
    Graph.add_value( value, data_graph )
    expected_value = [ [  ], [ { 'title' => 'R$0,00', 'value' => 0 } ] ]
    assert_equal( expected_value, data_graph )
  end
  test 'Raise negative value' do
    value = -0.0001
    data_graph = [ [  ], [ {} ] ]
    assert_raise( Exception ) do
      Graph.add_value( value, data_graph )
    end
  end
end
