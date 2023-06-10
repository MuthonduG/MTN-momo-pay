class MomopaysController < ApplicationController
  require 'securerandom'
  require 'rest-client'
  require 'faraday'
  require 'momoapi-ruby/config'
  require 'momoapi-ruby/client'
  require 'momoapi-ruby/validate'
  require 'json'

  # Make sure to set these values correctly
  config.collection_primary_key = 'Your Collection Subscription Key'
  config.collection_user_id = 'Your Collection User ID'
  config.collection_api_secret = 'Your Collection API Key'

  def create_user
    url = 'https://sandbox.momodeveloper.mtn.com/v1_0/apiuser'
    uuid = SecureRandom.uuid

    headers = {
      "Ocp-Apim-Subscription-Key": '0041b35c62984ac293d5b39c582c266c',
      "X-Reference-Id": uuid,
      "Content-Type": 'application/json'
    }

    payload = {
      "providerCallbackHost": "https://webhook.site/038dcc1d-c4e2-40cc-9dde-2401507dbef3"
    }

    conn = Faraday.new(url: url)
    response = conn.post do |req|
      req.headers = headers
      req.body = payload.to_json
    end

    render json: uuid, status: :ok
  end


  def get_user
    url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/158ad00c-f7d1-4f3c-ac37-a519a01995d3"
    headers = {
      "Ocp-Apim-Subscription-Key": '0041b35c62984ac293d5b39c582c266c'
    }

    conn = Faraday.new(url: url)
    response = conn.get do |req|
      req.headers = headers
    end

    render json: response
  end
  
  def create_apikey
    url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/158ad00c-f7d1-4f3c-ac37-a519a01995d3/apikey"
  
    headers = {
      "Ocp-Apim-Subscription-Key": '0041b35c62984ac293d5b39c582c266c',
    }
  
    conn = Faraday.new(url: url)
    response = conn.post do |req|
      req.headers = headers
    end
  
    apikey = response.body
    render json: apikey
  end

    
  def generate_access_token
    url = 'https://sandbox.momodeveloper.mtn.com/collection/token/'

    client_key = '158ad00c-f7d1-4f3c-ac37-a519a01995d3'
    client_secret = '90270bc1dcba4efc9efedd9291b729e0'
  
    headers = {
      'Ocp-Apim-Subscription-Key': '0041b35c62984ac293d5b39c582c266c',
      'Authorization': "Basic #{Base64.strict_encode64("#{client_key}:#{client_secret}")}"
    }   
    
    conn = Faraday.new(url: url)

    response = conn.post do |req|
      req.headers = headers
    end

    response_body = JSON.parse(response.body)
    if response.success?
      access_token = response_body['access_token']
      render json: { access_token: access_token }
    else
      error_message = response_body['error']
      render json: { error: error_message }, status: :bad_request
    end

  end

  def request_pay
    phoneNumber = params[:phone_number]
    amount = params[:amount]
    currency = 'EUR'
    payee_note = ''
    payer_message = ''
    external_id = ''
    access_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSMjU2In0.eyJjbGllbnRJZCI6IjE1OGFkMDBjLWY3ZDEtNGYzYy1hYzM3LWE1MTlhMDE5OTVkMyIsImV4cGlyZXMiOiIyMDIzLTA2LTEwVDE4OjE1OjQ5LjIwNCIsInNlc3Npb25JZCI6ImJlNWIzOTBhLTU2MTYtNGE1My04Y2FkLTI3YWNhZWNkMjIxMSJ9.i0AF5rBPLfXhlaPGTSbSol303gN_Us3v6gStPObJ-rgmCijNTpnVc-7v4K6lYYCRKNxjzRxqlBaPQN-gfN3ZgooEKCXnN4YGp-uiA6bsiBX48t1WSW7ObmWNeHKP_AIeebapuKbwKvg7fiFNDHtJmklsn7NouuQX1PQbpR2eT29YKJGub9HV1KgatS0lfmM5zTI8XtSWaR0beUzC1FpKSutygqJ5mtleVj_Da1e6EeT4ynUFKQGVs4GTbRV7BBx9bYck2SO2bt0vdmDT7c8KJpe0rG6fLPDzSdQ7KDUdoP1eKDCyKADdbZP01JkmF8jm9vFZkSMFu-r1NkPyL-Z5ow"
    
    uuid = SecureRandom.uuid

    headers = {
      'X-Target-Environment': 'sandbox',
      'Content-Type': 'application/json',
      'X-Reference-Id': uuid,
      'Ocp-Apim-Subscription-Key': '0041b35c62984ac293d5b39c582c266c',
      'Authorization': "Bearer #{access_token}"
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
      'amount': amount
    }

    path = 'https://sandbox.momodeveloper.mtn.com/collection/v1_0/requesttopay'
    conn = Faraday.new(url: path)
    
    response = conn.post do |req|
      req.headers = headers
      req.body = body.to_json
    end
    
    render json: response
  end
  
    # private

  
    def get_access_token response       
    end

end
  