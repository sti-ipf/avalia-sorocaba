require "yaml"

def get_year_formula year
  line = ""
  if year.class == String
    if year == ""
      line += ";não existe"
    else
      line += ";#{year}"
    end
  else
    line += ";"
    year.each do |y|
      line += "#{y} + "
    end
    line = line[0..line.size - 3] unless !line[line.size - 3 .. line.size] == " + "
  end
  line
end

dt = YAML::load(File.open("config/data_transformations.yml"))
out = "2010 indicator;2009 formula;2008 formula\n"
dt.each_pair do |key, value|
  line = "#{key[7..key.size]}"
  line += get_year_formula value[2009]
  line += get_year_formula value[2008]
  print "."
  out += "#{line}\n"
end
puts ""
puts "Writing the csv file"
file_out = File.open("config/data_transformations.csv", "w")
file_out.write out
file_out.close
puts "Finished the transformation"

