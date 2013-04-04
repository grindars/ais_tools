module AisTools::Atags
  class Atag
    class << self
      attr_accessor :tag_type
    end

    def save
      data = save_data

      buffer = ""
      buffer << [ data.length, self.class.tag_type ].pack("VV")
      buffer << data

      buffer
    end
  end
end
