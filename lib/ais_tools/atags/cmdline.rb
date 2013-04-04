module AisTools::Atags

  class Cmdline < Atag
    attr_reader :cmdline

    self.tag_type = 0x54410009

    def initialize(cmdline)
      @cmdline = cmdline
    end

    protected

    def save_data
      @cmdline.encode("UTF-8").force_encoding("BINARY") + "\x00".force_encoding("BINARY")
    end
  end
end
