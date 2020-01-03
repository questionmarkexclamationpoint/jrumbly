module Jrumbly
  module Memory
    class Word
      require 'jrumbly/memory/instructions'
      attr_accessor :instruction, :operand
      def initialize(instruction = nil, operand = nil)
        raise ArgumentError.new unless
          INSTRUCTIONS.include?(instruction) || instruction.nil?
        raise ArgumentError.new unless
          operand.is_a?(Integer) || operand.nil?
        @instruction = instruction.nil? ? 'DATA' : instruction
        @operand = operand.nil? ? 0 : operand
      end
    end
  end
end
