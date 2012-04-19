class CertOrgsController < BaseController
  layout "club_operations"
  AC_CERT_NAME_NAME_LIMIT = 10
  filter_access_to :all

  filter_access_to [:auto_complete_for_cert_org_name], :require => :read

  # We need to skip this for the auto complete to work.
  skip_before_filter :verify_authenticity_token,
                           :auto_complete_for_cert_org_name
  #
  # Responder for view function
  #      text_file_auto_complete(:club_member, :login)
  #
  # This returns a <ul> list for the auto_complete text Ajax drop down
  # list.
  # The text "Ji Ge" is interpreted as
  #    LOWER(name) LIKE '%ji%' AND LOWER(name LIKE '%ge%'
  # The default auto_complete_for functions do not separate spaces.
  #
  def auto_complete_for_cert_org_name
    # split by spaces, downcase and create query for each.
    # Remember to Sanitize the SQL
    conditions = params[:cert_org][:name].downcase.split.map {
            #             Sanitize       ***********************************
            |w| "LOWER(name) LIKE '%" + (w.gsub(/\\/, '\&\&').gsub(/'/, "''")) +"%'" }
                                                         # AND the queries."
    find_options = {
      :conditions => conditions.join(" AND "),
      :order => "name ASC",
      :limit => AC_CERT_NAME_NAME_LIMIT }

    @items = CertOrg.find(:all, find_options)

    render :inline => "<%= auto_complete_result @items, :name %>"
  end

  def index
    @cert_orgs = CertOrg.find(:all)
  end

  def show
    @cert_org = CertOrg.find(params[:id])
  end

  def new
    @cert_org = CertOrg.new
    @types = CertType.all
    @submit = "Create"
  end

  def edit
    @cert_org = CertOrg.find(params[:id])
    @types = CertType.all
    @submit = "Update"
  end

  def create
    @cert_org = CertOrg.new(params[:cert_org])
    if @cert_org.save
      flash[:notice] = "Certificaton Organization #{@cert_org.name} for type #{@cert_org.cert_type.name} has been created."
      redirect_to(@cert_org)
    else
      flash[:error] = "Certificaton Organization was not created."
      @submit = "Create"
      @types = CertType.all
      render :action => "new"
    end
  end

  def update
    @cert_org = CertOrg.find(params[:id])

    if @cert_org.update_attributes(params[:cert_org])
      flash[:notice] = "Certificaton Organization #{@cert_org.name} for type #{@cert_org.cert_type.name} has been updated."
      redirect_to(@cert_org)
    else
      flash[:error] = "Certificaton Organization was not updated."
      @submit = "Update"
      @types = CertType.all
      render :action => "edit"
    end
  end

  def destroy
    @cert_org = CertOrg.find(params[:id])
    if !CertMemberCert.all( :conditions => {:cert_org_id => @cert_org }).empty?
      @cert_org.errors.add_to_base "Cannot delete. This Organization is referenced by Members' Certification listings"
      flash[:error] = "Cannot delete Certificaton Organization #{@cert_org.name} for type #{@cert_org.cert_type.name}." +
                      "It is already referenced by some members."
    else
      @cert_org.destroy
      flash[:notice] = "Certificaton Organization #{@cert_org.name} for type #{@cert_org.cert_type.name} has been deleted."
    end
    redirect_to :action => :index
  rescue
    redirect_to :action => :index
  end
end
