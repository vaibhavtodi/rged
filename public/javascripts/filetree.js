// vim: ts=2:sw=2:nu:fdc=4:nospell
/**
	* Ext.ux.InfoPanel and Ext.ux.Accordion Example Application
	*
	* @author  Ing. Jozef Sakalos
	* @version $Id: filetree.js 73 2007-07-27 10:32:06Z jozo $
	*
	*/

// set blank image to local file
Ext.BLANK_IMAGE_URL = '/javascripts/extjs/resources/images/default/s.gif';

// run this function when document becomes ready
Ext.onReady(function() {

	Ext.QuickTips.init();

	// tree in the panel
	var tree = new Ext.ux.FileTreePanel('panel-tree', {
		animate: true
		, dataUrl: '/file/list/'
		, readOnly: false
		, containerScroll: true
		, enableDD: true
		, enableUpload: true
		, enableRename: true
		, enableDelete: true
		, enableNewDir: true
		, uploadPosition: 'menu'
		, edit: true
		, sort: true
		, maxFileSize: 1048575
		, hrefPrefix: '/filetree/'
		, pgCfg: {
			uploadIdName: 'UPLOAD_IDENTIFIER'
			, uploadIdValue: 'auto'
			, progressBar: false
			, progressTarget: 'qtip'
			, maxPgErrors: 10
			, interval: 1000
			, options: {
				url: '../uploadform/progress.php'
				, method: 'post'
			}
		}
	});
	
	// {{{
	var root = new Ext.tree.AsyncTreeNode({text:'Tree Root', path:'root', allowDrag:false});
	tree.setRootNode(root);
	tree.render();
	root.expand();
	//tree.on('click', function(tree, node, oldname, newname) {debugger;return false});
//	tree.setReadOnly(true);
//	tree.setReadOnly(false);
	// }}}

}) // end of onReady

// end of file
