$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rmu_data'
require 'yaml'

#load the input data
example_data= YAML.load File.read(File.dirname(__FILE__) + '/../s1-exam-data.yaml')

#initialize with the input data
table = RMUData::Table.new example_data, :header => true

#able to Restrict the rows to dates that occur in June 2006
table.select do |row|
   row['PROCEDURE_DATE']=~/06\/\d\d\/06/
end

#convert the AMOUNT, TARGET_AMOUNT, and AMTPINSPAID columns to money format. (e.g 1500 becomes $15.00)
[1,2,3].each do |index|
  table.transform_column index do |money|
    "$" + ("%.2f" % (money.to_i/10))
  end
end

#should remove the count column
table.delete_column 4


#should change the date format ot YYYY-MM-DD
table.transform_column 0 do |date|
  matcher=/(\d\d)\/(\d\d)\/(\d\d)/.match date
  m=matcher[1]
  d=matcher[2]
  y="20"+matcher[3]
  [y,m,d].join '-'
end

#convert the table to an array of arrays, and then write out a YAML file called 's1-exam-data-transformed.yaml', including the headers as the first row.
f = File.new(File.dirname(__FILE__)+"/../s1-exam-data-transformed.yaml", "w")

f.write YAML.dump(table.input_data.insert 0, table.header)
 
