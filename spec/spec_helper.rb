require 'rubygems'
require 'spork'

# Add spec/ to LOAD_PATH manually because guard/spork fired it :(
$:.unshift(File.expand_path(__dir__))

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

lib_folder = File.expand_path(File.join(__dir__, '..', 'lib'))
spec_folder = File.expand_path(__dir__)

Spork.each_run do
  Dir["#{lib_folder}/**/*.rb"].each { |f| require f }
  Dir["#{spec_folder}/support/**/*.rb"].sort.each { |f| require f }
end
