module AisTools
  class Instructions::ExecuteFunction < Instruction
    declare 0x5853590D, "execute_function",
      :function => :pointer,
      :args     => :ptrlist

    attr_accessor :function
    attr_accessor :args

    def read(&reader)
      attributes = reader.call
      @function = attributes & 0xFFFF
      arguments = attributes >> 16
      @args = Array.new(arguments) { |index| reader.call }
    end

    def write(&writer)
      attributes = (@args.length << 16) |
                   @function

      writer.call attributes
      writer.call @args, true
    end
  end
end