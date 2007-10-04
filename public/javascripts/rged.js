// set blank image to local file
Ext.BLANK_IMAGE_URL = '/javascripts/extjs/resources/images/default/s.gif';

var Rged = function() {
    // All Panel
    this.northPanel = null;
    this.westPanel = null;
    this.centerPanel = null;
    this.menu = null;
    this.tree = null;
    this.grid = null;
    this.textBox = null;
    this.ds = null;
    
    }
    
Rged.prototype =  {
    path: '',
    
    // Initialize the Tree
    init_tree: function() {
                   
           // tree in the panel
           
	this.tree = new Ext.ux.FileTreePanel('tree', {
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
        //tree = new Ext.Rged.TreeFile ('tree', {readOnly: false});
	
	// {{{
	var root = new Ext.tree.AsyncTreeNode({text:'/', path: this.path, id: '/', allowDrag:false});
	this.tree.setRootNode(root);
	this.tree.render();
        this.tree.on('click', this.tree_onClick, this);
	root.expand();
    },
    
    tree_onClick: function (node, elt) {
        var path = '';
        if (node.isLeaf())
            path = this.tree.getPath(node.parentNode);
        else
            path = this.tree.getPath(node);
        this.load_path(path);
        node.select ();
    },
    
    // When the user press the key enter
    menu_onSpecialKey: function(field, e) {
       if (e.getKey() == e.ENTER) {
           var path = field.getValue ()
           this.load_path(path);
       }
    },
    
    // When the TextBox in the menu change
    menu_onChange: function(field, newval, oldval) {
       this.load_path(newval);
    },

    // Initialize the menu
    init_menu: function () {
                   
       this.menu = new Ext.Toolbar('menu');
       this.menu.addButton({
           text: 'Rename', cls: 'x-btn-text-icon scroll-bottom', handler: function(o, e) {
              
           }
       });
       this.menu.addButton({
           text: 'Delete', cls: 'x-btn-text-icon scroll-top', handler: function(o, e) {
               
           }
       });
       this.textBox = new Ext.form.TextField ({cls : 'rged-adress', width: 500});
       this.textBox.on('change', this.menu_onChange, this);
       this.textBox.on('specialkey', this.menu_onSpecialKey, this);
       this.menu.addField(this.textBox);
       this.menu.addFill ();
       this.menu.addButton({
           text: 'Logout', cls: 'x-btn-text-icon logout', handler: function(o, e) {
               window.location = '/account/logout/';
           }
       });
    },
    
    // Initilize the global layout
    init_layout: function () {
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
                resizeTabs: true
            }
        });
        mainLayout.beginUpdate();
        mainLayout.add('north', this.northPanel = new Ext.ContentPanel('menu', { 
            fitToFrame: true, closable: false 
        }));
        mainLayout.add('west', this.westPanel = new Ext.ContentPanel('tree', { 
            fitToFrame: true, closable: false, title: 'Folders'
        }));
        mainLayout.add('center', this.centerPanel = new Ext.ContentPanel('grid', { 
            fitToFrame: true, autoScroll: true, resizeEl: this.grid, title: 'Files'
        })); 
        mainLayout.endUpdate();
        
    },
    
    // Initilize the Grid view
    init_grid: function () {
            // Grid Data Store
        this.ds = new Ext.data.Store({
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
                {name: 'lastChange', mapping: 'lastChange', type: 'date', dateFormat: 'D M  j h:i:s Y'}
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
        
        // Display the icon for file type
        function icon(val){
            if (val == 'folder')
                return '<img width="16" height="18" class="folder" src="/javascripts/extjs/resources/images/default/tree/folder.gif"/>';
            else
                return '<img width="16" height="18" src="/javascripts/extjs/resources/images/default/tree/leaf.gif"/>';
        }
	// Column Model of the grid
        var colModel = new Ext.grid.ColumnModel([
                        {id: 'icon', header: '<img src="/images/icons/arrow_up.png" width="16" height="18"/>', width: 25, sortable: false, renderer: icon, dataIndex: 'cls', fixed : true},
			{id:'name',header: "Name", width: 160, sortable: true, locked:false, dataIndex: 'name'
                            , editor: new Ext.grid.GridEditor(new Ext.form.TextField({
                                allowBlank: false}))},
			{header: "Size", width: 75, sortable: true, renderer: size, dataIndex: 'size'},
                        {header: "Last Updated", width: 85, sortable: true, renderer: Ext.util.Format.dateRenderer('m/d/Y'), dataIndex: 'lastChange'}
		]);


        // create the Grid
        this.grid = new Ext.grid.Grid('grid', {
            ds: this.ds,
            cm: colModel,
            enableDragDrop : true,
            ddGroup: 'TreeDD',
            autoExpandColumn: 'name'
        });
        
        this.grid.render();
        this.grid.on('celldblclick', this.grid_onCellClick, this);
        this.grid.on('cellcontextmenu', this.grid_onCellContextMenu, this);
        this.grid.on('headerdblclick', this.grid_onHeaderClick, this);
    
    },
    
    //When the user click on the arrox up in the first column
    grid_onHeaderClick: function( grid, columnIndex, e ) 
    {
        if (grid.getColumnModel().getColumnId(columnIndex) == 'icon') {
            var pos = this.path.lastIndexOf('/');
            if (pos >= 0) {
                var path = this.path.substr(0, pos);                
                this.load_path(path);
            }
        }
    },
    
    // On right click
    grid_onCellContextMenu: function( grid, rowIndex, columnIndex, e ) 
    {
        //Do Context menu
    },
    
    grid_onCellClick: function( grid, rowIndex, columnIndex, e ) 
    {
        var rec = grid.getDataSource().getAt(rowIndex);
        var path = rec.get('path');
        var folder = rec.get('cls');
        if (folder == 'folder') {
            /*this.ds.load ({params: {path : path}});  
            this.textBox.setValue(path);*/
            this.load_path(path);
        }
        this.tree.expandPath(path, 'text', function (success, node) { if (success) node.select()});
        /*var node = this.tree.getNodeById(path);
        if (node) {
            this.tree.getSelectionModel().select(node);
            node.expand ();
        }*/
    },
    
    init_history: function () {
        var bookmarkedSection = Ext.ux.History.getBookmarkedState( "dir" );
        var init = bookmarkedSection || '/';
       
        Ext.ux.History.register( "dir", init, function( state ) {
        // This is called after calling YAHOO.util.History.navigate, or after the user
        // has trigerred the back/forward button. We cannot discrminate between
        // these two situations.
            var cur = Ext.ux.History.getCurrentState ("dir");
            if (cur != state)
                this.load_path (state, true);
        }, this, true );
        
        Ext.ux.History.initialize();
        this.load_path (init, true);
    },
    
    init : function() {
       Ext.QuickTips.init();
       
       this.init_tree();
       this.init_menu ();
       this.init_layout ();
       this.init_grid ();
       //this.init_history ();
       this.load_path (init);
    },

    load_path : function (path, change) {
        if (this.path != path) {
            if (path == '')
                path = '/';
            this.path = path;
            this.ds.load ({params: {path: path}});
            this.textBox.setValue(path);
            this.tree.expandPath(path, 'text', function (success, node) { if (success) node.select()});
            if (!change)
                Ext.ux.History.navigate( "dir", path );
        }
    }
};

Ext.onReady(function() {
    var rged = new Rged ();
    rged.init ();
});

