class ServiceLevelsController < ApplicationController
  # GET /service_levels
  # GET /service_levels.xml
  def index
    @service_levels = ServiceLevel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @service_levels }
    end
  end

  # GET /service_levels/1
  # GET /service_levels/1.xml
  def show
    @service_level = ServiceLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @service_level }
    end
  end

  # GET /service_levels/new
  # GET /service_levels/new.xml
  def new
    @service_level = ServiceLevel.new
    @segments = Segment.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @service_level }
    end
  end

  # GET /service_levels/1/edit
  def edit
    @service_level = ServiceLevel.find(params[:id])
    @segments = Segment.all
  end

  # POST /service_levels
  # POST /service_levels.xml
  def create
    @service_level = ServiceLevel.new(params[:service_level])

    respond_to do |format|
      if @service_level.save
        format.html { redirect_to(@service_level, :notice => 'ServiceLevel was successfully created.') }
        format.xml  { render :xml => @service_level, :status => :created, :location => @service_level }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @service_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /service_levels/1
  # PUT /service_levels/1.xml
  def update
    @service_level = ServiceLevel.find(params[:id])

    respond_to do |format|
      params[:service_level][:segment_ids] ||= []  
      if @service_level.update_attributes(params[:service_level])
        format.html { redirect_to(@service_level, :notice => 'ServiceLevel was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @service_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /service_levels/1
  # DELETE /service_levels/1.xml
  def destroy
    @service_level = ServiceLevel.find(params[:id])
    @service_level.destroy

    respond_to do |format|
      format.html { redirect_to(service_levels_url) }
      format.xml  { head :ok }
    end
  end
end
