class DimensionsController < ApplicationController
  # GET /dimensions
  # GET /dimensions.xml
  def index
    @dimensions = Dimension.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dimensions }
    end
  end

  # GET /dimensions/1
  # GET /dimensions/1.xml
  def show
    @dimension = Dimension.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @dimension }
    end
  end

  # GET /dimensions/new
  # GET /dimensions/new.xml
  def new
    @dimension = Dimension.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @dimension }
    end
  end

  # GET /dimensions/1/edit
  def edit
    @dimension = Dimension.find(params[:id])
  end

  # POST /dimensions
  # POST /dimensions.xml
  def create
    @dimension = Dimension.new(params[:dimension])

    respond_to do |format|
      if @dimension.save
        format.html { redirect_to(@dimension, :notice => 'Dimension was successfully created.') }
        format.xml  { render :xml => @dimension, :status => :created, :location => @dimension }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dimension.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dimensions/1
  # PUT /dimensions/1.xml
  def update
    @dimension = Dimension.find(params[:id])

    respond_to do |format|
      if @dimension.update_attributes(params[:dimension])
        format.html { redirect_to(@dimension, :notice => 'Dimension was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dimension.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dimensions/1
  # DELETE /dimensions/1.xml
  def destroy
    @dimension = Dimension.find(params[:id])
    @dimension.destroy

    respond_to do |format|
      format.html { redirect_to(dimensions_url) }
      format.xml  { head :ok }
    end
  end
end
