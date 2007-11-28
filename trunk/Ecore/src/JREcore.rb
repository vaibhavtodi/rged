#!/opt/local/shar/jruby-1.0.2/bin/jruby

require 'java'
require File.dirname(__FILE__) + '/../lib/org.eclipse.emf.ecore_2.3.1.v200709252135.jar'
require File.dirname(__FILE__) + '/../lib/org.eclipse.emf.common_2.3.0.v200709252135.jar'
require File.dirname(__FILE__) + '/../lib/org.eclipse.emf.ecore.xmi_2.3.1.v200709252135.jar'
require File.dirname(__FILE__) + '/../lib/java.ecore.importer.jar'

include_class 'JavaEcoreImporter'

#include_class java.io.IOException;
#include_class java.util.HashMap;
#include_class java.util.Iterator;

#include_class org.eclipse.emf.common.util.BasicEList;
#include_class org.eclipse.emf.common.util.EList;
#include_class org.eclipse.emf.common.util.TreeIterator;
#include_class org.eclipse.emf.common.util.URI;
#include_class org.eclipse.emf.ecore.EClass;
#include_class org.eclipse.emf.ecore.EObject;
#include_class org.eclipse.emf.ecore.EPackage;
#include_class org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl;


class JREcoreImporter <  JavaEcoreImporter

#  def initializer
#  end

end

lol = JREcoreImporter.new
lol.load(File.dirname(__FILE__) + '/../ecore_example/test.ecore')
lol.parse_package()
lol.parse_all()
lol.parse_class(lol.getEhp.values().iterator().next().getName(), 0)
