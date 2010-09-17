require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
module ExampleScenario

  describe 'Running Example Scenario' do
    before (:all) do
      @example_data= YAML.load File.read(File.dirname(__FILE__) + '/../s1-exam-data.yaml')
      @table = RMUData::Table.new @example_data, :header => true
    end

    it "should able to Restrict the rows to dates that occur in June 2006" do
     @table.select do |row|
        row['PROCEDURE_DATE']=~/06\/\d\d\/06/
      end

    end

    it "should convert the AMOUNT, TARGET_AMOUNT, and AMTPINSPAID columns to money format. (e.g 1500 becomes $15.00)" do
      [1,2,3].each do |index|
        @table.transform_column index do |money|
          "$" + ("%.2f" % (money.to_i/10))
        end
      end

    end

    it "should remove the count column" do
      @table.delete_column 4
    end

    it "should change the date format ot YYYY-MM-DD" do
      @table.transform_column 0 do |date|
        matcher=/(\d\d)\/(\d\d)\/(\d\d)/.match date
        m=matcher[1]
        d=matcher[2]
        y="20"+matcher[3]
        [y,m,d].join '-'
      end
    end

    it "should convert the table to an array of arrays, and then write out a YAML file called 's1-exam-data-transformed.yaml', including the headers as the first row." do
      f = File.new (File.dirname(__FILE__)+"/../s1-exam-data-transformed.yaml", "w")
      f.write YAML.dump(@table.input_data.insert 0, @table.header)
    end

    it "should check this file and the code used to generate it into your repository for review." do
    end

  end
end
