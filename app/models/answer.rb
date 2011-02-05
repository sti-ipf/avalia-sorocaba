# -*- coding: utf-8 -*-
class Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :question

  before_validation :default_values

  validates_presence_of :zero, :one, :two, :three, :four, :five
 
  NUMBERS = [ :zero, :one, :two, :three, :four, :five ]

  def number=(attr)
    NUMBERS.each { |n| self.send "#{n}=", 0 }
    self.send "#{attr}=", 1
  end

  def number
    ret = "zero"
   NUMBERS.each_with_index do |v,i| 
      ret = v.to_s if (self.send v) == 1
    end
    ret
  end

 protected

  def default_values
    self.zero = 0 unless self.zero
    self.one = 0 unless self.one
    self.two = 0 unless self.two
    self.three = 0 unless self.three
    self.four = 0 unless self.four
    self.five = 0 unless self.five
  end

end
