class CertMemberCertsController < BaseController
  layout "club_operations"

  filter_access_to :all
  filter_access_to :add_member_cert,       :require => [:create]
  filter_access_to :delete_cert,           :require => [:delete]
  filter_access_to :my_index,              :require => [:read]
  filter_access_to :update_form_cert_orgs, :require => [:read]

  def index
    @cert_member_certs = CertMemberCert.paginate(
          :page => params[:page], :per_page => 6, :order => "end_date DESC")
  end

  def show
    @cert_member_cert = CertMemberCert.find(params[:id])
  end

  def new
    @cert_member_cert = CertMemberCert.new
  end

  def edit
    @cert_member_cert = CertMemberCert.find(params[:id])
  end

  def create
    @cert_member_cert = CertMemberCert.new(params[:cert_member_cert])

    if @cert_member_cert.save
      flash[:notice] = "The Certification held by #{@cert_member_cer.member.login} was successfully update
."
      redirect_to(@cert_member_cert)
    else
      render :action => "new"
    end
  end

  def update
    @cert_member_cert = CertMemberCert.find(params[:id])

    if @cert_member_cert.update_attributes(params[:cert_member_cert])
      flash[:notice] = "The Certification held by #{@cert_member_cer.member.login} was successfully update
."
      redirect_to(@cert_member_cert)
    else
      render :action => "edit"
    end
  end

  def add_member_cert
    @cert_member_cert = CertMemberCert.new(params[:cert_member_cert])

    if @cert_member_cert.member != current_user
      flash[:error] = "Error in transmission"
      @cert_member_cert.errors.add_to_base(
          "Somehow you tried to update another members certifications. Try again")
      @cert_member_cert.member = current_user
      init_render_my_index
      render :action => :my_index, :id => "me"
    elsif @cert_member_cert.update_attributes(params[:cert_member_cert])
      flash[:notice] = "The Certification held by #{@cert_member_cert.member.login} was added."
      redirect_to :action => :my_index, :id => "me"
    else
      init_render_my_index
      render :action => :my_index, :id => "me"
    end
  end

  def my_index
    @cert_member_cert = CertMemberCert.new(:member => current_user)
    init_render_my_index
  end

  def delete_cert
    cert = CertMemberCert.find(params[:id])
    if cert
      cert.destroy
    end
    redirect_to :action => "my_index", :id => "me"
  end

  def destroy
    @cert_member_cert = CertMemberCert.find(params[:id])
    @cert_member_cert.destroy

    redirect_to(cert_member_certs_path)
  end

  def update_form_cert_orgs
    cert_orgs = CertOrg.all(:all, 
                  :conditions => { :cert_type_id => params[:cert_type_id] })
    x=render :partial => "form_cert_orgs", :locals => {
      :cert_orgs => cert_orgs }
    logger.info x
    x
  end

  protected

  def init_render_my_index
    @current_certs = current_user.current_certifications.sort { |x,y| x.cert_type.name <=> y.cert_type.name }
    @past_certs = current_user.past_certifications.sort { |x,y| x.cert_type.name <=> y.cert_type.name }
    @cert_types = CertType.all(:order => "name ASC")
    @cert_orgs = []
    if !@cert_member_cert.cert_org.nil? && !@cert_member_cert.cert_type.nil?
      @cert_orgs = CertOrg.find_by_cert_type_id(@cert_member_cert.cert_type)
    end
  end
end
