#####################################################################
# Class name: ApplicationController
# File name: application_controller.rb
# Description: Default parent controller, all others controllers
# inherit it.
#####################################################################

class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session

    public

    # Description: Method that returns a specific public agency
    # found by its id.
    # Parameters: public_agency_id.
    # Return: @public_agency.
    def find_agency_by_id( public_agency_id = 0 )
        @public_agency = PublicAgency.find( public_agency_id )
        @superior_public_agency = SuperiorPublicAgency
          .find( @public_agency.superior_public_agency_id )

        return @public_agency
    end
end
