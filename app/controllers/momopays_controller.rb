class MomopaysController < ApplicationController
  require 'securerandom'
  require 'faraday'
  require 'json'

  def create_user
    url = 'https://sandbox.momodeveloper.mtn.com/v1_0/apiuser'
    @@uuid = SecureRandom.uuid

    headers = {
      "Ocp-Apim-Subscription-Key": '0041b35c62984ac293d5b39c582c266c',
      "X-Reference-Id": @@uuid,
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

    render json: @@uuid, status: :ok
    # create_apikey(@@uuid)
  end


  def get_user
    url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/70560e7f-5225-4901-803a-8d52a1273e93"
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
    # Retrieve the UUID from the request parameters

    url = "https://sandbox.momodeveloper.mtn.com/v1_0/apiuser/70560e7f-5225-4901-803a-8d52a1273e93/apikey"
    headers = {
      "Ocp-Apim-Subscription-Key": '0041b35c62984ac293d5b39c582c266c',
    }

    conn = Faraday.new(url: url)
    response = conn.post do |req|
      req.headers = headers
    end

    apikey = response.body
    render json: apikey, status: :ok
  end


    
  def generate_access_token
    url = 'https://sandbox.momodeveloper.mtn.com/collection/token/'
  
    password = "ce62314d122341008e5a8551fe68af71"
    username = "70560e7f-5225-4901-803a-8d52a1273e93"
  
    headers = {
      'Ocp-Apim-Subscription-Key': '0041b35c62984ac293d5b39c582c266c',
      'Authorization': "Basic #{Base64.strict_encode64("#{username}:#{password}")}"
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
    token = get_token()
        
    uuid = SecureRandom.uuid
    # token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSMjU2In0.eyJjbGllbnRJZCI6IjM2NTkwZmJmLTcxMjUtNGY1Yi1hOGFiLWFjZWQyYzllZDg3OSIsImV4cGlyZXMiOiIyMDIzLTA2LTEyVDAwOjM0OjM5LjM2NSIsInNlc3Npb25JZCI6IjQ2OTYwZDYzLTZhMmQtNGY3OS05OTYxLTM3NWQzYjM5YjM2YiJ9.Xj22lMkGjk2ePoga-BNNwP0pjOjx-ZqNnjdXqpdX3164RHiTUQvGrN8blAruXzeI45yy_jTeYneBYQKwkOL2C16Tn3s3aKbwLw7DRhuuJ8K2jeBvPkmwXcgFdlILz17PII93SqjUz5ydfh75vDE3I4KX2EVc8oRApV6iz_ZCxFfnOtM5SDQqH4XLPUTpdeyiVRu8mr4-ydAMDobxNGI94LACjXfxCdCBgqmiXuiJKu6NllOFWBC-Loz7PHbX6lPqdlh-YKj9JLGekzRyI_D_s80XujxP566Zbx-_auNSq4JrtENAFDMK_WYtkLlrFZbPsz_pBO9SJwwsitDrJ9oEdg'

    headers = {
      'X-Target-Environment': 'sandbox',
      'Content-Type': 'application/json',
      'X-Reference-Id': uuid,
      'Ocp-Apim-Subscription-Key': '0041b35c62984ac293d5b39c582c266c',
      'Authorization': "Bearer #{token}"
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
  