ALTER TABLE `comparable_answers`
ADD INDEX `institution` (`institution_id` ASC, `dimension` ASC) ;

ALTER TABLE `comparable_answers`
ADD INDEX `institution_and_indicator` (`institution_id` ASC, `dimension` ASC, `indicator` ASC, `year` ASC) ;

ALTER TABLE `comparable_answers`
ADD INDEX `institution_and_segment_name` (`institution_id` ASC, `year` ASC, `segment_name` ASC, `dimension` ASC, `indicator` ASC, `question` ASC) ;

ALTER TABLE `report_data`
ADD INDEX `index_on_institution_id_and_dimension` (`institution_id` ASC, `dimension` ASC) ;

