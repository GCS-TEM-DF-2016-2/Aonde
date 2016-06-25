######################################################################
# Class name: CompanyController
# File name: company_controller.rb
# Description: Process the expenses of companies to create chart related to a 
# public agency or a graph with all public agencies make hires
####################################################################### 

class CompanyController < ApplicationController

  # Description: Prepares the attributes of an specific year to be shown in the
  # Show view.
  # Parameters: none.
  # Return: none.
  def show
    # Gets from the URL the year whose attributes are being collected.
    year = params[ :year ]
    id = params[ :id ]
    company_expense = HelperController
                      .find_expenses_entity( year, id, :company, :name )

    respond_to do |format|
      format.json { render json: company_expense }
    end
  end

  # Description: Finds the expenses and hiring incidence of a company.
  # Parameters: none.
  # Return: none.
  def find
    expenses = Expense.where( company_id: params[ :id ] )
    company_hiring_incidence = find_public_agencies( expenses )
    # company_hiring_incidence = get_15_first_nodes( company_hiring_incidence )
    @company = Company.find( params[ :id ] )
    data_company = generate_company_node( @company.name )
    array = generate_public_agency_node( @company.name, company_hiring_incidence,
                                        data_company )
    @correct_datas = array.to_json
  end

  # Description: Finds and sorts the public agencies based on their expenses.
  # Parameters: expenses.
  # Return: none.
  def find_public_agencies( expenses )
    company_hiring_incidence = {}
    expenses.each do |expense|
      unless expense.public_agency_id.nil?
        public_agency = PublicAgency.find( expense.public_agency_id )
        verify_insert( company_hiring_incidence, public_agency )
      end
    end
    company_hiring_incidence.sort_by { |_name, expense| expense }
  end

  # Description: Gets the hiring count of a given public agency.
  # Parameters: public_agency.
  # Return: counting.
  def find_hiring_count( public_agency )
    counting = Expense.where( public_agency_id: public_agency.id ).count
  end

  # Description: Verifies and stores the hiring incidence counting of a company.
  # Parameters: company_hiring_incidence, public_agency.
  # Return: none.
  def verify_insert( company_hiring_incidence, public_agency )
    unless company_hiring_incidence[ public_agency.name ]
      counting = find_hiring_count( public_agency )
      company_hiring_incidence[ public_agency.name ] = counting
    end
  end

  # Description: Prepares a 'node' of a company. This node is a collection of 
  # data in hash format to be used in the charts.
  # Parameters: company_name.
  # Return: none.
  def generate_company_node( company_name )
    data_company = [
      { 'data' => { 'id' => company_name }, 'position' => { 'x' => 0,
                                                            'y' => 400 } },
      { 'data' => { 'id' => 'Órgãos Públicos' } },
      { 'data' => { 'id' => 'qtde Contratações' } }
     ]
  end
  # Description: Prepares a 'node' of a public agency. This node is a collection
  # of data in hash format to be used in the charts.
  # Parameters: company_name, company_hiring_incidence.
  # Return: array_general.
  def generate_public_agency_node( company_name, company_hiring_incidence,
    data_company )
    count = 1
    array_general = [ ]
    edges = [ ]
    company_hiring_incidence.each do |public_agency_name, hiring|
      public_agency_name = public_agency_name.to_s
      hash_public_agency = { 'data' => { 'id' => public_agency_name,
                                         'parent' => 'Órgãos Públicos' },
                             'position' => { 'x' => 400, 'y' => count * 50 } }
      hash_hiring = { 'data' => { 'id' => hiring, 'parent' => 'qtde Contrataç'\
        'ões' }, 'position' => { 'x' => 700, 'y' => count * 50 } }

      data_company << hash_public_agency
      data_company << hash_hiring
      count += 1

      hash_edge_to_company = { 'data' => { 'source' => public_agency_name,
                                           'target' => company_name } }
      hash_edge_to_public_agency = { 'data' => {
        'source' => hiring, 'target' => public_agency_name } }

      edges << hash_edge_to_company
      edges << hash_edge_to_public_agency
    end

    array_general << data_company
    array_general << edges
  end

  private :generate_public_agency_node,:generate_company_node,:find_hiring_count,:find_public_agencies,
          :verify_insert

end
