# Goldspike configuration

# Set the version of JRuby and GoldSpike to use:
#maven_library 'org.jruby', 'jruby-complete', '1.0'
#maven_library 'org.jruby.extras', 'goldspike', '1.3-SNAPSHOT'

# Add a Java library from the Maven repository:
puts "war 1"
maven_library 'mysql', 'mysql-connector-java', '5.0.4'
puts "war 2"
add_gem 'gettext'
puts "war 3"
add_gem 'rubyzip'
puts "war 4"
