module Jrumbly
  module Util
    require 'jrumbly/util/string'
    def self.valid_word?(string)
      begin
        value = self.parse_word(string)
        !value.nil?
      rescue AssemblyError
        false
      end
    end
    def self.parse_word(string)
      if string.strip == '' || string.strip.start_with?('//')
        nil
      else
        values = string.partition('//')[0]
        values = values.strip.partition(' ')
        #raise assembly error if values[2].nil?
        instruction = values[0].strip.upcase
        operand = values[2].strip.to_i
        begin
          if instruction.is_i?
            [instruction.to_i, Jrumbly::Memory::Word.new('DATA', operand)]
          else
            Jrumbly::Memory::Word.new(instruction, operand)
          end
        rescue ArgumentError
          raise AssemblyError.new('Error: Malformed line')
        end
      end
    end
  end
end
