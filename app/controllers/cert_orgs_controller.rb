class CertOrgsController < BaseController
  layout "club_operations"

  filter_access_to :all

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
      flash[:notice] = 'CertOrg was successfully created.'
      redirect_to(@cert_org)
    else
      @submit = "Create"
      @types = CertType.all
      render :action => "new"
    end
  end

  def update
    @cert_org = CertOrg.find(params[:id])

    if @cert_org.update_attributes(params[:cert_org])
      flash[:notice] = 'CertOrg was successfully updated.'
      redirect_to(@cert_org)
    else
      @submit = "Update"
      @types = CertType.all
      render :action => "edit"
    end
  end

  def destroy
    @cert_org = CertOrg.find(params[:id])
    @cert_org.destroy

    redirect_to(cert_orgs_url)
  end
end
