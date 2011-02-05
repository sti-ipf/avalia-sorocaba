class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to(@user, :notice => 'User was successfully created.') }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(sessions_path) }
        format.xml  { head :ok }
      else
        # format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  def show_status
    @data = []
    @completed = 0
    @in_progress = 0
    @not_started = 0
    User.all.sort.each do |user|
      institution = Institution.find(user.institution_id)
      if institution
        institution_name = institution.name
        segment_name = Segment.find(user.segment_id).name
        service_level_name = ServiceLevel.find(user.service_level_id).name
        survey = Survey.find(:first,
                            :conditions => "service_level_id = #{user.service_level_id} AND segment_id = #{user.segment_id}")
        if survey
          questions = survey.questions.count
          answers = user.answers.count
          if questions < answers
            status = "Completo"
            @completed = @completed + 1
          elsif answers > 0
            status = "Em preenchimento"
            @in_progress = @in_progress + 1
          else
            status = "Não iniciado"
            @not_started = @not_started + 1
          end
          @data << [ institution_name, service_level_name, segment_name, status ]
        end
      end
    end
  end  
 
end
