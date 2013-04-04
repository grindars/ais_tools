module AisTools
  class Instructions::JumpAndClose < Instruction
    declare 0x58535906, "jump_and_close",
      :address => :pointer

    attr_accessor :address

    def read(&reader)
      @address = reader.call
    end

    def write(&writer)
      writer.call @address
    end
  end
end
