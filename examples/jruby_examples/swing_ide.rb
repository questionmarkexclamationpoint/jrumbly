require 'jrumbly'

computer = Jrumbly::Computer.new
computer.ram = Jrumbly::Memory::Ram.new(100)
computer.screen = Jrumbly::Screen::SwingScreen.new


computer.start
