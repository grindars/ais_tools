module AisTools
  module Features::Linux
    def load_linux(options)
      core_flags = 0
      core_flags |= 1 if options[:readonly]

      atags = [
        Atags::Core.new(
            core_flags,
            options[:pagesize],
            options[:rootdev]
        ),

        *options[:memory].map do |region|
          Atags::Mem32.new(region[:size], region[:base])
        end,

        Atags::Cmdline.new(options[:cmdline]),
        Atags::End.new
      ]

      kickstart_buffer = [
        0xE3A00000,             # 00: mov r0, #0
        0xE59F1004,             # 04: ldr r1, [pc, #4] ; 0x10
        0xE59F2004,             # 08: ldr r2, [pc, #4] ; 0x14
        0xE59FF004,             # 0c: ldr pc, [pc, #4] ; 0x18
        options[:machine],      # machine id
        options[:base] + 8 * 4, # atags base
        options[:base] + 4096,  # kernel entry
        0x00000000,             # padding
      ].pack("V*")

      atags.each do |tag|
        kickstart_buffer << tag.save
      end

      kernel = File.open(options[:kernel], "rb") { |io| io.read }

      section options[:base], kickstart_buffer
      0.step(kernel.length, 8192) do |offset|
        chunk = 8192
        chunk = kernel.length - offset if kernel.length - offset < chunk
        section options[:base] + 4096 + offset, kernel.slice(offset, chunk)
      end

      jump_and_close options[:base]
    end
  end
end