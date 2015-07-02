require "rubygems"
require 'sinatra'
require 'net/http'
require 'uri'

post "/ec" do 
  resp = Net::HTTP.post_form URI('https://api-3t.sandbox.paypal.com/nvp'), {
  	'METHOD' => 'SetExpressCheckout',
  	'VERSION' => '109.0',
  	'USER' => 'daniel.oconnor_api1.paypal.com',
  	'PWD' => 'DM6DWAL8P83XQE5M',
  	'SIGNATURE' => 'AIHR.P3zrJxO3juFwINITaOoNj5eAquTzGgFuExWtKuvvm.lW2bWM.iW',
  	'PAYMENTREQUEST_0_AMT' => '12.13',
  	'PAYMENTREQUEST_0_CURRENCYCODE' => 'USD',
  	'PAYMENTREQUEST_0_PAYMENTACTION' => 'SALE',
  	'RETURNURL' => 'https://paypalec.herokuapp.com/success',
  	'CANCELURL' => 'https://paypalec.herokuapp.com/cancel'
  }	
  
  response = parse(URI.decode(resp.body).to_str)
  p response["TOKEN"]
  redirect "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=#{response["TOKEN"]}"
end

get "/ec" do
  erb :ec
end

get "/success" do
  @token = params['token']
  @payer_id = params['PayerID']
  erb :success
end

post "/confirm" do
  resp = Net::HTTP.post_form URI('https://api-3t.sandbox.paypal.com/nvp'), {
  	'METHOD' => 'DoExpressCheckoutPayment',
  	'VERSION' => '109.0',
  	'USER' => 'daniel.oconnor_api1.paypal.com',
  	'PWD' => 'DM6DWAL8P83XQE5M',
  	'SIGNATURE' => 'AIHR.P3zrJxO3juFwINITaOoNj5eAquTzGgFuExWtKuvvm.lW2bWM.iW',
  	'PAYMENTREQUEST_0_AMT' => '10.00',
  	'PAYMENTREQUEST_0_CURRENCYCODE' => 'USD',
  	'PAYMENTREQUEST_0_PAYMENTACTION' => 'SALE',
  	'TOKEN' => params[:token],
  	'PAYERID' => params[:payer_id]
  }	

  response = parse(URI.decode(resp.body).to_str)
  p response
  
end





def parse(http_response)
  pairs = http_response.split("&")
  response = {}

  pairs.each do |node|
  parse_element(response, node)
end

  response
end

def parse_element(response, pair)
  response[pair.split("=").first] = pair.split("=").last
end