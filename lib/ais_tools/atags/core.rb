module AisTools::Atags
  class Core < Atag
    attr_reader :flags, :pagesize, :rootdev

    self.tag_type = 0x54410001

    def initialize(flags, pagesize, rootdev)
      @flags = flags
      @pagesize = pagesize
      @rootdev = rootdev
    end

    protected

    def save_data
      [ @flags, @pagesize, @rootdev ].pack("VVV")
    end
  end
end