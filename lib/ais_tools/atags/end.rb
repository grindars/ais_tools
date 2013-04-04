module AisTools::Atags
  class End < Atag
    self.tag_type = 0x00000000

    protected

    def save_data
      ""
    end
  end
end
