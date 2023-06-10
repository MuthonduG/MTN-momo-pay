class MomopaysController < ApplicationController
  require 'securerandom'
  require 'faraday'
  require 'json'

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

    render json: response.body
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
      { access_token: access_token }
    else
      error_message = response_body['error']
      { error: error_message }
    end
  end
  
  def get_token
    response = generate_access_token()
    if response.key?(:error)
      response = generate_access_token()
    end
   response[:access_token]
  end
  

  def request_pay 
    phoneNumber = params[:phone_number]
    amount = params[:amount]
    currency = 'EUR'
    payee_note = 'Paid'
    payer_message = 'Pay Max'
    external_id = '678990'
        
    uuid = SecureRandom.uuid

    headers = {
      'X-Target-Environment': 'sandbox',
      'Content-Type': 'application/json',
      'X-Reference-Id': uuid,
      'Ocp-Apim-Subscription-Key': '0041b35c62984ac293d5b39c582c266c',
      'Authorization': "Bearer #{get_token}"
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

  def payment_status

  end

end
  