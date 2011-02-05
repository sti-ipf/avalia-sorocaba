# -*- coding: undecided -*-
class SurveysController < ApplicationController
  # GET /surveys
  # GET /surveys.xml
  def index
    @surveys = Survey.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @surveys }
    end
  end

  # GET /surveys/1
  # GET /surveys/1.xml
  def show
    @institution_name = Institution.find(current_user.institution_id).name
    service_level_name = ServiceLevel.find(current_user.service_level_id).name
    segment_name = Segment.find(current_user.segment_id).name
    @subtitle = "#{service_level_name} - #{segment_name}"
    @user = current_user

    current_page = session[:question_page] || 0
    page = params[:page] ? params[:page].to_i - 1 : current_page
    page = 0 if page < 0
    session[:question_page] = page
    @survey = Survey.find(params[:id])
    
    if page < @survey.questions.count
      @question = @survey.questions.sort[page] 
      
      @answer ||= Answer.find( :last, :conditions => "user_id = #{@user.id} AND question_id = #{@question.id}")
      @answer ||= Answer.new
    end
    respond_to do |format|
      if page <  @survey.questions.count
        format.html # show.html.erb
        format.xml  { render :xml => @survey }
      else
        format.html { render :template => "surveys/finale.html.erb" }
      end
    end
  end

  # GET /surveys/new
  # GET /surveys/new.xml
  def new
    @survey = Survey.new
    @segments = Segment.all
    @service_levels = ServiceLevel.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @survey }
    end
  end

  # GET /surveys/1/edit
  def edit
    @survey = Survey.find(params[:id])
  end

  # POST /surveys
  # POST /surveys.xml
  def create
    @survey = Survey.new(params[:survey])

    respond_to do |format|
      if @survey.save
        format.html { redirect_to(@survey, :notice => 'Survey was successfully created.') }
        format.xml  { render :xml => @survey, :status => :created, :location => @survey }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /surveys/1
  # PUT /surveys/1.xml
  def update
    @survey = Survey.find(params[:id])

    respond_to do |format|
      if @survey.update_attributes(params[:survey])
        format.html { redirect_to(@survey, :notice => 'Survey was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @survey.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /surveys/1
  # DELETE /surveys/1.xml
  def destroy
    @survey = Survey.find(params[:id])
    @survey.destroy

    respond_to do |format|
      format.html { redirect_to(surveys_url) }
      format.xml  { head :ok }
    end
  end


 def save_answer
   if(params[:answer][:id])
     @answer = Answer.find(params[:answer][:id])
   else
    @answer = Answer.new(params[:answer])
   end
    @answer.user_id = current_user.id
    @answer.question_id = params[:question][:id]
    @answer.survey_id = params[:id]

   @question = Question.find(@answer.question_id)
   
    respond_to do |format|
      if (@answer.id ? @answer.update_attributes(params[:answer]) : @answer.save)
        @survey = Survey.find(params[:id])
        session[:question_page] = session[:question_page] + 1
        format.html { redirect_to @survey }
        format.xml  { render :xml => @answer, :status => :created, :location => @answer }
      else
        format.html { render :action => "show" }
        format.xml  { render :xml => @answer.errors, :status => :unprocessable_entity }
      end
   end
 end

  def get_pdf
   @institution_name = Institution.find(current_user.institution_id).name
    service_level_name = ServiceLevel.find(current_user.service_level_id).name
    segment_name = Segment.find(current_user.segment_id).name
    @subtitle = "#{service_level_name} - #{segment_name}"
    @user = current_user
    @survey = Survey.find(params[:id])

    @questions = @survey.questions.sort

    @answers = []
    @questions.each do |question|
      @answers[question.id] ||= Answer.find( :last, :conditions => "user_id = #{@user.id} AND question_id = #{question.id}")
    end
    respond_to do |format|
      format.html
    end
  end
 
end
