######################################################################
# Class name: ContactController
# File name: contact_controller.rb
# Description: Controller of contact to manage the email service
# of the application.
#######################################################################

require 'rest-client'
# Comunicate with API to send a email
class ContactController < ApplicationController
    def send_simple_message
        user_email = params[ :from ]
        subject = params[ :subject ]
        text = params[ :text ]

        mailgun_api = Rails.application.secrets.secret_mailgun_api
        RestClient.post 'https://api:' + "#{mailgun_api}" +
          '@api.mailgun.net/v3/aondebrasil.com/messages',
          from: user_email,
          to: 'contato@aondebrasil.com',
          subject: subject,
          text: text

        respond_to do |format|
            format.json { render json: "enviado".to_json }
        end
    end

    def help
    end
end
