module AisTools::Atags
  class Mem32 < Atag
    attr_reader :size, :start

    self.tag_type = 0x54410002

    def initialize(size, start)
      @size = size
      @start = start
    end

    protected

    def save_data
      [ @size, @start ].pack("VV")
    end 
  end
end
