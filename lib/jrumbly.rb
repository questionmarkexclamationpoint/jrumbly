module Jrumbly
  VERSION = '0.0.1'
  
  require 'jrumbly/bus'
  require 'jrumbly/computer'
  require 'jrumbly/processor'
  require 'jrumbly/memory/ram'
  require 'jrumbly/memory/word'
  require 'jrumbly/memory/instructions'
  require 'jrumbly/screen/base'
  require 'jrumbly/screen/console_screen'
  require 'jrumbly/screen/shoes_screen'
  require 'jrumbly/screen/swing_screen'
  
  class AssemblyWarning < Exception
  end
  
  class AssemblyError < Exception
  end
end
