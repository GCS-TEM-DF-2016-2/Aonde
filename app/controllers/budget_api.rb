#####################################################################
# Class name: BudgetAPI
# File name: budget_api.rb
# Description: budget_api.rb Communicate with API of budget,
# obtain the data in json format and parse it to be used in rails.
#####################################################################

class BudgetAPI

  # Description: Get all budgets of an especific year.
  # Parameters: public_agency_id, year = 'Todos'
  # Return: budget_years
  def self.get_budget( public_agency_id, year = 'Todos' )
    data_api = obtain_api_data( public_agency_id, year )
    data_budget = parse_json_to_hash( data_api )
    valid_response = valid_data?( data_budget )
    budget_years = []
    if valid_response
      add_budget_array( budget_years, data_budget )
    else
      fail 'Não foi possível obter o valor da API do orçamento'
    end
    budget_years
  end

  # Description: Increment in budget_years array a data.
  # Parameters: budget_years, data_budget
  # Return: none.
  def self.add_budget_array( budget_years, data_budget )
    budgets = data_budget['results']['bindings']
    budgets.each do |budget|
      budget_by_year = create_budget_year( budget )
      budget_years << budget_by_year
    end
  end

  # Description: Create an array with the budgets from years.
  # Parameters: budget.
  # Return: budget_by_year.
  def self.create_budget_year( budget )
    year = budget['ano']['value']
    value_budget = budget['somaProjetoLei']['value']
    budget_by_year = {}
    if (year && value_budget)
      budget_by_year = { 'year' => year.to_i, 'value' => value_budget.to_i }
    else
      # nothing to do.
    end
    return budget_by_year
  end

  # Description: Take data from api with a public agency and a year.
  # Parameters: public_agency_id, year.
  # Return: data_api.
  def self.obtain_api_data( public_agency_id, year )
    data_api = ''
    begin
      url_query = get_url( public_agency_id, year )
      # puts "#{url_query}"
      uri_query = URI.parse( url_query )
      data_api = Net::HTTP.get( uri_query )
    rescue Exception => error
      raise "Não foi possível conectar a API\n#{error}"
    end
    return data_api
  end

  # Description: Verify if the value of an data is valid.
  # Parameters: budget_hash.
  # Return: valid_data.
  def self.valid_data?( budget_hash )
    valid_data = true
    results_hash = budget_hash['results']
    if ( results_hash && !results_hash.empty? )
      bindings_array = results_hash['bindings']
      valid_data = false if bindings_array.nil? || bindings_array.empty?
    else
      valid_data = false
    end
    return valid_data
  end

  # Description: Return an hash in JSON format thats contains all bugets by
  # the year.
  # Parameters: data_api.
  # Return: budget_year.
  def self.parse_json_to_hash( data_api )
    # Create a hash that will contains the data_api content in JSON format.
    budget_year = {}
    begin
      budget_year = JSON.parse( data_api )
    rescue
      raise 'Não foi possivel conventer os dados da API do orçamento'
    end
    return budget_year
  end

  # Description: Make a url to be used in view.
  # Parameters: public_agency_id, year
  # Return: url.
  def self.get_url( public_agency_id, year = 'Todos' )
    begin_url = 'http://aondebrasil.com:8890/sparql?default-graph-uri=&query='

    end_url = '&debug=on&timeout=&format=application%2Fsparql-results%2Bjson'\
    '&save=display&fname='

    # Transform the year content in string.
    year = year.to_s
    public_agency_id = public_agency_id.to_s

    url_query = generate_query( public_agency_id, year )
    url = begin_url + url_query + end_url

    return url
  end

  # Description: Make the request of an specific public agency by the year
  # from databases.
  # Parameters: public_agency_id, year.
  # Return: url_query.
  def self.generate_query( public_agency_id, year = 'Todos' )
    prefix = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> '\
            'PREFIX loa: <http://vocab.e.gov.br/2013/09/loa#>'

    year_query = query_for_year( year )

    query = 'SELECT ?ano, (SUM(?valorProjetoLei) AS ?somaProjetoLei) WHERE {'\
            '?itemBlankNode loa:temExercicio ?exercicioURI . ' + year_query +
            '?exercicioURI loa:identificador ?ano . '\
            '?itemBlankNode loa:temUnidadeOrcamentaria ?uoURI . '\
            '?uoURI loa:codigo "' + public_agency_id + '" . '\
            '?itemBlankNode loa:valorProjetoLei ?valorProjetoLei . }'

    url_query = URI.encode( prefix + query )

    return url_query
  end

  # Description: Make the database requisition with an especific year.
  # Parameters: year.
  # Return: none.
  def self.query_for_year( year )
    year_query = ''
    if year != 'Todos'
      year = year.to_i - 1
      year_query = '?exercicioURI loa:identificador ' + year.to_s + ' . '
    end
    year_query
  end
  private_class_method :query_for_year, :generate_query, :get_url,
                       :parse_json_to_hash, :valid_data?, :obtain_api_data,
                       :create_budget_year, :add_budget_array
end
