class UpdateAllAnswers < ActiveRecord::Migration
  def self.up
    execute "drop procedure if exists update_all_answers"
    execute %Q{
      create procedure update_all_answers()
      BEGIN
          declare count, done int default 0;
          declare ir int;
          declare i9 int;
          declare i8 int;
      	declare c cursor for SELECT id, id_2009, id_2008 from institutions where id_2008 is not null and id_2008 > 0 and id_2009 is not null and id_2009 > 0;
      	declare continue handler for not found set done = 1;
          OPEN c;
      	the_loop: LOOP
              FETCH c into ir, i9, i8;

      		if done then
                  LEAVE the_loop;
              end if;
              -- begin transaction;
              -- select ir, i9, i8;
      		update all_answers set id_instituicao=ir where id_instituicao=i9 and year(data) = 2009;
      		update all_answers set id_instituicao=ir where id_instituicao=i8 and year(data) = 2008;


              set count = count + 1;
      	END LOOP;
          CLOSE c;
      END
    }
    say_with_time "Updating existing records" do
      execute "CALL update_all_answers;"
    end
    execute "drop procedure update_all_answers;"
  end

  def self.down
    execute %{drop procedure if exists update_all_answers;}
  end
end
