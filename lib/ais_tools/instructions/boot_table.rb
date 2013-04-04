module AisTools
  class Instructions::BootTable < Instruction
    declare 0x58535907, "boot_table",
      :length  => :number,
      :field   => :range,
      :address => :pointer,
      :data    => :pointer,
      :sleep   => :number

    attr_accessor :length, :field, :address, :data, :sleep

    def read(&reader)
      type = reader.call

      @length = type & 0xFF
      start   = (type & 0xFF00) >> 8
      stop    = (type & 0xFF0000) >> 16
      @field  = start..stop
      @address = reader.call
      @data = reader.call
      @sleep = reader.call
    end

    def write(&writer)
      stop = @field.begin
      start = @field.end

      type = (start << 16) |
             (stop << 8) |
             @length

      writer.call type
      writer.call @address
      writer.call @data
      writer.call @sleep
    end
  end
end