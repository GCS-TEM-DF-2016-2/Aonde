# superior_public_agency_controller.rb
# Process the requests of users and the data related with superior public
# agencies
class SuperiorPublicAgencyController < ApplicationController
  def show
    @superior_agency = SuperiorPublicAgency.find( params[ :id ] )
    public_agencies = find_public_agencies( @superior_agency.id )

    superior_agency_graph = [ [ { 'id' => '1_', 'label' => @superior_agency.name } ], [  ] ]
    Graph.create_nodes( @superior_agency, public_agencies, superior_agency_graph )
    @data_superior_agency = superior_agency_graph.to_json
  end

  def find_public_agencies( superior_id )
    public_agencies = PublicAgency.where( superior_public_agency_id: superior_id )
  end
end
