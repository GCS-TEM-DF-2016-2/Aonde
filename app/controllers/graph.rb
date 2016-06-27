#####################################################################
# Module name: Graph
# File name: graph.rb
# Description: Process the methods to create graphs
#####################################################################

module Graph
    # Description: Generates a set of specifics nodes.
    # Parameters: entity,data_array,graph_data.
    # Return: none.
    def self.create_nodes( entity, data_array, graph_data )
        entity_name = entity.class.name

        iterator = 0
        data_array.each do |data|
            name_value = obtain_name_value( entity_name, data )
            create_node( graph_data, name_value )
            iterator += 1
        end
    end

    # Description: Obtain a value that is associated with a name.
    # Parameters: data,entity_name.
    # Return: name_value.
    def self.obtain_name_value( entity_name, data )
        name = 0
        value = 1
        class_name = 2
        id = 3
        name_value = {}
        if entity_name == Program.name
            name_value = { name: data[ name ], value: data[ value ],
                         class_entity: data[ class_name ], id: data[ id ] }
        elsif entity_name == SuperiorPublicAgency.name
            name_value = { name: data.name, class_entity: PublicAgency.name, id: data.id }
        end

        return name_value
    end

    # Description: Adds a specific node to the graph.
    # Parameters: data_graph,name_value.
    # Return: none.
    def self.create_node( data_graph, name_value )
        add_node( name_value[ :name ], data_graph, name_value[ :class_entity ], name_value[ :id ] )
        add_edge( data_graph, name_value[ :class_entity ] )
        if name_value[ :value ]
            begin
                add_value( name_value[ :value ], data_graph )
                rescue Exception => error
            end
        end
    end

    # Description: Method that adds edges to the graph.
    # Parameters: name,data_graph,name_entity,id_entity.
    # Return: none.
    def self.add_node( name, data_graph, name_entity, id_entity )
        node = 0
        next_id = id_node( data_graph[ node ].last[ 'id' ] ) + 1
        data_graph[ node ] << { 'id' => "#{next_id}_#{id_entity}", 'label' => name,
                              'group' => name_entity }
    end

    # Description: Remove a character from and convert the id to a number.
    # Parameters: full_id.
    # Return: id.
    def self.id_node( full_id )
        id = full_id.split( '_' )

        first_id = id[ 0 ].to_i

        return first_id
    end

    # Description: Method that adds edges to the graph.
    # Parameters: data_graph, class_entity.
    # Return: none.
    def self.add_edge( data_graph, class_entity )
        node = 0
        last_id = data_graph[ node ].last[ 'id' ]
        edge = 1
        color = color_edge( class_entity )
        data_graph[ edge ] << { 'from' => '1_', 'to' => last_id, 'color' => color }
    end

    # Description: Add the value of a public agency to the graph.
    # Parameters: value,data_graph.
    # Return: none.
    def self.add_value( value, data_graph )
        edge = 1
        if value >= 0
            value_currency = ActionController::Base
                             .helpers.number_to_currency( value, unit: 'R$',
                                                                separator: ',', delimiter: '.' )
            data_graph[ edge ].last[ 'title' ] = value_currency
            data_graph[ edge ].last[ 'value' ] = value
        else
            fail 'Value negative'
        end
    end

    # Description: Define a specific color to element according to its class.
    # Parameters: class_entity.
    # Return: color.
    def self.color_edge( class_entity )
        color = nil
        if class_entity == PublicAgency.name
            color = '#43BFC5'
        elsif class_entity == Company.name
            color = '#FFBC82'
        else
            #nothing to do
        end

        return color
    end
end
