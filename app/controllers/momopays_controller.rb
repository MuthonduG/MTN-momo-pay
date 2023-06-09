class MomopaysController < ApplicationController
    require 'securerandom'
    require 'rest-client'
    require 'faraday'
    require 'momoapi-ruby/config'
    require 'momoapi-ruby/client'
    require 'momoapi-ruby/validate'

    config.collection_primary_key = 'Your Collection Subscription Key'
    config.collection_user_id = 'Your Collection User ID'
    config.collection_api_secret = 'Your Collection API Key'
    subscription_key = '0041b35c62984ac293d5b39c582c266c'

    def create_user
      url = 'https://sandbox.momodeveloper.mtn.com/v1_0/apiuser'
      uuid = SecureRandom.uuid
      
      headers = {
        "Ocp-Apim-Subscription-Key": '0041b35c62984ac293d5b39c582c266c',
        "X-Reference-Id": uuid
      }

      payload = {
        "providerCallbackHost": "https://webhook.site/038dcc1d-c4e2-40cc-9dde-2401507dbef3"
      }

      response = RestClient::Request.execute{
        method: post,
        headers: headers,
        body: payload
      }

      render json :response
      create_apikey(uuid)
      generate_access_token(uuid)
    end

    def create_apikey uuid
      url = `https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/#{uuid}/apikey`

      headers = {
        "Ocp-Apim-Subscription-Key": '0041b35c62984ac293d5b39c582c266c',
      }
      response = RestClient::Request.execute{
        method: post,
        headers: headers
      }

      unless response != 200
        raise Momoapi::Error.new(response.body, response.status)
      end

      render json :response, status: :ok
      
      generate_access_token(response)
    end
  
    def request_pay
      phoneNumber = params[:phone_number]
      amount = params[:amount]
      currency = 'RWF'
      payee_note = ''
      payer_message = ''
      external_id = ''
  
      Monoapi::Validate.new.validate(phoneNumber, amount, currency)
      uuid = SecureRandom.uuid
  
      headers = {
        'X-Target-Environment': Monoapi.config.environment || 'sandbox',
        'Content-Type': 'application/json',
        'X-Reference-Id': uuid,
        'Ocp-Apim-Subscription-Key': Monoapi.config.collection_primary_key,
        'Authorization': "Bearer #{get_access_token}"
      }
  
      body = {
        'payer': {
          'partyIdType': 'MSISDN',
          'partyId': phoneNumber
        },
        'payeeNote': payee_note,
        'payerMessage': payer_message,
        'externalId': external_id,
        'currency': currency,
        'amount': amount.to_s
      }
      
      path = 'https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay'
  
      response = RestClient::Request.execute(
        method: :post,
        url: path,
        payload: body.to_json,
        headers: headers
      )
  
      case response.code
      when 500
        result = [:error, JSON.parse(response.to_str)]
      when 400
        result = [:error, JSON.parse(response.to_str)]
      else
        result = [:success, JSON.parse(response.to_str)]
      end
  
      { transaction_reference: uuid }.to_json
    end
  
    private
  
    def generate_access_token(subscription_key, response, uuid)
      url = 'https://sandbox.momodeveloper.mtn.com/collection/token/'

      headers = {
        'Ocp-Apim-Subscription-Key': subscription_key,
        http_basic_authenticate_with: [uuid, response] 
      }
      
      response = RestClient::Request.execute(
        url: url,
        headers: headers
      )
  
      render json: response

      get_access_token(response)

    end
  
    def get_access_token
      
    end
  end
  