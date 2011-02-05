class ServiceLevel < ActiveRecord::Base
  has_and_belongs_to_many :institutions
  has_and_belongs_to_many :segments
end
