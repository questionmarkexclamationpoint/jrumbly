# jrumbly
### About
jrumbly is meant to be used to build simple assembly interpreters and IDEs.
### Use
Make sure you have jruby installed:
```bash
rvm install jruby
rvm use jruby
```
Install the gem:
```bash
gem build jrumbly.gemspec
gem install jrumbly-*.gem
```
Just require the gem, and you're good to go:
```ruby
require 'jrumbly'
```
### Testing
Currently, the only working example of jrumbly is located in `lib/examples/jruby_examples/swing_ide.rb`.
You can view the source for this example, or run it using `ruby lib/examples/jruby_examples/swing_ide.rb`.
