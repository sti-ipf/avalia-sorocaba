DROP TABLE groups;

CREATE  TABLE `groups` (
  `id` INT NOT NULL ,
  `name` VARCHAR(250) NULL ,
  PRIMARY KEY (`id`) );

ALTER TABLE `groups` CHANGE COLUMN `id` `id` INT(11) NOT NULL AUTO_INCREMENT  ;

CREATE  TABLE `regions` (
  `id` INT NOT NULL ,
  `name` VARCHAR(250) NULL );

ALTER TABLE `institutions`
ADD COLUMN `group_id` VARCHAR(45) NULL  AFTER `id_2008` ,
ADD COLUMN `region_id` INT NULL  AFTER `id_2008` ;

