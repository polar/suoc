
require 'active_support'
require 'builder'
require 'cgi'
require 'rexml/document'

require 'active_merchant/utils'
require 'active_merchant/error'
require 'active_merchant/validateable'
require 'active_merchant/connection'
require 'active_merchant/posts_data'
require 'active_merchant/post_data'
require 'active_merchant/requires_parameters'
require 'active_merchant/country'

# This code came from some idiot's version of ActiveMerchant, where 
# he screwed up confusing the params with the raw_post of the request.
# That only cost me a day.

class PayPalNotification
  include ActiveMerchant::PostsData
      class Paypal
	def self.service_url
	  if RAILS_ENV == "production"
	    "https://www.paypal.com/cgi-bin/webscr"
	  elsif RAILS_ENV == "development"
	    "https://www.sandbox.paypal.com/cgi-bin/webscr"
	    "https://www.paypal.com/cgi-bin/webscr"
	  else # test
	    "https://www.sandbox.paypal.com/cgi-bin/webscr"
	  end
	end
      end
      
      # Params as parsed from raw post
      attr_accessor :params

      # The raw post
      attr_accessor :raw
      
      
      # Was the transaction complete?
      def complete?
	status == "Completed"
      end

      # When was this payment received by the client. 
      # sometimes it can happen that we get the notification much later. 
      # One possible scenario is that our web application was down. In this case paypal tries several 
      # times an hour to inform us about the notification
      def received_at
	Time.parse params['payment_date']
      end

      # Status of transaction. List of possible values:
      # <tt>Canceled-Reversal</tt>::
      # <tt>Completed</tt>::
      # <tt>Denied</tt>::
      # <tt>Expired</tt>::
      # <tt>Failed</tt>::
      # <tt>In-Progress</tt>::
      # <tt>Partially-Refunded</tt>::
      # <tt>Pending</tt>::
      # <tt>Processed</tt>::
      # <tt>Refunded</tt>::
      # <tt>Reversed</tt>::
      # <tt>Voided</tt>::
      def status
	params['payment_status']
      end

      # Id of this transaction (paypal number)
      def transaction_id
	params['txn_id']
      end

      # What type of transaction are we dealing with? 
      #  "cart" "send_money" "web_accept" are possible here. 
      def type
	params['txn_type']
      end

      # the money amount we received in X.2 decimal.
      def gross
	params['mc_gross']
      end

      # the markup paypal charges for the transaction
      def fee
	params['mc_fee']
      end

      # What currency have we been dealing with
      def currency
	params['mc_currency']
      end

      # This is the item number which we submitted to paypal 
      # The custom field is also mapped to item_id because PayPal
      # doesn't return item_number in dispute notifications
      def item_id
	params['item_number'] || params['custom']
      end

      def custom
        params['custom']
      end

      class Item
	attr_accessor :name
	attr_accessor :number
	attr_accessor :quantity
	attr_accessor :tax
	attr_accessor :mc_handling
	attr_accessor :mc_gross
	attr_accessor :btn_id
	
	# An array of [name,value] pairs.
	# Names can repeat so it's not a hash.
	# The array index is the option number.
	# There is no option 0.
	attr_accessor :options
	
	def initialize(hash, i)
	  @name = hash["item_name#{i}"]
	  @number =  hash["item_number#{i}"]
	  @quanity =  hash["quantity#{i}"]
	  @tax =  hash["tax#{i}"]
	  @mc_handling =  hash["mc_handling#{i}"]
	  @mc_gross =  hash["mc_gross_#{i}"]
	  @btn_id =  hash["btn_id#{i}"]
	  @options = Array.new
	  keys = hash.keys.select {|k| k =~ /option_name[0-9]+_#{i}/ }
	  # There is no option count variable.
	  # Not sure if options are always numbered 1-n, or if all are there.
	  for k in keys do
	    md = /option_name([0-9]+)_#{i}/.match(k)
	    # n is the option number
	    n = md[1].to_i
	    # options[n] = [ option n's name, option n's value ]
	    options[n] = 
		[ hash["option_name#{n}_#{i}"], 
	          hash["option_selection#{n}_#{i}"]]
	  end
	end
	
	def to_h
	    { "name" => name, "number" => number, "quanity" => quantity,
	      "tax" => tax, "mc_handling" => mc_handling, "mc_gross" => mc_gross,
	      "btn_id" => btn_id, "options" => options }
	end
	
	def to_s
	  to_h.dump
	end
      end

      def items
	# If no num_cart_items, assume 1?
	count = params["num_cart_items"]
	count = count ? count.to_i : 1
	its = Array.new
	for i in 1..count do
	  its[i] = Item.new(params,i)
	end
	return its
      end

      # This is the invoice which you passed to paypal 
      def invoice
	params['invoice']
      end   

      # Was this a test transaction?
      def test?
	params['test_ipn'] == '1'
      end
      
      def account
	params['business'] || params['receiver_email']
      end

      
      def raw
        @raw
      end
      
      def acknowledge
        unless RAILS_ENV=="test"
           payload = raw
           response = ssl_post(Paypal.service_url + '?cmd=_notify-validate', payload,
             'Content-Length' => "#{payload.size}"
           )
           raise StandardError.new("Faulty paypal result: #{response}") unless ["VERIFIED", "INVALID"].include?(response)
        end
        response == "VERIFIED"
      end

      def initialize(post, options = {})
	@options = options
	empty!
	parse(post)
      end

      # the money amount we received in X.2 decimal.
      def gross
	raise NotImplementedError, "Must implement this method in the subclass"
      end

      def gross_cents
	(gross.to_f * 100.0).round
      end

      # reset the notification. 
      def empty!
	@params  = Hash.new
	@raw     = ""      
      end
      
      
      private

      # Take the posted data and move the relevant data into a hash
      def parse(post)
	@raw = post.to_s
	for line in @raw.split('&')    
	  key, value = *line.scan( %r{^([A-Za-z0-9_.]+)\=(.*)$} ).flatten
	  params[key] = CGI.unescape(value)
	end
      end
  
end