class ReunionController < BaseController
  layout "club_operations"
  
  # This filter forces a redirect to the login or sign up page, then
  # will redirect when signed up.
  before_filter :login_required
  filter_access_to :all
  filter_access_to :registrants, :require => :read
  filter_access_to :who, :require => :read
  filter_access_to :tshirts, :require => :read
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
    
    def member
      @payment.member
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
  
  class Attendee
    attr_accessor :name
    attr_accessor :year
    attr_accessor :guest_of
    attr_accessor :status
    attr_accessor :affiliation
    attr_accessor :year
    attr_accessor :type
  end
  
  def registrants
    @registrants = PaypalReunionPayment.all.map {|p| Registrant.new(p)}
  end
  
  def who
    @registrants = PaypalReunionPayment.all.map {|p| Registrant.new(p)}
    @attendees = []
    for r in @registrants do
      @attendees += get_attendees(r)
    end  
    @attendees = @attendees.sort { |x,y| x.name <=> y.name }
  end

  def tshirts
    @registrants = PaypalReunionPayment.all.map {|p| Registrant.new(p)}
    @small = 0
    @medium = 0
    @large = 0
    @largeX = 0
    @large2X = 0
    @large3X = 0
    for r in @registrants do
      for i in r.items
        if i
          case i.tshirt 
          when "Small" then @small += 1
          when "Medium" then @medium += 1
          when "Large" then @large += 1
          when "X-Large" then @largeX += 1
          when "2X-Large" then @large2X += 1
          when "3X-Large" then @lage3X += 1
          end
       end
      end

    end
  end

  
  def thanks
    @registrants = PaypalReunionPayment.all(:conditions => { :member_id => @current_user.id }).map {|p| Registrant.new(p)}
  end
  
  private

  def get_attendees(registrant)
    reg = Attendee.new
    reg.name = registrant.member.name
    reg.year = registrant.member.club_start_date.year
    reg.status = registrant.member.club_member_status.name
    reg.affiliation = registrant.member.club_affiliation.name
    reg.type = "Adult"
    atts = [reg]
    for i in registrant.items do
       if i && i.number != "100"
         reg = Attendee.new
         reg.name = i.full_name
         reg.guest_of = registrant.member.name
         reg.year = registrant.member.club_start_date.year
         reg.status = "Guest"
         reg.affiliation = registrant.member.club_affiliation.name
         reg.type = i.type
         atts <<= reg
       end
    end
    return atts
  end
  
end
