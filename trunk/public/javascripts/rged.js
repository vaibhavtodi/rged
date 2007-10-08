// set blank image to local file
Ext.BLANK_IMAGE_URL = '/javascripts/extjs/resources/images/default/s.gif';

Ext.override(Ext.grid.Grid, {
        getDragDropText: function(){
            var sel = this.selModel.getSelected();
            if (sel)
                return sel.get('name');
            else
                return 'No selected row';
        }
    });

Ext.override(Ext.ux.FileTreePanel, {
	onNodeDragOver: function(e) {
             if(e.target.disabled || e.dropNode && e.dropNode.parentNode === e.target.parentNode && e.target.isLeaf()) {
                e.cancel = true;
             }
        },
        onBeforeNodeDrop: function (e) {
            var s = e.dropNode;
            var d = e.target.leaf ? e.target.parentNode : e.target;
            var oldName = '';
            var newName = '';
            if (!s) {
                var elt = e.data.selections[0];
                s = this.getNodeById(elt.id);
                e.dropNode = s;
            }
            if (s) {
                if (s.parentNode === d) {
                    return false;
                }
                if (this.hasChild(d, s.text) && !e.confirmed) {
                    this.confirmOverwrite(s.text, function () {e.confirmed = true;this.onBeforeNodeDrop(e);});
                    return false;
                }
                e.confirmed = false;
                e.oldParent = s.parentNode;
                oldName = this.getPath(s);
                newName = this.getPath(d) + "/" + s.text;
            }
            else {
                return false;
                var elt = e.data.selections[0];
            }

            if (false === this.fireEvent("beforerename", this, s, oldName, newName)) {
                return false;
            }
            var options = {url:this.renameUrl || this.dataUrl, method:this.method, scope:this, callback:this.cmdCallback, node:s, oldParent:s.parentNode, e:e, params:{cmd:"rename", oldname:oldName, newname:newName}};
            var conn = (new Ext.data.Connection).request(options);
            return true;
        }
});

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
                , downloadUrl: '/directory/download'
                , downloadText: 'Download'
                , newdirUrl: '/directory/newdir'
                , uploadUrl: '/directory/upload'
                , iconPath: '../images/icons/'
		, readOnly: false
		, containerScroll: true
		, enableDD: true
                , ddGroup: 'TreeDD'
		, enableUpload: true
		, enableRename: true
		, enableDelete: true
                , enableDownload: true
		, enableNewDir: true
		, uploadPosition: 'menu'
		, edit: true
		, maxFileSize: 1048575
		, hrefPrefix: '/filetree/'
		, pgCfg: {
			uploadIdName: 'UPLOAD_IDENTIFIER'
			, uploadIdValue: 'auto'
			, progressBar: true
			, progressTarget: 'qtip'
			, maxPgErrors: 10
			, interval: 1000
			, options: {
				url: '/directory/upload'
				, method: 'post'
			}
		}
	});
        //tree = new Ext.Rged.TreeFile ('tree', {readOnly: false});

	// {{{
	var root = new Ext.tree.AsyncTreeNode({text:'root', path: '/', id: '/', allowDrag:false});
	this.tree.setRootNode(root);
	this.tree.render();
        this.tree.on('click', this.tree_onClick, this);
        this.tree.on('renamesuccess', function(tree, node, newname, oldname) { this.change_path(this.path)}, this);
        this.tree.on('beforeopen', this.tree_onDownload, this);
        root.expand();
    },
 
    tree_onDownload: function(tree, node, mode) {
        window.location = '/directory/download/?file=' + node.id;
        return false;
    },
    
    tree_onClick: function (node, elt) {
        var path = '/';
        if (node.isLeaf())
            path += this.tree.getPath(node.parentNode, 'path');
        else
            path += this.tree.getPath(node, 'path');
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

    menu_onRename: function(o, e) {
        var sel = this.grid.selModel.getSelected();
        this.renameFile(sel);
    },
    menu_onDelete: function(o, e) {
        var sel = this.grid.selModel.getSelected();
        this.deleteFile(sel);
    },
    menu_onDownload: function(o, e) {
        var sel = this.grid.selModel.getSelected();
        this.downloadFile(sel);
    },
    menu_onRefresh: function(o, e) {
        this.change_path(this.path);
    },
    // Initialize the menu
    init_menu: function () {

       this.menu = new Ext.Toolbar('menu');
       this.menu.addButton({
           text: 'Rename', cls: 'x-btn-text-icon scroll-bottom', handler: this.menu_onRename, scope: this});
       this.menu.addButton({
           text: 'Delete', cls: 'x-btn-text-icon scroll-top', handler: this.menu_onDelete, scope: this});
       this.menu.addButton({
           text: 'Download', cls: 'x-btn-text-icon scroll-top', handler: this.menu_onDownload, scope: this});
       this.menu.addButton({
           text: 'Refresh', cls: 'x-btn-text-icon scroll-top', handler: this.menu_onRefresh, scope: this});
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
                useShim: true,
                autoScroll: true,
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
            selModel:  new Ext.grid.RowSelectionModel({singleSelect: true}),
            enableDragDrop : true,
            ddGroup: 'TreeDD',
            autoExpandColumn: 'name',
            loadMask: true
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
        e.stopEvent();
        e.preventDefault();

        // {{{
        // lazy create upload form
        //this.createUploadForm();
        // }}}
        // {{{
        // lazy create context menu
        if(!this.contextMenu) {
                this.contextMenu = new Ext.menu.Menu({
                        items: [
                                        // node name we're working with placeholder
                                  { id:'nodename', disabled:true, cls:'x-filetree-nodename'}
                                , new Ext.menu.Separator({id:'sep-open'})
                                , {	id:'rename'
                                        , text:this.tree.renameText + ' (F2)'
                                        , icon:this.tree.renameIcon
                                        , scope:this
                                        , handler:this.onContextMenuItem
                                }
                                , {	id:'delete'
                                        , text:this.tree.deleteText + ' (' + this.tree.deleteKeyName + ')'
                                        , icon:this.tree.deleteIcon
                                        , scope:this
                                        , handler:this.onContextMenuItem
                                }
                                , {	id:'download'
                                        , text:this.tree.downloadText + ' (' + this.tree.openKeyName + ')'
                                        , icon:this.tree.openIcon
                                        , scope:this
                                        , handler:this.onContextMenuItem
                                }
                        ]
                });
        }
        var sel = this.grid.selModel.getSelected();
        // save current node to context menu and open submenu
        var menu = this.contextMenu;
        menu.item = sel;

        // set menu item text to node text
        var itemNodename = menu.items.get('nodename');
        itemNodename.setText(Ext.util.Format.ellipsis(sel.get('name'), 25));

        menu.showAt(menu.getEl().getAlignToXY(e.target, 'tl-tl?', [0, 18]));
        itemNodename.container.setStyle('opacity', 1);

    },
    // }}}
    // {{{
    /**
		* context menu item click handler
		* @param {MenuItem} item
		* @param {Event} e event
		*/
    onContextMenuItem: function(item, e) {

        // get node for before event
        var sel = item.parentMenu.item;
        var node = this.tree.getNodeById(sel.id);

        // menu item switch
        switch(item.id) {

                // {{{
                case 'rename':
                        this.renameFile(sel);
                break;
                // }}}
                // {{{
                case 'delete':
                        this.deleteFile(sel);
                break;
                // }}}
                // {{{
                case 'download':
                        this.downloadFile(sel);
                break;
                // }}}

         }; // end of switch(item.id)
    },

    renameFile: function(sel) {
        Ext.Msg.prompt(this.tree.renameText
                , this.tree.renameText + ' <b>' + sel.get('name') + '</b> to ?'
                , function(response, newname) {
                        var conn;
                        // do nothing if answer is not yes
                        if('ok' !== response) {
                                return;
                        }
                        // answer is yes
                        else {
                                // setup request options
                                options = {
                                        url: this.tree.renameUrl || this.tree.dataUrl
                                        , method: this.tree.method
                                        , scope: this
                                        , callback: this.cmdCallback
                                        , params: {
                                                cmd: 'rename'
                                                , oldname: sel.get('path')
                                                , newname: this.path + newname
                                        }
                                };
                                // send request
                                conn = new Ext.data.Connection().request(options);
                        }
                }
                , this
        );

        // set focus to no button to avoid accidental deletions
        var msgdlg = Ext.Msg.getDialog();
        msgdlg.setDefaultButton(msgdlg.buttons[2]).focus();
    },

    deleteFile: function(sel) {
        // display confirmation message
        Ext.Msg.confirm(this.tree.deleteText
                , this.tree.reallyWantText + ' ' + this.tree.deleteText.toLowerCase() + ' <b>' + sel.get('name') + '</b>?'
                , function(response) {
                        var conn;
                        // do nothing if answer is not yes
                        if('yes' !== response) {
                                return;
                        }
                        // answer is yes
                        else {
                                // setup request options
                                options = {
                                        url: this.tree.deleteUrl || this.tree.dataUrl
                                        , method: this.tree.method
                                        , scope: this
                                        , callback: this.cmdCallback
                                        , params: {
                                                cmd: 'delete'
                                                , file: sel.get('path')
                                        }
                                };
                                // send request
                                conn = new Ext.data.Connection().request(options);
                        }
                }
                , this
        );

        // set focus to no button to avoid accidental deletions
        var msgdlg = Ext.Msg.getDialog();
        msgdlg.setDefaultButton(msgdlg.buttons[2]).focus();
    },
    
    downloadFile: function(sel) {
        window.location = '/directory/download/?file=' + sel.get('path');
    },

    cmdCallback: function (options, bSuccess, response) {
        var i, o, node;
        var showMsg = true;
        if (true === bSuccess) {
            o = Ext.decode(response.responseText);
            if (true === o.success) {
                Ext.Msg.alert('Success', 'OK');
                this.change_path(this.path);
            } else {
                    Ext.Msg.alert(this.errorText, o.error);
            }
        }
    },

    grid_onCellClick: function( grid, rowIndex, columnIndex, e )
    {
        var rec = grid.getDataSource().getAt(rowIndex);
        var path = rec.get('path');
        var folder = rec.get('cls');
        if (folder == 'folder') {
            this.load_path(path);
        }
        //this.tree.expandPath(path.substrsub, 'path', function (success, node) { if (success) node.select()});
    },

    // Manage browser history
    init_history: function () {
        var bookmarkedSection = Ext.ux.History.getBookmarkedState( "dir" );
        var init = bookmarkedSection || '';

        Ext.ux.History.register( "dir", init, function( state ) {
        // This is called after calling YAHOO.util.History.navigate, or after the user
        // has trigerred the back/forward button. We cannot discrminate between
        // these two situations.
            var cur = Ext.ux.History.getCurrentState ("dir");
            if (cur != state)
                this.change_path(path);
        }, this, true );

        Ext.ux.History.initialize();
        //this.load_path (init);
    },

    init : function() {
       Ext.QuickTips.init();

       this.init_tree();
       this.init_menu ();
       this.init_layout ();
       this.init_grid ();
       //this.init_history ();
       this.load_path ('/');
    },

    load_path : function (path) {
        if (this.path != path) {
            if (path == '')
                path = '';
            //Ext.ux.History.navigate( "dir", path );
            this.change_path(path);
        }
    },

    change_path: function (path) {
        this.path = path;
        this.ds.load ({params: {path: path}});
        var p = "/root" + path;
        if (p.substr(p.length - 1, 1) == '/')
            p = p.substr(0, p.length - 1)
        this.textBox.setValue(p.substr(5, p.length - 5));
        this.tree.selectPath(p, 'text', function (success, node) { if (success) node.expand() });
    }
};

Ext.onReady(function() {
    var rged = new Rged ();
    rged.init ();
});


