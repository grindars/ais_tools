module AisTools
  class Formatter
    def convert(ais, &section_writer)
      string = ""

      ais.instructions.each do |insn|
        args = []

        insn.parameters.each do |name, type|
          value = insn.send(name)

          case type
          when :pointer
            args << sprintf("0x%08X", value)

          when :number
            args << value.to_s

          when :range
            args << value.to_s

          when :file
            args << section_writer.call(value).inspect

          when :ptrlist
            args.concat value.map { |value| sprintf("0x%08X", value) }

          else
            raise "unknown argument type: #{type} in #{insn.class.name}, #{name}"
          end
        end

        string << "#{insn.name} #{args.join ", "}\n"
      end

      string
    end
  end
end