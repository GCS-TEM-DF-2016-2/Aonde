######################################################################
# Class name: ApplicationController
# File name: application_controller.rb
# Description: Default parent controller, all others controllers
# inherit it.
######################################################################

class ApplicationController < ActionController::Base
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    protect_from_forgery with: :null_session
    #  before_action :owl_zueira

    # def owl_zueira
    #  logger.info "  ,,,\n {0,0}\n./) )\n==\"=\"=="
    # sleep(1)
    # end

    def find_agency_by_id(id = 0)
        @public_agency = PublicAgency.find(id)
        @superior_public_agency = SuperiorPublicAgency
          .find(@public_agency.superior_public_agency_id)

        return @public_agency
    end
end
