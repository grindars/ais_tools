module AisTools
  class Instruction
    class << self
      def create_by_opcode(word)
        klass = nil
        klass = Instruction.instruction_opcodes[word]

        raise "undefined opcode #{word.to_s 16}" if klass.nil?

        klass.new
      end

      def create_by_name(name)
        klass = nil
        klass = Instruction.instruction_names[name.to_s]

        raise "undefined instruction #{name}" if klass.nil?

        klass.new
      end 

      def instruction_defined?(name)
        Instruction.instruction_names.include? name.to_s
      end

      def declare(opcode, name, parameters)
        Instruction.instruction_opcodes[opcode] = self
        Instruction.instruction_names[name] = self

        @instruction_opcode = opcode
        @instruction_name = name
        @instruction_parameters = parameters
      end

      def instruction_opcodes
        @instruction_opcodes ||= {}
      end

      def instruction_names
        @instruction_names ||= {}
      end
    end

    def opcode
      self.class.instance_variable_get :@instruction_opcode
    end

    def name
      self.class.instance_variable_get :@instruction_name
    end

    def parameters
      self.class.instance_variable_get :@instruction_parameters
    end
  end
end