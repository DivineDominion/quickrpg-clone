require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  require 'rspec'
    
  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus
    config.order = 'random'
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  
  lib_folder = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
  Dir["#{lib_folder}/**/*.rb"].each do |file|
    puts file
    require file
  end
end
