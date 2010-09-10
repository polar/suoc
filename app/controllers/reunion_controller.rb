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
    
    def date
      @payment.created_at
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
    attr_accessor :date
    attr_accessor :tshirt
  end
  
  def registrants
    @registrants = PaypalReunionPayment.all.map {|p| Registrant.new(p)}
    @gross_income = 0
    @gross_fees = 0
    @registrants.each do |x|
      @gross_income += eval x.amount_paid
      @gross_fees += eval x.fee
    end
    @net_income = @gross_income - @gross_fees
  end
  
  def who
    @registrants = PaypalReunionPayment.all.map {|p| Registrant.new(p)}
    @attendees = []
    for r in @registrants do
      @attendees += get_attendees(r)
    end
    @sort = params[:sort] ? params[:sort] : "first"
    case params[:sort]
      when "last" then @attendees = @attendees.sort { |x,y| x.name.split.last <=> y.name.split.last }
      when "date" then @attendees = @attendees.sort { |x,y| x.date <=> y.date }
      when "year" then @attendees = @attendees.sort { |x,y| x.year <=> y.year }
      else
        @attendees = @attendees.sort { |x,y| x.name <=> y.name }
    end
    @adults = 0
    @kids1015 = 0
    @kids0509 = 0
    for a in @attendees do
       case a.type
       when "Adult" then @adults += 1
       when "Adult 16+" then @adults += 1
       when "Kid 10-15" then @kids1015 += 1
       when "Kid 5-10" then @kids0509 += 1
       when "Kid 5-9" then @kids0509 += 1
       end
    end
  end

  def tshirts
    @registrants = PaypalReunionPayment.all.map {|p| Registrant.new(p)}
    @small = 0
    @medium = 0
    @large = 0
    @largeX = 0
    @large2X = 0
    @large3X = 0
    @total = 0
    for r in @registrants do
      for i in r.items
        if i
          @total += 1
          case i.tshirt 
          when "Small" then @small += 1
          when "Medium" then @medium += 1
          when "Large" then @large += 1
          when "X-Large" then @largeX += 1
          when "2X-Large" then @large2X += 1
          when "3X-Large" then @large3X += 1
          end
       end
      end
    end
    
    @attendees = []
    for r in @registrants do
      @attendees += get_attendees(r)
    end
    
    
    # sorts are not stable!!!
    @sort = params[:sort] ? params[:sort] : "first"
    case params[:sort]
      when "last" then @attendees = @attendees.sort { |x,y| x.name.split.last <=> y.name.split.last }
      when "date" then @attendees = @attendees.sort { |x,y| x.date <=> y.date }
      when "size" then @attendees = @attendees.sort { |x,y| sort_by_size(x,y) }
      else
        @attendees = @attendees.sort { |x,y| x.name <=> y.name }
    end
  end

  
  def thanks
    @registrants = PaypalReunionPayment.all(:conditions => { :member_id => @current_user.id }).map {|p| Registrant.new(p)}
  end
  
  private

  # Sorts are not stable in Ruby, this impl is horrible
  def sort_by_size(x,y)
    sizes = ["Small","Medium","Large","X-Large","2X-Large","3X-Large"]
    cmp = sizes.index(x.tshirt) <=> sizes.index(y.tshirt)
    if cmp == 0
      x.name <=> y.name
    else
      cmp
    end
  end
    
  def get_attendees(registrant)
    atts = []
    for i in registrant.items do
      # Registrant may not be an Attendee, only if item 100
       if i && i.number == "100"
	  reg = Attendee.new
	  reg.name = i.full_name
	  reg.year = registrant.member.club_start_date.year
	  reg.status = registrant.member.club_member_status.name
	  reg.affiliation = registrant.member.club_affiliation.name
	  reg.type = i.type
	  reg.date = registrant.date
	  reg.tshirt = i.tshirt
          atts <<= reg
       end
      # Add Guests of Registrant
       if i && i.number == "101"
         guest = Attendee.new
         guest.name = i.full_name
         guest.guest_of = registrant.member.name
         guest.year = registrant.member.club_start_date.year
         guest.status = "Guest"
         guest.affiliation = registrant.member.club_affiliation.name
         guest.type = i.type
	 guest.date = registrant.date
	 guest.tshirt = i.tshirt
         atts <<= guest
       end
    end
    return atts
  end
  
end
