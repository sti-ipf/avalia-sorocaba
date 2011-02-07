insert into regions (id, name) values
  (0, 'POLO PROGRESSO'),
  (1, 'POLO OESTE 1'),
  (2, 'POLO OESTE 2'),
  (3, 'POLO OESTE 3'),
  (4, 'POLO APARECIDINHA'),
  (5, 'POLO NORTE IPA 1'),
  (6, 'POLO NORTE ITA 1'),
  (7, 'POLO NORTE ITA 2'),
  (8, 'POLO NORTE ITA 3'),
  (9, 'POLO CENTRAL'),
  (10, 'POLO LESTE'),
  (11, 'POLO ÉDEN/CAJURU'),
  (12, 'POLO LESTE 2'),
  (13, 'POLO BRIGADEIRO');

update institutions set region_id = 0 where id in (66, 48, 69, 62, 41, 132, 76, 25, 122);

update institutions set region_id = 1 where id in (90, 81, 39, 55, 64, 34, 22, 77, 65, 109, 112, 108);

update institutions set region_id = 2 where id in (47, 57, 63, 12, 18, 53, 44, 33, 130, 111, 99);

update institutions set region_id = 3 where id in (31, 37, 60, 88, 92, 125, 127);

update institutions set region_id = 4 where id in (118, 11, 83);

update institutions set region_id = 5 where id in (85, 74, 89, 15, 61, 54, 27, 128, 105, 101);

update institutions set region_id = 6 where id in (70, 50, 67, 73, 93, 115, 104, 106, 100);

update institutions set region_id = 7 where id in (21, 36, 124, 103, 94, 96, 98, 102);

update institutions set region_id = 8 where id in (29, 38, 71, 9, 17, 68, 126, 28, 131, 119);

update institutions set region_id = 9 where id in (20, 32, 58, 56, 121, 120, 113);

update institutions set region_id = 10 where id in (24, 51, 78, 84, 79, 30, 45, 123, 107, 114);

update institutions set region_id = 11 where id in (35, 14, 59, 91, 129);

update institutions set region_id = 12 where id in (87, 86, 16, 75, 52, 49, 110);

update institutions set region_id = 13 where id in (19, 46, 72, 133);

