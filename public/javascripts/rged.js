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
    // All Panel
    var northPanel, westPanel, centerPanel;
    var menu;
    var tree;
    var grid;
    var textBox;
    
    function init_tree () {
                   
           // tree in the panel
	tree = new Ext.ux.FileTreePanel('tree', {
		animate: true
		, dataUrl: '/directory/get'
                , renameUrl: '/directory/rename'
                , deleteUrl: '/directory/delete'
                , newdirUrl: '/directory/newdir'
                , iconPath: '../images/icons/'
		, readOnly: false
		, containerScroll: true
		, enableDD: true
                , ddGroup: 'TreeDD'
		, enableUpload: true
		, enableRename: true
		, enableDelete: true
		, enableNewDir: true
		, uploadPosition: 'menu'
		, edit: true
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
	var root = new Ext.tree.AsyncTreeNode({text:'/', path:'/', allowDrag:false});
	tree.setRootNode(root);
	tree.render();
        tree.on('click', function(node, elt) {
                var path = '';
                if (node.isLeaf())
                    path = tree.getPath(node.parentNode);
                else
                    path = tree.getPath(node);
                textBox.setValue(path);
                ds.load({params: {path: path}});
            });
	root.expand();
    }
    
    function init_menu () {
                   
       menu = new Ext.Toolbar('menu');
       menu.addButton({
           text: 'Rename', cls: 'x-btn-text-icon scroll-bottom', handler: function(o, e) {
              
           }
       });
       menu.addButton({
           text: 'Delete', cls: 'x-btn-text-icon scroll-top', handler: function(o, e) {
               
           }
       });
       textBox = new Ext.form.TextField ({cls : 'rged-adress', width: 500});
       textBox.on('change', function(field, newval, oldval) {
           ds.load ({params: {path : newval}});
           var node = tree.getNodeById(newval);
                if (node) {
                    tree.getSelectionModel().select(node);
                    node.expand ();
                }
           });
       textBox.on('specialkey', function(field, e) {
           if (e.getKey() == e.ENTER) {
               var path = field.getValue ()
                ds.load ({params: {path : path}});
                var node = tree.getNodeById(path);
                if (node) {
                    tree.getSelectionModel().select(node);
                    node.expand ();
                }
           }
           });
       menu.addField(textBox);
       menu.addFill ();
       menu.addButton({
           text: 'Logout', cls: 'x-btn-text-icon logout', handler: function(o, e) {
               window.location = '/account/logout/';
           }
       });
    }
    
    function init_layout () {
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
        
    }
    
    function init_grid () {
            // Grid Data Store
        ds = new Ext.data.Store({
            proxy: new Ext.data.HttpProxy({url: '/directory/list'}),
            reader: new Ext.data.JsonReader({
                root: 'Files',
                totalProperty: 'FilesCount',
                id: 'path'
            }, [
                {name: 'name', mapping: 'name'},
                {name: 'path', mapping: 'path'},
                {name: 'cls', mapping: 'cls'},
                {name: 'size', mapping: 'size', type: 'int'},
                {name: 'lastChange', mapping: 'lastChange', type: 'date', dateFormat: 'Y-m-d'}
            ])
        });
	
        // Convert a file size in Kilo/Mega/Giga Octet
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
        
        function icon(val){
            return '<img class="x-tree-node-icon' + val + '" width="16" height="18" src="/javascripts/extjs/resources/images/default/s.gif"/>';
        }
	// Column Model of the grid
        var colModel = new Ext.grid.ColumnModel([
                        {id: 'icon', header: '<img src="/images/icons/arrow_up.png" width="16" height="18"/>', width: 20, sortable: false, renderer: icon, dataIndex: 'cls', fixed : true},
			{id:'name',header: "Name", width: 160, sortable: true, locked:false, dataIndex: 'name'
                            , editor: new Ext.grid.GridEditor(new Ext.form.TextField({
                                allowBlank: false}))},
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
        grid.on('cellclick', function( grid, rowIndex, columnIndex, e ) 
            {
                var rec = grid.getDataSource().getAt(rowIndex);
                var path = rec.get('path');
                var folder = rec.get('cls');
                if (folder == 'folder') {
                    ds.load ({params: {path : path}});  
                    textBox.setValue(path);
                }
                var node = tree.getNodeById(path);
                if (node) {
                    tree.getSelectionModel().select(node);
                    node.expand ();
                }
            });
        grid.on('cellcontextmenu', function( grid, rowIndex, columnIndex, e ) 
            {
                //Do Context menu
            });
        grid.on('headerclick', function( grid, columnIndex, e ) 
        {

            if (grid.getColumnModel().getColumnId(columnIndex) == 'icon') {
                var path = textBox.getValue();
                ds.load ({params: {path : path + '/../'}});
                textBox.setValue(path);
            }
        });
    
    }
    
    return {
        init : function() {
           Ext.QuickTips.init();
           
           init_tree();
           init_menu ();
           init_layout ();
           init_grid ();
           this.load_path ('./');
        },
        
        load_path : function (path) {
           ds.load ({params: {path: path}});
           textBox.setValue(path);
        }
    };
}();
Ext.EventManager.onDocumentReady(Rged.init, Rged, true);
