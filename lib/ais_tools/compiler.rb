module AisTools
  class Compiler
    class InstructionBuilder
      def self.loader(meth, mod)
        class_eval <<-EOF
          def #{meth}(name)
            klass = name.capitalize
            raise "unsupported #{meth} \#{name}" unless AisTools::#{mod}.const_defined?(klass)
            instance_eval "class << self; include AisTools::#{mod}::\#{klass}; end"
            nil
          end
        EOF
      end

      attr_reader :instructions, :target

      loader "cpu",     "CPU"
      loader "feature", "Features"

      def initialize(target)
        @instructions = []
        @target = target
      end

      def self.evaluate(target, source)
        builder = self.new(target)

        builder.instance_eval source

        builder.instructions
      end

      def method_missing(name, *args, &block)
        if Instruction.instruction_defined?(name)
          insn = Instruction.create_by_name(name)

          insn.parameters.each do |name, type|
            case type
            when :pointer, :number
              raise "not enough arguments" if args.empty?
              value = args.shift
              raise "integer expected for #{name}" unless value.kind_of? Integer

            when :range
              raise "not enough arguments" if args.empty?
              value = args.shift
              raise "range expected for #{name}" unless value.kind_of? Range

            when :file
              raise "not enough arguments" if args.empty?
              value = args.shift
              raise "string expected for #{name}" unless value.kind_of? String

            when :ptrlist
              args.each do |arg|
                raise "integer expected" unless arg.kind_of? Integer
              end

              value = args
              args = []

            else
              raise "unknown parameter type #{type}"
            end

            insn.send "#{name}=", value
          end

          @instructions << insn

          nil
        else
          super
        end
      end

      def respond_to?(name)
        super || Instruction.instruction_defined?(name)
      end
    end

    def compile(target, source)
      binary = Binary.new

      binary.instructions = InstructionBuilder.evaluate(target, source)

      binary
    end
  end
end
