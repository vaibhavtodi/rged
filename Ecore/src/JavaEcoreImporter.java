import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;

import org.eclipse.emf.common.util.BasicEList;
import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.common.util.TreeIterator;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EClass;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EPackage;
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl;

public class JavaEcoreImporter {
	
	protected EList<EObject> el;
	protected HashMap<String, EPackage> ehp = new HashMap<String, EPackage>();
	protected HashMap<String, EList<EClass>> ehc = new HashMap<String, EList<EClass>>();
	
	public void load (java.lang.String ecore_file_name) {		
		try {
			URI aURI=URI.createFileURI(ecore_file_name); 
			XMIResourceImpl resource = new XMIResourceImpl(aURI); 
			resource.load(null);
			this.setEl(resource.getContents());
			TreeIterator<EObject> te = resource.getAllContents();	
			do {
				EObject tmp = te.next();				
				if (tmp.getClass().getSimpleName().indexOf("EClass") >= 0)
				{
					EClass tmp_c = (EClass) tmp;
					String tmp_hashcode = tmp_c.getEPackage().getName();
					if (this.ehc.get(tmp_hashcode) == null)
					{					
						EList<EClass> el = new BasicEList<EClass>();
						el.add((EClass) tmp);
						this.ehc.put(tmp_hashcode, el);
					}
					else
					{
						this.ehc.get(tmp_hashcode).add((EClass) tmp);
					}
				}
				if (tmp.getClass().getSimpleName().indexOf("EPackage") >= 0)
				{
					EPackage tmp_p = (EPackage) tmp;
					String tmp_hashcode = tmp_p.getName();
					this.ehp.put(tmp_hashcode, tmp_p);
				}				
				
			} while (te.hasNext());
			


		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}	
	}
	
	private void print_tab(int nb)
	{
		for (int i = 0; i <= nb; i++) {
			System.out.print("\t");
		}
	}
	
	public void parse_class (String package_name, int i_c)
	{
		EList<EClass> type_lc = ehc.get(package_name);
		for (Iterator iterator2 = type_lc.iterator(); iterator2.hasNext();) {
			EClass class1 = (EClass) iterator2.next();
			this.print_tab(i_c);
			System.out.println("Eclass: " + class1.getName());
		}
	}
	
	public void parse_package ()
	{
		int i_p = 0;
		for (Iterator iterator = ehp.values().iterator(); iterator.hasNext();) {
			EPackage type = (EPackage) iterator.next();
			this.print_tab(i_p);
			System.out.println("Package: " + type.getName());
			i_p++;
		}
	}
	
	public void parse_all ()
	{
		int i_p = 0;
		for (Iterator iterator = ehp.values().iterator(); iterator.hasNext();) {
			EPackage type = (EPackage) iterator.next();
			this.print_tab(i_p);
			System.out.println("Package: " + type.getName());
			String package_name = type.getName();
			this.parse_class(package_name, i_p + 1);
		}
	}

	public EList<EObject> getEl() {
		return el;
	}

	public void setEl(EList<EObject> el) {
		this.el = el;
	}

	public HashMap<String, EPackage> getEhp() {
		return ehp;
	}

	public void setEhp(HashMap<String, EPackage> ehp) {
		this.ehp = ehp;
	}

	public HashMap<String, EList<EClass>> getEhc() {
		return ehc;
	}

	public void setEhc(HashMap<String, EList<EClass>> ehc) {
		this.ehc = ehc;
	}
	

}
