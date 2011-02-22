module UniFreire
  module Graphics
    class GeralPercentualRespondido
      def self.get_infantil
        count=ActiveRecord::Base.connection.execute("
            select sum(ct) from (select institution_id,count(*) as ct from
            (select institution_id,segment_name from comparable_answers ca
            inner join institutions i on i.id=ca.institution_id
            where i.infantil_type in (1,2,3) and segment_name <> 'Alessandra'
            group by institution_id,segment_name) a
            group by institution_id) b").fetch_row[0].to_i
            puts "*" * 100
            puts count
            puts ((count.fdiv 370) * 100).round(2).to_s << "%"
        {:count=>count, :percentual=>((count.fdiv 370) * 100).round(2).to_s << "%"}

      end

      def self.get_data_for_type(group_type,total)
        count=ActiveRecord::Base.connection.execute("
            select sum(ct) from (select institution_id,count(*) as ct from
            (select institution_id,segment_name
            from comparable_answers ca inner join institutions i on i.id=ca.institution_id
            where i.group_id=#{group_type} and segment_name <> 'Alessandra'
            group by institution_id,segment_name) a
            group by institution_id) b").fetch_row[0].to_i
        {:count=>count, :percentual=>((count.fdiv total) * 100).round(2).to_s << "%"}
      end
    end
  end
end

