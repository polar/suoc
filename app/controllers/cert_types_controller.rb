class CertTypesController < BaseController
  layout "club_operations"

  filter_access_to :all

  def index
    @cert_types = CertType.find(:all)
  end

  def show
    @cert_type = CertType.find(params[:id])
  end

  def new
    @cert_type = CertType.new
    @submit = "Create"
  end

  def edit
    @cert_type = CertType.find(params[:id])
    @submit = "Update"
  end

  def create
    @cert_type = CertType.new(params[:cert_type])

    if @cert_type.save
      flash[:notice] = "Certification Type #{@cert_type.name} was successfully added."
      redirect_to(@cert_type)
    else
      flash[:error] = "Certification Type was not created."
      @submit = "Create"
      render :action => "new"
    end
  end

  def update
    @cert_type = CertType.find(params[:id])

    if @cert_type.update_attributes(params[:cert_type])
      flash[:notice] = "Certification Type #{@cert_type.name} was successfully updated."
      redirect_to(@cert_type)
    else
      flash[:error] = "Certification Type was not updated."
      @submit = "Update"
      render :action => "edit"
    end
  end

  def destroy
    @cert_type = CertType.find(params[:id])

    if !CertOrg.all( :conditions => {:cert_type_id => @cert_type }).empty?
      @cert_type.errors.add_to_base "Cannot delete, this type is referenced by certification organizations"
      flash[:error] = "Cannot delete Certification Type #{@cert_type} as it is referenced by certification organizations."
    else
      @cert_type.destroy
      flash[:notice] = "Certification Type #{@cert_type.name} was successfully deleted."
      redirect_to(cert_types_url)
    end
  end
end
