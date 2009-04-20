class AcctCategoriesController < BaseController
  layout "club_operations"

  PER_PAGE = 10
  ENTRIES_PER_PAGE  = 10

  filter_access_to :all

  include Viewable
  uses_tiny_mce(:options => AppConfig.default_mce_options.merge({:editor_selector => "rich_text_editor"}),
    :only => [:new, :create, :update, :edit])


  def index
    @categories = AcctCategory.paginate(:all,
        :page => params[:page], :per_page => PER_PAGE)

  end

  def show
    @category = AcctCategory.find(params[:id])
  end

  def new
    @category = AcctCategory.new
    @submit = "Create"
  end

  def edit
    @category = AcctCategory.find(params[:id])
    @submit = "Update"
  end

  def create
    AcctCategory.enumeration_model_updates_permitted = true
    @category = AcctCategory.new(params[:acct_category])

    if @category.save
      flash[:notice] = "The account category #{@category.name} was successfully created."
      redirect_to @category
    else
      render :action => "new"
    end
  end

  def update
    AcctCategory.enumeration_model_updates_permitted = true

    @category = AcctCategory.find(params[:id])

    if @category.update_attributes(params[:acct_category])
      flash[:notice] = "The account category #{@category.name} was successfully updated."
      redirect_to @account_type
    else
      render :action => "edit"
    end
  end

  def destroy
    AcctCategory.enumeration_model_updates_permitted = true
    @category = AcctCategory.find(params[:id])
    error = false
    if !AcctEntry.all(:conditions => { :category_id => @category }).empty?
      @category.errors.add_to_base "Account Category #{@category.name} has associated transactions."
      error = true
    end
    if !AcctAction.all(:conditions => { :category_id => @category }).empty?
      @category.errors.add_to_base "Account Category #{@category.name} has associated actions."
      error = true
    end
    if !error && @category.destroy
      flash[:notice] = "Account Category #{@category.name} has been deleted."
      redirect_to acct_categories_url
    else
      flash[:error] = "Account Category #{@category.name} cannot be deleted."
    end
  end
end
