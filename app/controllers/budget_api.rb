# budget_api.rb Communicate with API of budget, obtain the data in json format
# and parse it to be used in rails
class BudgetAPI
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

  def self.add_budget_array( budget_years, data_budget )
    budgets = data_budget['results']['bindings']
    budgets.each do |budget|
      budget_by_year = create_budget_year( budget )
      budget_years << budget_by_year
    end
  end

  def self.create_budget_year( budget )
    year = budget['ano']['value']
    value_budget = budget['somaProjetoLei']['value']
    budget_by_year = {}
    if !year.nil? && !value_budget.nil?
      budget_by_year = { 'year' => year.to_i, 'value' => value_budget.to_i }
    end
    budget_by_year
  end

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
    data_api
  end

  def self.valid_data?( budget_hash )
    valid_data = true
    # puts budget_hash
    results_hash = budget_hash['results']
    if !results_hash.nil? && !results_hash.empty?
      bindings_array = results_hash['bindings']
      valid_data = false if bindings_array.nil? || bindings_array.empty?
    else
      valid_data = false
    end
    valid_data
  end

  def self.parse_json_to_hash( data_api )
    budget_year = {}
    begin
      budget_year = JSON.parse( data_api )
    rescue
      raise 'Não foi possivel conventer os dados da API do orçamento'
    end
    budget_year
  end

  def self.get_url( public_agency_id, year = 'Todos' )
    begin_url = 'http://aondebrasil.com:8890/sparql?default-graph-uri=&query='

    end_url = '&debug=on&timeout=&format=application%2Fsparql-results%2Bjson'\
    '&save=display&fname='

    year = year.to_s
    public_agency_id = public_agency_id.to_s

    url_query = generate_query( public_agency_id, year )
    url = begin_url + url_query + end_url

    #    puts "\n\n\n\n#{url}\n\n\n"

    url
  end

  def self.generate_query( public_agency_id, year = 'Todos' )
    prefix = 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> '\
            'PREFIX loa: <http://vocab.e.gov.br/2013/09/loa#>'

    year_query = query_for_year( year )

    # puts year_query
    query = 'SELECT ?ano, ( SUM( ?valorProjetoLei ) AS ?somaProjetoLei ) WHERE {'\
            '?itemBlankNode loa:temExercicio ?exercicioURI . ' + year_query +
            '?exercicioURI loa:identificador ?ano . '\
            '?itemBlankNode loa:temUnidadeOrcamentaria ?uoURI . '\
            '?uoURI loa:codigo "' + public_agency_id + '" . '\
            '?itemBlankNode loa:valorProjetoLei ?valorProjetoLei . }'

    # puts query
    url_query = URI.encode( prefix + query )

    url_query
  end

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
