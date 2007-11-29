#!/opt/local/shar/jruby-1.0.2/bin/jruby

require 'java'
require File.dirname(__FILE__) + '/../lib/org.eclipse.emf.ecore_2.3.1.v200709252135.jar'
require File.dirname(__FILE__) + '/../lib/org.eclipse.emf.common_2.3.0.v200709252135.jar'
require File.dirname(__FILE__) + '/../lib/org.eclipse.emf.ecore.xmi_2.3.1.v200709252135.jar'
require File.dirname(__FILE__) + '/../lib/java.ecore.importer.jar'

include_class 'JavaEcoreImporter'

class JREcoreImporter <  JavaEcoreImporter

#  def initializer
#  end

end

lol = JREcoreImporter.new
lol.load(File.dirname(__FILE__) + '/../ecore_example/test.ecore')
lol.parse_package()
lol.parse_all()
lol.parse_class(lol.getEhp.values().iterator().next().getName(), 0)
