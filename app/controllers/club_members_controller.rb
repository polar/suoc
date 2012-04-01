class ClubMembersController < ApplicationController

  def index
  end

  def new
    @club_member = ClubMember.new
    @successful = true

    respond_to do |type|
      type.html do
        if @successful
          @options = { :action => "create" }
          render :partial => "form", :layout => true
        else
          redirect_to_main
        end
      end
    end
  end

  def create
    begin
      @club_member = ClubMember.new(params[:club_member])
      @successful = @club_member.save
    rescue
      flash[:error], @successful  = $!.to_s, false
    end

    flash[:info] = "ClubMember created" if @successful

    respond_to do |type|
      type.html do
        if not @successful
          @options = { :action => "create" }
          render :partial => "form", :layout => true
        else
          redirect_to_main
        end
      end
    end
  end

  def edit
    begin
      @club_member = ClubMember.find(params[:id])
      @successful = !@club_member.nil?
    rescue
      flash[:error], @successful  = $!.to_s, false
    end

    respond_to do |type|
      type.html do
        if @successful
          @options = { :action => "update", :id => params[:id] }
          render :partial => "form", :layout => true
        else
          redirect_to_main
        end
      end
    end
  end

  def update
    begin
      @club_member = ClubMember.find(params[:id])
      @successful = @club_member.update_attributes(params[:club_member])
    rescue
      flash[:error], @successful  = $!.to_s, false
    end

    flash[:info] = "ClubMember updated" if @successful

    respond_to do |type|
      type.html do
        if not @successful
          @options = { :action => "update", :id => params[:id] }
          render :partial => "form", :layout => true
        else
          redirect_to_main
        end
      end
    end
  end

  def destroy
    begin
      @successful = ClubMember.find(params[:id]).destroy
    rescue
      flash[:error], @successful  = $!.to_s, false
    end

    flash[:info] = "ClubMember deleted" if @successful

    respond_to do |type|
      type.html {return redirect_to_main}
    end
  end

  def cancel
    @successful = true

    respond_to do |type|
      type.html {return redirect_to_main}
    end
  end

protected
  def redirect_to_main
    redirect_to common_redirection
  end

  def common_redirection
    { :action => 'index' }
  end
end
