module AisTools
  class Instructions::SectionLoad < Instruction
    declare 0x58535901, "section",
      :address => :pointer,
      :data    => :file

    attr_accessor :address, :data

    def read(&reader)
      @address = reader.call
      size = reader.call
      
      words = (size + 3) / 4
      @data = reader.call(words, false)

      if size % 4 != 0
        @data = @data.slice(0, size)
      end
    end

    def write(&writer)
      writer.call @address
      writer.call @data.length

      if @data.length % 4 == 0
        padded = @data
      else
        padded = @data + "\x00" * (4 - @data.length % 4)
      end

      writer.call padded, false
    end
  end
end
