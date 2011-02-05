class User < ActiveRecord::Base
  has_many :answers
  has_many :attendees
  belongs_to :segment
  belongs_to :institution
  belongs_to :service_level

  accepts_nested_attributes_for :attendees

  def <=>(other)
    institution.name <=> other.institution.name
  end
end
