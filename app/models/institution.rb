class Institution < ActiveRecord::Base
  has_and_belongs_to_many :service_levels
  belongs_to :group

  def <=>(other)
    name <=> other.name
  end

 def graph_dimension(dimension,service_level,group)
    data = mean_dimension(dimension,service_level)
    mean_group =  Institution.general_mean_dimension(dimension,group)
    values = []
    values_mean = []
    labels = []
    graph = Gruff::Bar.new("400x300")
    graph.minimum_value = 0
    graph.maximum_value = 5
    graph.marker_count = 10
    graph.sort = false
    data[:users].each do |user|
      user.each do |seg,value|
        values << value.round(2)
        values_mean << mean_group[seg].round(2)
        labels << seg
      end
    end


    graph.data("Media da UE", values)
    graph.data("Media do Agrupamento", values_mean)

    final_labels = {}
    labels.each_with_index { |v,k|  final_labels.merge!({k => v}) }
    graph.labels = final_labels
    graph.write("#{RAILS_ROOT}/public/graficos/#{name}_#{service_level.name}_d#{dimension}.png")
  end

end
