module AisTools
  class Binary
    attr_accessor :instructions

    def initialize
      @instructions = []
      @io = nil
    end

    def load(io)
      @io = io
      begin        
        magic = readw
        if magic != AisTools::Magic
          raise "unexpected magic word: #{magic.to_s 16}, expected #{AisTools::AIS::Magic}"
        end

        stop = false
        until stop
          word = readw
          instruction = AisTools::Instruction.create_by_opcode(word)
          instruction.read &method(:readw)

          @instructions << instruction
          break if instruction.is_a? Instructions::JumpAndClose
        end
      ensure
        @io = nil
      end
    end

    def save(io)
      @io = io
      begin
        writew AisTools::Magic
        @instructions.each do |instruction|
          writew instruction.opcode
          instruction.write &method(:writew)
        end
      ensure
        @io = nil
      end
    end

    private

    def readw(words = 1, unpack = true)
      data = @io.read(words * 4)
      raise "unexpected end of file" if data.nil? || data.length < words * 4
      
      if unpack
        unpacked = data.unpack("V")
        if words == 1
          unpacked[0]
        else
          unpacked
        end
      else
        data
      end
    end

    def writew(data, pack = true)
      if pack
        if data.kind_of? Array
          data = data.pack("V*")
        else
          data = [ data ].pack("V")
        end
      end

      @io.write data
    end

    def self.load(io)
      binary = Binary.new
      binary.load(io)
      binary
    end
  end
end