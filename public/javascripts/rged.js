function getIframeDocument(el) {
    var oIframe = Ext.get('center-iframe').dom;
    var oDoc = oIframe.contentWindow || oIframe.contentDocument;
    if(oDoc.document) {
        oDoc = oDoc.document;
    }
    return oDoc;
}

// set blank image to local file
Ext.BLANK_IMAGE_URL = '/javascripts/extjs/resources/images/default/s.gif';

var Rged= function() {
    var northPanel, southPanel, eastPanel, westPanel, centerPanel;
    return {
        init : function() {
           Ext.QuickTips.init();
           
           // tree in the panel
	var tree = new Ext.ux.FileTreePanel('tree', {
		animate: true
//		, dataUrl: 'filetree.php'
		, readOnly: false
		, containerScroll: true
		, enableDD: true
		, enableUpload: true
		, enableRename: true
		, enableDelete: true
		, enableNewDir: true
		, uploadPosition: 'menu'
//		, edit: true
//		, sort: true
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
	var root = new Ext.tree.TreeNode({text:'/', path:'root', allowDrag:false});
	tree.setRootNode(root);
	tree.render();
	root.expand();
//	tree.on('beforerename', function(tree, node, oldname, newname) {debugger;return false});
//	tree.setReadOnly(true);
//	tree.setReadOnly(false);
	// }}}
            
           var menu= new Ext.Toolbar('menu');
           menu.addButton({
               text: 'Rename', cls: 'x-btn-text-icon scroll-bottom', handler: function(o, e) {
                   var iframeDoc = getIframeDocument('center-iframe');
                   iframeDoc.body.scrollTop = iframeDoc.body.scrollHeight;
               }
           });
           menu.addButton({
               text: 'Delete', cls: 'x-btn-text-icon scroll-top', handler: function(o, e) {
                   var iframeDoc = getIframeDocument('center-iframe');
                   iframeDoc.body.scrollTop = 0;
               }
           });
           var mainLayout = new Ext.BorderLayout(document.body, {
                north: {
                    split:false,
                    initialSize: 32,
                    titlebar: false
                },
                west: {
                    split:true,
                    initialSize: 250,
                    minSize: 175,
                    maxSize: 400,
                    titlebar: true,
                    collapsible: true,
                    animate: true,
                    useShim:true,
                    cmargins: {top:2,bottom:2,right:2,left:2}
                },
                center: {
                    titlebar: true,
                    title: 'Files',
                    autoScroll:false,
                    tabPosition: 'top',
                    closeOnTab: true,
                    //alwaysShowTabs: true,
                    resizeTabs: true
                }
            });
            mainLayout.beginUpdate();
            mainLayout.add('north', northPanel = new Ext.ContentPanel('menu', { 
                fitToFrame: true, closable: false 
            }));
            mainLayout.add('west', westPanel = new Ext.ContentPanel('tree', { 
                fitToFrame: true, closable: false, title: 'Folders'
            }));
            mainLayout.add('center', centerPanel = new Ext.ContentPanel('grid', { 
                fitToFrame: true, autoScroll: true, resizeEl: grid, title: 'Files'
            })); 
            mainLayout.endUpdate();
            //northPanel.setContent('This panel will be used for a header');
       
        ds = new Ext.data.Store({
            proxy: new Ext.data.HttpProxy({url: '/directory/list'}),
            reader: new Ext.data.JsonReader({
                root: 'Files',
                totalProperty: 'FilesCount',
                id: 'id'
            }, [
                {name: 'name', mapping: 'name'},
                {name: 'size', mapping: 'size', type: 'int'},
                {name: 'lastChange', mapping: 'lastChange', type: 'date', dateFormat: 'Y-m-d'}
            ])
        });
		// example of custom renderer function
        function size(val){
            if(val < 1024){
                return Math.round( val) + ' o';
            } else  {
                val = Math.round( val / 1024);
                if(val < 1024){
                return val + ' ko';
                }
                else {
                    val = Math.round( val / 1024);
                    if(val < 1024){
                        return val + ' mo';
                    }
                    else {
                        return Math.round( val / 1024) + ' go';
                    }
                }
            }
            return val;
        }
		// the DefaultColumnModel expects this blob to define columns. It can be extended to provide
        // custom or reusable ColumnModels
        var colModel = new Ext.grid.ColumnModel([
			{id:'name',header: "Name", width: 160, sortable: true, locked:false, dataIndex: 'name'},
			{header: "Size", width: 75, sortable: true, renderer: size, dataIndex: 'size'},
			{header: "Last Updated", width: 85, sortable: true, renderer: Ext.util.Format.dateRenderer('m/d/Y'), dataIndex: 'lastChange'}
		]);


        // create the Grid
        var grid = new Ext.grid.Grid('grid', {
            ds: ds,
            cm: colModel,
            enableDragDrop : true,
            autoExpandColumn: 'name'
        });
        
        grid.render();
        ds.load ({params: {dir : '/home/patou'}});

        grid.getSelectionModel().selectFirstRow();
        Ext.get('center-iframe').dom.src = 'http://www.google.fr';
        }
    };
}();
Ext.EventManager.onDocumentReady(Rged.init, Rged, true);
