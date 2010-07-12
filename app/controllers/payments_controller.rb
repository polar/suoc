class PaymentsController < ApplicationController
  # This will be coming in from pay pal
  def ipn
      notify = PayPalNotification.new(request.raw_post)
      
      # Verify with PayPal
      if notify.acknowledge
	begin
	  # We need to get the member id out of the Item 100.
	  items = notify.items
	  user = 1 # Default user id
	  user_set = false
	  items.each do |item|
	    if item
	      # The memberid is in all items (we hope), however
	      # We set the user from item 100 as a priority.
	      # They should be all the same.
	      if !user_set || item.number == "100"
		item.options.each do |opt|
		  # Options may be sparse and there is no option 0
		  if opt && opt[0] == "memberid"
		    user = opt[1]
		    user_set = true
		  end
		end
	      end
	    end
	  end
	  payment = PaypalReunionPayment.new(:member_id => user, :ipn_data => notify.params.inspect)
	  if !payment.save
	    log.error "Could not save payment"
	    log.error notify.params.inspect
	  end
	end
      end
      
      render :nothing => true
  end
  
end
