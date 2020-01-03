require 'jrumbly'

computer = Jrumbly::Computer.new
computer.ram = Jrumbly::Memory::Ram.new(100)
computer.screen = Jrumbly::Screen::ConsoleScreen.new

if ARGV.length != 1
  raise ArgumentError.new
else
  File.open(ARGV[0]) do |file|
    file.each_line do |line|
      computer.screen.load_line(line)
    end
  end
  computer.start
  sleep(1) while computer.processor.running
end

