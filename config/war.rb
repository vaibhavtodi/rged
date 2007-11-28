# Goldspike configuration

# Set the version of JRuby and GoldSpike to use:
maven_library 'org.jruby', 'jruby-complete', '1.0.1'
#maven_library 'org.jruby.extras', 'goldspike', '1.3-SNAPSHOT'

# Add a Java library from the Maven repository:
maven_library 'mysql', 'mysql-connector-java', '5.1.5'
add_gem 'gettext'
add_gem 'rubyzip'
add_gem 'jruby-openssl'
#add_gem 'slave'

