# -*- coding: utf-8 -*-
class Question < ActiveRecord::Base
  belongs_to :survey


  def survey_info
    "#{ServiceLevel.find(survey.service_level_id).name} - #{Segment.find(survey.segment_id).name}"
    end

  def <=>(other)
    self_arr = self.number.split('.')
    other_arr = other.number.split('.')
    first_number_status = self_arr[0].to_i <=> other_arr[0].to_i 
    second_number_status = self_arr[1].to_i <=> other_arr[1].to_i 
    third_number_status = self_arr[2].to_i <=> other_arr[2].to_i 

    return  first_number_status unless first_number_status == 0
    return  second_number_status unless second_number_status == 0
    return  third_number_status
  end
end
