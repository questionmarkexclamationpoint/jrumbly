module Jrumbly
  module Screen
    require 'java'
    require 'jrumbly/bus'
    require 'jrumbly/util/non_editable_model'
    require 'jrumbly/util/util'
    require 'jrumbly/memory/ram'
    require 'jrumbly/processor'
    require 'jrumbly/screen/base'
    require 'jrumbly/util/string'
    
    java_import 'javax.swing.JFrame'
    java_import 'javax.swing.JButton'
    java_import 'javax.swing.JPanel'
    java_import 'javax.swing.JLabel'
    java_import 'javax.swing.JTable'
    java_import 'javax.swing.JTextArea'
    java_import 'javax.swing.JTextField'
    java_import 'javax.swing.JScrollPane'
    java_import 'javax.swing.JOptionPane'
    java_import 'javax.swing.JFileChooser'
    java_import 'java.awt.BorderLayout'
    java_import 'java.awt.FlowLayout'
    java_import 'java.awt.GridBagLayout'
    java_import 'java.awt.GridBagConstraints'
    java_import 'java.awt.event.KeyEvent'
    java_import 'java.awt.event.WindowEvent'
    java_import 'java.awt.Dimension'
    java_import 'java.awt.Color'
    java_import 'java.nio.file.Files'
    java_import 'java.nio.charset.Charset'
    class SwingScreen < Base
      def initialize
        super
        
        @unsaved_changes = false
        
        @window = JFrame.new('jrumbly')
        
        @window.set_layout(BorderLayout.new)
        @window.set_preferred_size(Dimension.new(1200, 675))
        @window.set_default_close_operation(JFrame::DO_NOTHING_ON_CLOSE)
        
        @window.add(generate_main_panel, BorderLayout::CENTER)
        
        @window.add_window_listener do |e|
          if e.get_id == WindowEvent::WINDOW_CLOSING
            if @unsaved_changes
              result = JOptionPane.show_confirm_dialog(@window, 'You have unsaved changes. Are you sure you want to quit?', nil, JOptionPane::YES_NO_OPTION)
              if result == JOptionPane::YES_OPTION
                @window.set_visible(false)
                @window.dispose
              end
            else
              @window.set_visible(false)
              @window.dispose
            end
          end
        end
        
        @window.pack
      end
      def start
        @window.set_visible(true)
        started = !@running
        unless @running
          @running = true
          
          @update_thread = Thread.new { fetch_update }
          @output_thread = Thread.new { fetch_output }
          @input_thread = Thread.new { fetch_input }
        end
        started
      end
      def stop
        stopped = @running
        unless @running
          @running = false
          
          @update_thread.join
          @output_thread.join
          @input_thread.join
        end
        stopped
      end
      def processor=(processor)
        @processor = processor
        refresh_register_display
        refresh_ram_display
      end
      def set_visible(value)
        @window.set_visible(value)
      end
      
      private
      
      def generate_main_panel
        panel = JPanel.new
        panel.set_layout(BorderLayout.new)
        
        panel.add(generate_button_panel, BorderLayout::NORTH)
        panel.add(generate_main_center_panel, BorderLayout::CENTER)
        panel.add(generate_main_right_panel, BorderLayout::EAST)
        
        panel
      end
      def generate_button_panel
        panel = JPanel.new
        panel.set_layout(BorderLayout.new)
        
        panel.add(generate_button_left_panel, BorderLayout::WEST)
        panel.add(generate_button_right_panel, BorderLayout::EAST)
        
        panel
      end
      def generate_button_left_panel
        panel = JPanel.new
        panel.set_layout(FlowLayout.new)
        
        button = JButton.new('Open')
        button.add_action_listener do |e|
          load_file
        end
        panel.add(button)
        
        button = JButton.new('Save')
        button.add_action_listener do |e|
          save_file
        end
        panel.add(button)
        
        panel
      end
      def generate_button_right_panel
        panel = JPanel.new
        panel.set_layout(FlowLayout.new(FlowLayout::TRAILING))
        
        button = JButton.new('Load RAM')
        button.add_action_listener do |e|
          load_ram
        end
        panel.add(button)
        
        button = JButton.new('Reset')
        button.add_action_listener do |e|
          reset
        end
        panel.add(button)
        
        button = JButton.new('Step')
        button.add_action_listener do |e|
          step_processor
        end
        panel.add(button)
        
        button = JButton.new('Run')
        button.add_action_listener do |e|
          run_processor
        end
        panel.add(button)
        
        button = JButton.new('Stop')
        button.add_action_listener do |e|
          stop_processor
        end
        panel.add(button)
        
        panel
      end
      def generate_main_center_panel
        panel = JPanel.new
        panel.set_layout(BorderLayout.new)
        
        panel.add(generate_input_panel, BorderLayout::CENTER)
        panel.add(generate_line_count_panel, BorderLayout::WEST)
        
        panel = JScrollPane.new(panel)
        
        panel
      end
      def generate_line_count_panel
        @line_count_display = JTextArea.new(1, 3)
        @line_count_display.set_enabled(false)
        @line_count_display.set_foreground(Color::BLACK)
        refresh_line_count_display
        
        @line_count_display
      end
      def generate_input_panel
        @input_display = JTextArea.new('HALT 0')
        @input_display.add_key_listener do |e|
          if e.get_id == KeyEvent::KEY_TYPED
            if (e.get_modifiers & KeyEvent::CTRL_MASK) != 0
              if e.get_key_char == 'S'.ord - 64
                save_file
              elsif e.get_key_char == 'O'.ord - 64
                load_file
              end
            end
            @unsaved_changes = true
            refresh_line_count_display
          end
        end
        
        @input_display
      end
      def generate_main_right_panel
        panel = JPanel.new
        panel.set_layout(BorderLayout.new)
        
        panel.add(generate_register_panel, BorderLayout::NORTH)
        panel.add(generate_table_panel, BorderLayout::CENTER)
        panel.add(generate_output_panel, BorderLayout::SOUTH)
        
        panel
      end
      def generate_register_panel
        panel = JPanel.new
        panel.set_layout(GridBagLayout.new)
        
        names = ['H', 'PC', 'IR', 'OR']
        values = {}
        values['H'] = @processor.accumulator.to_s
        values['PC'] = @processor.accumulator.to_s
        values['IR'] = @processor.word.instruction
        values['OR'] = @processor.word.operand.to_s
        
        constraints = GridBagConstraints.new
        constraints.fill = GridBagConstraints::HORIZONTAL
        constraints.weightx = 1
        constraints.weighty = 1
        constraints.gridx = 0
        constraints.gridy = 0
        names.each do |name|
          constraints.gridy = 0
          label = JLabel.new(name)
          panel.add(label, constraints)
          
          constraints.gridy += 1
          field = JTextField.new
          field.set_text(values[name])
          field.set_editable(false)
          case name
          when 'H'
            @accumulator_display = field
          when 'PC'
            @program_counter_display = field
          when 'IR'
            @instruction_display = field
          when 'OR'
            @operand_display = field
          end
          panel.add(field, constraints)
          
          constraints.gridx += 1
        end
        
        panel
      end
      def generate_table_panel
        table = JTable.new
        @ram_display = NonEditableModel.new
        @ram_display.add_column('Address')
        @ram_display.add_column('Instruction')
        @ram_display.add_column('Operand')
        table.set_model(@ram_display)
        
        refresh_ram_display
        
        JScrollPane.new(table)
      end
      def generate_output_panel
        panel = JPanel.new
        panel.set_layout(BorderLayout.new)
        
        label = JLabel.new('Output')
        panel.add(label, BorderLayout::NORTH)
        
        @output_display = JTextArea.new(5, 10)
        @output_display.set_editable(false)
        
        panel.add(JScrollPane.new(@output_display), BorderLayout::CENTER)
        
        panel
      end
      def save_file
        chooser = JFileChooser.new
        result = chooser.show_save_dialog(@window)
        if result == JFileChooser::APPROVE_OPTION
          file = chooser.get_selected_file.to_path.to_string
          file = file.end_with?('.ass') ? file : "#{file}.ass"
          File.open(file, 'w') do |f|
            f.write(@input_display.get_text)
            @unsaved_changes = false
          end
        end
      end
      def load_file
        if @unsaved_changes
          result = JOptionPane.show_confirm_dialog(@window, 'You have unsaved changes. Are you sure you want to load another file?', nil, JOptionPane::YES_NO_OPTION)
          return unless result == JOptionPane::YES_OPTION
        end
        chooser = JFileChooser.new
        result = chooser.show_open_dialog(@window)
        if result == JFileChooser::APPROVE_OPTION
          @input_display.set_text('')
          file = chooser.get_selected_file
          file = file.to_path.to_string
          File.open(file) do |f|
            f.each_line do |line|
              @input_display.append(line)
            end
            @unsaved_changes = false
          end
          reset
        end
      end
      def load_ram
        JOptionPane.show_message_dialog(@window, 'Warning: No HALT detected', 'Warning', JOptionPane::WARNING_MESSAGE) unless
          @input_display.get_text.upcase.include?('HALT')
        @processor.ram.reset
        @processor.reset
        @ram_display.set_value_at(@last_row, @last_row, 0) unless
          @last_row.nil?
        
        i = 0
        begin
          @input_display.get_text.each_line do |line|
            begin
              word = Jrumbly::Util.parse_word(line)
            rescue AssemblyError => e
              JOptionPane.show_message_dialog(@window, e.message, 'Error', JOptionPane::ERROR_MESSAGE)
              @processor.ram.reset
              @processor.reset
            end
            unless word.nil?
              if word.is_a?(Array)
                location, word = word
              else
                location = i
                i += 1
              end
              raise AssemblyError.new('Error: Not enough ram') if
                location >= @processor.ram.size
              JOptionPane.show_message_dialog(@window, 'Warning: Overwriting previous lines', 'Warning', JOptionPane::WARNING_MESSAGE) unless
                @processor.ram[location].instruction == Memory::Word.new.instruction && @processor.ram[location].operand == Memory::Word.new.operand
              @processor.ram[location] = word
            end
          end
        rescue AssemblyError => e
          JOptionPane.show_message_dialog(@window, e.message, 'Error', JOptionPane::ERROR_MESSAGE)
          @processor.ram.reset
          @processor.reset
        end
        
        refresh_register_display
        refresh_ram_display
      end
      def reset
        begin
        @processor.ram.reset
        @processor.reset
        refresh_register_display
        refresh_ram_display
        refresh_line_count_display
        rescue => e
          puts e.message
        end
      end
      def step_processor
        Thread.new do
          unless @processor.word.instruction == 'HALT'
            highlight_active_row
            begin
              @processor.step
            rescue AssemblyError => e
              JOptionPane.show_message_dialog(@window, e.message, 'Error', JOptionPane::ERROR_MESSAGE)
            end
            refresh_register_display
          end
        end
      end
      def run_processor
        @processing = true
        @run_thread = Thread.new do
          while @processing && @processor.word.instruction != 'HALT'
            highlight_active_row
            begin
              @processor.step
            rescue AssemblyError => e
              @processing = false
              JOptionPane.show_message_dialog(@window, e.message, 'Error', JOptionPane::ERROR_MESSAGE)
            end
            refresh_register_display
          end
        end
      end
      def stop_processor
        @processing = false
        @run_thread.join
      end
      def refresh_register_display
        @accumulator_display.set_text(@processor.accumulator.to_s)
        @program_counter_display.set_text(@processor.program_counter.to_s)
        @instruction_display.set_text(@processor.word.instruction.to_s)
        @operand_display.set_text(@processor.word.operand.to_s)
      end
      def refresh_ram_display
        i = 0
        grown = @ram_display.get_row_count < @processor.ram.size
        shrunk = @processor.ram.size < @ram_display.get_row_count
        less = grown ? @ram_display.get_row_count : @processor.ram.size
        more = grown ? @processor.ram.size : @ram_display.get_row_count
        (0..(less - 1)).each do |i|
          @ram_display.set_value_at(@processor.ram[i].instruction, i, 1)
          @ram_display.set_value_at(@processor.ram[i].operand.to_s, i, 2)
        end
        if grown
          (@ram_display.get_row_count..(@processor.ram.size - 1)).each do |i|
            @ram_display.add_row([i.to_s, @processor.ram[i].instruction, @processor.ram[i].operand.to_s].to_java)
          end
        elsif shrunk
          (@processor.ram.size..(@ram_display.get_row_count - 1)).each do |i|
            @ram_display.remove_row(@processor.ram.size)
          end
        end
        @ram_display.set_value_at(@last_row, @last_row, 0) unless
          @last_row.nil?
        @ram_display.fire_table_data_changed
      end
      def refresh_line_count_display
        i = 0
        @line_count_display.set_text('')
        @input_display.get_text.each_line do |line|
          if Util.valid_word?(line)
            @line_count_display.append("#{i < 10 ? 0 : ''}#{i}>\r\n")
            i += 1
          elsif line.strip == '' || line.start_with?('//')
            @line_count_display.append("\r\n")
          else
            @line_count_display.append(">!<\r\n")
          end
        end
      end
      def highlight_active_row
        @ram_display.set_value_at(@last_row, @last_row, 0) unless
          @last_row.nil?
        @last_row = @processor.program_counter
        @ram_display.set_value_at(">>>#{@processor.program_counter}", @processor.program_counter, 0)
        
        @ram_display.fire_table_rows_updated(@processor.program_counter, @processor.program_counter)
      end
      def fetch_output
        while @running
          value = @processor.output.pop
          @output_display.append("#{value}\r\n")
        end
      end
      def fetch_update
        while @running
          value = @processor.update.pop
          @ram_display.set_value_at(@processor.ram[value].instruction, value, 1)
          @ram_display.set_value_at(@processor.ram[value].operand.to_s, value, 2)
          @ram_display.fire_table_rows_updated(value, value)
        end
      end
      def fetch_input
        while @running
          value = @processor.input.pop_in
          result = JOptionPane.show_input_dialog('Please input an integer:')
          until result.is_i?
            result = JOptionPane.show_input_dialog('Please input an integer:')
          end
          result = Memory::Word.new('DATA', result.to_i)
          @processor.input.push_out(result)
        end
      end
    end
  end
end
