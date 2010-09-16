module RMUData
  class ArrayIndexByStr < Array
    def initialize(origin_array,header=[])
      #@internal_array = Array.new origin_array
      super origin_array
      @header =header
    end

    def [](index)
      begin
        super
      rescue TypeError
        integer_index=@header.find_index index
        super integer_index if integer_index
      end
    end

  end
  class Table

    attr_reader :input_data
    attr_accessor :header

    def initialize(tabular_data=[],option=Hash.new)
      if option[:header]==true
        @header=tabular_data[0]
        @input_data= tabular_data[1..-1]
      else
        @header=[]
        @input_data= tabular_data
      end
    end

    def <<(new_row)
      @input_data << new_row
    end

    def [](column)
      if column == :header
        @header
      elsif column.class == Fixnum
        ArrayIndexByStr.new @input_data[column],@header
      elsif column.class == String
        integer_index=@header.find_index column
        return nil unless integer_index
        column_result =[]
        @input_data.each do |row|
          column_result<<row[integer_index]
        end
        column_result
      end
    end

    def []=(column,header_array)
      if column == :header
        @header = header_array
      end
    end

    def insert(position,new_row)
      @input_data.insert position,new_row
    end

    def delete_at(position)
      @input_data.delete_at position
    end

    def transform(row, &block)
      @input_data[row].map! &block
    end

    def rename(index, new_name)
      case index
      when String
        integer_index = @header.find_index index
        @header[integer_index]=new_name
      when Fixnum
        @header[index]=new_name
      end
    end

    def append_column(new_column,option=Hash.new)
      insert_column -1,new_column, option
    end

    def insert_column(position, new_column,option=Hash.new)
      if option[:header]
        @header.insert position, new_column.first
        @input_data.each_with_index do |row, i|
          row.insert position, new_column[i+1]
        end
      else
        @header << nil unless @header.empty?
        @input_data.each_with_index do |row, i|
          row.insert position, new_column[i]
        end
      end

    end

    def delete_column(position)
      @header.delete_at position unless @header.empty?
      @input_data.each_with_index do |row, i|
        row.delete_at position
      end
    end

    def transform_column(position, &block)

      @input_data.each_with_index do |row, i|
        row[position]= block.call row[position]
      end
    end

    def select(&block)
      @input_data.select &block
    end

    def select_column(&block)
    end

  end
end
