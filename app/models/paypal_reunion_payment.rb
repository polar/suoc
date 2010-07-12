class PaypalReunionPayment < ActiveRecord::Base
  belongs_to :member,       :class_name => "ClubMember"
  
  def params
    if ! @params
      @params = eval ipn_data
    end
    @params
  end
  
end
