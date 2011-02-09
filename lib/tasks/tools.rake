#you can change directory to a hidden path, it's up to you
#TEMPLATE_DIRECTORY=File.expand_path( File.join(RAILS_ROOT,"public/templates"))
namespace :tools do
  namespace :generate do

    desc "Receives a pdf file to create a template, usage (absolute path) FILE=myfile.pdf"
    #you should have pdftopdf and pdftk in your vm
    task :template do
      source_file = ENV['FILE']
      abort "FILE is mandatody" unless source_file
      remove_extension = lambda{|str| str.gsub(/\.pdf$/i, '') }
      dir_name =  remove_extension.call File.basename(source_file)
      template_path = File.dirname(File.expand_path(source_file) )
     
      

      Dir.chdir template_path
      puts `pdftk #{source_file} burst`
      Dir.glob("pg_*.pdf").each do |pdf_file|
        eps_file = remove_extension.call(pdf_file) << ".eps"
        puts "Converting #{pdf_file} to #{eps_file} ..."
        `pdftops -eps #{pdf_file} #{eps_file} 1> /dev/null 2> /dev/null`
        rm pdf_file, :verbose => false
      end
      rm "doc_data.txt", :verbose => false #pdftk metadata 
      puts "Get files at #{template_path}"
      
      
      
    end

  end
end
