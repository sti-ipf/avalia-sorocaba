class QueryFunctions < ActiveRecord::Migration
  def self.up
    execute %Q{CREATE FUNCTION answer_value(a0 int, a1 int,a2 int,a3 int,a4 int,a5 int ) returns int
    return if(a1 = 1,1,0)+if(a2 = 1,2,0)+if(a3 = 1,3,0)+if(a4 = 1,4,0)+if(a5 = 1,5,0); }
    
    execute %Q{CREATE FUNCTION strSplit(x varchar(255), delim varchar(12), pos int) returns varchar(255)
    return replace(substring(substring_index(x, delim, pos), length(substring_index(x, delim, pos - 1)) + 1), delim, '');}

    execute %Q{CREATE FUNCTION indicator_id(num varchar(255)) returns varchar(5)
        return substring_index(num,'.',-2);}
    
    execute %Q{CREATE FUNCTION dimension_id(num varchar(255)) returns int
    return cast(strSplit( num , '.', 1) as unsigned);}

    execute %Q{CREATE FUNCTION question_num(num varchar(255)) returns int
    return cast(strSplit( num , '.', 3) as unsigned);}
  end

  def self.down
  end
end
