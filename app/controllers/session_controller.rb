# -*- coding: utf-8 -*-
class SessionController < ApplicationController

  def index
    @institution_name = Institution.find(current_user.institution_id).name
    service_level_name = ServiceLevel.find(current_user.service_level_id).name
    segment_name = Segment.find(current_user.segment_id).name
    @subtitle = "#{service_level_name} - #{segment_name}"
    @survey = Survey.find(:first, 
                             :conditions => "service_level_id = #{current_user.service_level_id} AND segment_id = #{current_user.segment_id}")
    @user = current_user
  end

  def new
    @institutions = Institution.all.sort
    @service_levels = ServiceLevel.all
    @segments = Segment.all
    
  end

  def create
    if authenticated?(params)
      redirect_to :action => "index"
    else
      flash[:error] = "Confira os dados para acesso e caso necessário, contacte o help-desk: 11 3024-3654"
      redirect_to :action => "new"
    end

  end

  def destroy
    reset_session
    redirect_to :action => "new"
  end

end
