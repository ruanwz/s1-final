require File.dirname(__FILE__) + '/spec_helper.rb'

# Time to add your specs!
# http://rspec.info/
module RMUData

  describe Table do
    before (:all) do
      @example_data= YAML.load File.read(File.dirname(__FILE__) + '/../s1-exam-data.yaml')
    end


    before(:each) do
      # the example data with following headers
      # user github_id email level
      @example_input=[
        ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2],
        ['rainly', 'rainly_github', 'rainly@gmail.com',1]
      ]

      @example_input2=[
        ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2],
        ['rainly', 'rainly_github', 'rainly@gmail.com',1]
      ]

      @example_input_with_header=[
        ['user', 'github_id', 'email', 'level'],
        ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2],
        ['rainly', 'rainly_github', 'rainly@gmail.com',1]
      ]


      @table = RMUData::Table.new @example_input
      @empty_table = RMUData::Table.new
    end

    context "Initializing" do

      it "should able to create an empty table object and append data to it" do
        @empty_table << ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2]
        @empty_table.input_data.should == [['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2]]
        @empty_table << ['rainly', 'rainly_github', 'rainly@gmail.com',1]
        @empty_table.input_data.should == [
        ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2],
        ['rainly', 'rainly_github', 'rainly@gmail.com',1]
      ]

      end
      it "should able to create a table object with header enabled" do
        @table = RMUData::Table.new @example_input_with_header, :header => true
        @table[:header].should == %w[user github_id email level]
      end

    end

    context "Column Name" do

      it "should able to set the column name and refer column by name" do
        @table[:header][0]='user'
        @table[:header][0].should == 'user'
        # user github_id email level
        @table[:header]=%w[user github_id email level]
        @table[:header].should == %w[user github_id email level]
        @table[0]['user'].should == 'ruanwz'
        @table[0]['not exist'].should == nil
      end

      it "should able to refer column by zero-based ordinal positon" do
        @table[0].should == ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2]
        @table[0][0].should == 'ruanwz'
        @table[0][3].should == 2
      end

     it "should be possible to do all of the following row manipulations" do
       #retrieve
       @table[1].should == ['rainly', 'rainly_github', 'rainly@gmail.com',1] 
       #append
       @table << ['billy', 'billy_github', 'billy@gmail.com',3]
       @table[2].should == ['billy', 'billy_github', 'billy@gmail.com',3]

       #insert
       @table.insert 1,['billy', 'billy_github', 'billy@gmail.com',3]
       @table[1].should == ['billy', 'billy_github', 'billy@gmail.com',3]
       @table[2].should == ['rainly', 'rainly_github', 'rainly@gmail.com',1] 
       #delete
       @table.delete_at 1
       @table[1].should == ['rainly', 'rainly_github', 'rainly@gmail.com',1] 
       #transform
       @table[:header]=%w[user github_id email level]
       @table[0]['level'].should == 2
       @table.transform 0 do |e|
         if e.class == Fixnum
           e+1
         else
           e
         end
       end
       @table[0]['level'].should == 3
    end

     it "should be possible to do all of the following column manipulations" do
       #retrieve
       @table[:header]=%w[user github_id email level]
       @table['level'].should == [2,1]

       #rename
       @table.rename 3, 'LEVEL'
       @table[:header].should == %w[user github_id email LEVEL]
       @table.rename 'LEVEL','level'
       @table[:header].should == %w[user github_id email level]

       #append
       new_column = ['id', 1,2]
       @table.append_column new_column, :header => true
       @table[:header].should == %w[user github_id email level id]
       @table.input_data.should == [
        ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2,1],
        ['rainly', 'rainly_github', 'rainly@gmail.com',1,2]
      ]
       #original header exists, but new column withou header
       new_column = [4,5]
       @table.append_column new_column
       @table[:header].should == ['user','github_id','email', 'level', 'id',nil]
       @table.input_data.should == [
        ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2,1,4],
        ['rainly', 'rainly_github', 'rainly@gmail.com',1,2,5]
      ]

     end

     it "should be possible to append row without header" do
       @table = RMUData::Table.new @example_input
       new_column = [1,2]
       @table.append_column new_column
       @table[:header].should be_empty
       @table.input_data.should == [
        ['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2,1],
        ['rainly', 'rainly_github', 'rainly@gmail.com',1,2]
      ]
     end

     it "should be possible to insert row with header" do
       @table[:header]=%w[user github_id email level]
       new_column = ["id",1,2]
       #insert
       @table.insert_column 1, new_column, :header => true
       @table[:header].should == ['user', 'id', 'github_id','email', 'level',]
       @table.input_data.should == [
        ['ruanwz', 1, 'ruanwz', 'ruanwz@gmail.com',2],
        ['rainly', 2, 'rainly_github', 'rainly@gmail.com',1]
      ]
     end

     it "should be possible to insert row without header" do
       new_column = [1,2]
       #insert
       @table.insert_column 1, new_column
       @table.input_data.should == [
        ['ruanwz', 1, 'ruanwz', 'ruanwz@gmail.com',2],
        ['rainly', 2, 'rainly_github', 'rainly@gmail.com',1]
      ]
     end

     it "should be possible to delete row with header" do

       @table[:header]=%w[user github_id email level]
       @table.delete_column 1
       @table[:header].should == ['user', 'email', 'level',]
       @table.input_data.should == [
        ['ruanwz', 'ruanwz@gmail.com',2],
        ['rainly', 'rainly@gmail.com',1]
      ]

     end

     it "should be possible to delete row with header" do
       #transform
       @table[:header]=%w[user github_id email level]
       @table.transform_column 3 do |e|
         e+1
       end
       @table['level'].should == [3,2]

     end

     it "should be possible to reduce rows" do
       result=@table.select do |row|
        row[3] >1
       end
       result.should == [['ruanwz', 'ruanwz', 'ruanwz@gmail.com',2]]
     end

     it "should be possible to reduce columns" do
       pending
       result=@table.select_column do |column|
        column[0].class == Fixnum
       end
       result.should == [[2,1]]
     end

    end
  end
end
