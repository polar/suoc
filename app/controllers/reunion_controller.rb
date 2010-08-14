class ReunionController < BaseController
  layout "club_operations"
  
  # This filter forces a redirect to the login or sign up page, then
  # will redirect when signed up.
  before_filter :login_required
  filter_access_to :all
  filter_access_to :registrants, :require => :read
  filter_access_to :steps, :require => :read
  filter_access_to :thanks, :require => :read
  
  def get_registrants
    @registrants = PaypalReunionPayment.all(:conditions => { :member_id => @current_user.id }).map {|p| Registrant.new(p)}
    @self_registered = false
    @registrants.each do |r|
      if r
	@self_registered ||= r.self_registered?
      end
    end
  end
  def index
    get_registrants
  end
#   
  def show
    get_registrants
    render :action => "index"
  end
  
  class Item < PayPalNotification::Item
    def cost
      mc_gross
    end
    def friday
      options.each do |opt|
	if opt && opt[0] == "Friday"
	  return opt[1]
	end
      end
      return ""
    end
    def saturday
      options.each do |opt|
	if opt && opt[0] == "Saturday"
	  return opt[1]
	end
      end
      return ""
    end
    def sunday
      options.each do |opt|
	if opt && opt[0] == "Sunday"
	  return opt[1]
	end
      end
      return ""
    end
    def tshirt
      options.each do |opt|
	if opt && opt[0] == "T-Shirt"
	  return opt[1]
	end
      end
      return ""
    end
    
    def full_name
      options.each do |opt|
	if opt && opt[0] == "Full Name"
	  return opt[1]
	end
      end
      return ""
    end
    
    def type
      options.each do |opt|
	if opt && (opt[0] == "Type" || opt[0] == "GuestType")
	  return opt[1]
	end
      end
      return ""
    end
  end
      
  class Registrant
    def initialize(payment)
      @payment = payment
      @params = eval payment.ipn_data
    end
    
    def items
      Item.items(@params)
    end
    def name
      @payment.member.name
    end
    def amount_paid
      @params["mc_gross"]
    end
    def fee
      @params["mc_fee"]
    end
    
    def self_registered?
      items.each do |item|
	if item && item.number == "100"
	  return true
	end
      end
    end
	
  end
    
  def registrants
    @registrants = PaypalReunionPayment.all.map {|p| Registrant.new(p)}
  end
  
  def thanks
    @registrants = PaypalReunionPayment.all(:conditions => { :member_id => @current_user.id }).map {|p| Registrant.new(p)}
  end
end
