######################################################################
# Class name: ContactController
# File name: contact_controller.rb
# Description: Controller of contact to manage the email service
# of the application.
#######################################################################

require 'rest-client'
# Comunicate with API to send a email
class ContactController < ApplicationController

    public

    # Description: Send one email to the software manager with comments
    # or suggestions about the software.
    # Parameters: none.
    # Return: none.
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

    # Description: This method is called to make help view about the messages
    # made about this software.
    # Parameters: none.
    # Return: none.
    def help
    end
end
