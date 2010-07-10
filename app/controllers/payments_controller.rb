class PaymentsController < ApplicationController
  # This will be coming in from pay pal
  def ipn
      notify = PayPalNotification.new(request.raw_post)
      
      # Verify with PayPal
      if notify.acknowledge
	begin
	  p "#############################################################"
	  p notify.params
	  p "Items from this request"
	  p notify.items
	  p "#############################################################"
	end
      end
      
      render :nothing => true
  end
  
end
