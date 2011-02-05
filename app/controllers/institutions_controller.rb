class InstitutionsController < ApplicationController
  # GET /institutions
  # GET /institutions.xml
  def index
    @institutions = Institution.all.sort

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @institutions }
    end
  end

  # GET /institutions/1
  # GET /institutions/1.xml
  def show
    @institution = Institution.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @institution }
    end
  end

  # GET /institutions/new
  # GET /institutions/new.xml
  def new
    @institution = Institution.new
    @service_levels = ServiceLevel.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @institution }
    end
  end

  # GET /institutions/1/edit
  def edit
    @institution = Institution.find(params[:id])
    @service_levels = ServiceLevel.all
  end

  # POST /institutions
  # POST /institutions.xml
  def create
    @institution = Institution.new(params[:institution])

    respond_to do |format|
      if @institution.save
        @institution.service_levels.each do |sl|
          sl.segments.each do |segment|
            @user = User.new(:institution_id => @institution.id, :service_level_id => sl.id, 
                             :segment_id => segment.id, :password => nil )
            @user.save
          end
        end

        format.html { redirect_to(@institution, :notice => 'Institution was successfully created.') }
        format.xml  { render :xml => @institution, :status => :created, :location => @institution }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @institution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /institutions/1
  # PUT /institutions/1.xml
  def update
    @institution = Institution.find(params[:id])

    respond_to do |format|
      params[:institution][:service_level_ids] ||= []  
      if @institution.update_attributes(params[:institution])
        format.html { redirect_to(@institution, :notice => 'Institution was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @institution.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /institutions/1
  # DELETE /institutions/1.xml
  def destroy
    @institution = Institution.find(params[:id])
    @institution.destroy

    respond_to do |format|
      format.html { redirect_to(institutions_url) }
      format.xml  { head :ok }
    end
  end
end
