######################################################################
# Class name: CompanyController
# File name: company_controller.rb
# Description: Process the expenses of companies to create chart related to a 
# public agency or a graph with all public agencies make hires
####################################################################### 

    class CompanyController < ApplicationController
        include Assertions

        # Description: Prepares the attributes of an specific year to be shown in the
        # Show view.
        # Parameters: none.
        # Return: none.
        def show
            # Gets from the URL the year whose attributes are being collected.
            year = params[ :year ]
            company_id = params[ :id ]
            company_expense = HelperController
                              .find_expenses_entity( year, company_id, :company, :name )
            assert_object_is_not_null( company_expense )

            respond_to do |format|
              format.json { render json: company_expense }
            end
        end

       # Description: Finds the expenses and hiring incidence of a company.
       # Parameters: none.
       # Return: none.
       def find
            company_expenses = Expense.where( company_id: params[ :id ] )
            assert_object_is_not_null( company_expenses )
            company_hiring_incidence = find_public_agencies( company_expenses )
            assert_object_is_not_null( company_hiring_incidence )
            @company = Company.find( params[ :id ] )
            company_node = generate_company_node( @company.name )
            assert_object_is_not_null( company_node )
            company_data = generate_public_agency_node( @company.name, 
                                                company_hiring_incidence, company_node )
            assert_object_is_not_null( company_data )
            @correct_datas = company_data.to_json
        end

         # Description: Finds and sorts the public agencies based on their expenses.
         # Parameters: expenses.
         # Return: company_hiring_incidence.
         def find_public_agencies( expenses )
              assert_object_is_not_null( expenses )
              assert_type_of_object( expenses, Expense::ActiveRecord_Relation )
              company_hiring_incidence = {}
              expenses.each do |expense|
                  if (!expense.public_agency_id.nil?)
                      public_agency = PublicAgency.find( expense.public_agency_id )
                      verify_insert( company_hiring_incidence, public_agency )
                  else 
                      # Nothing to do.
                  end
              end
             company_hiring_incidence.sort_by { |_name, expense| expense }
         end

        # Description: Gets the hiring count of a given public agency.
        # Parameters: public_agency.
        # Return: counting.
        def find_hiring_count( public_agency )
            assert_object_is_not_null( public_agency )
            assert_type_of_object( public_agency, PublicAgency)
            counting = Expense.where( public_agency_id: public_agency.id ).count
            return counting
        end

        # Description: Stores the hiring incidence counting of a company in a hash,
        # but only if there was no previously value stored for that company.
        # Parameters: company_hiring_incidence, public_agency.
        # Return: none.
        def verify_insert( company_hiring_incidence, public_agency )
            assert_object_is_not_null( company_hiring_incidence)
            assert_object_is_not_null( public_agency )
            assert_type_of_object( company_hiring_incidence, Hash)
            assert_type_of_object( public_agency, PublicAgency )
            if ( company_hiring_incidence[ public_agency.name ].nil? )
                counting = find_hiring_count( public_agency )
                company_hiring_incidence[ public_agency.name ] = counting
            else
                # Nothing to do.
            end
            return company_hiring_incidence
        end

        # Description: Prepares a 'node' of a company. This node is a collection of 
        # data in hash format to be used in the charts.
        # Parameters: company_name.
        # Return: data_company.
        def generate_company_node( company_name )
            assert_object_is_not_null( company_name )
            assert_type_of_object( company_name, String )
            data_company = [
              { 'data' => { 'id' => company_name }, 'position' => { 'x' => 0,
                                                                  'y' => 400 } },
              { 'data' => { 'id' => 'Órgãos Públicos' } },
              { 'data' => { 'id' => 'qtde Contratações' } }
            ]
            return data_company;
        end

        # Description: Prepares a 'node' of a public agency. This node is a collection
        # of data in hash format to be used in the charts.
        # Parameters: company_name, company_hiring_incidence.
        # Return: array_general.
        def generate_public_agency_node( company_name, company_hiring_incidence,
          data_company )
            assert_object_is_not_null( company_name )
            assert_object_is_not_null( company_hiring_incidence )
            assert_object_is_not_null( data_company )
            assert_type_of_object( company_name, String )
            assert_type_of_object( company_hiring_incidence, Hash)
            assert_type_of_object( data_company, Array )
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

        private :generate_public_agency_node, :generate_company_node,
                :find_hiring_count, :find_public_agencies, :verify_insert
end
