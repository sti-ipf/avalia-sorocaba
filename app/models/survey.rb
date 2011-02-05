class Survey < ActiveRecord::Base
  belongs_to :segment
  belongs_to :service_level
  has_many :questions
end
