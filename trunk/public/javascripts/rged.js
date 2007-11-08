// set blank image to local file
Ext.BLANK_IMAGE_URL = '/javascripts/extjs/resources/images/default/s.gif';

Ext.override(Ext.grid.GridPanel, {
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

	this.tree = new Ext.ux.FileTreePanel({
                el: 'tree'
		, animate: true
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
                , root: new Ext.tree.AsyncTreeNode({text:'root', path: '/', id: '/', allowDrag:false})
	});

	this.tree.render();
        this.tree.getRootNode().expand();
        this.tree.on('click', this.tree_onClick, this);
        this.tree.on('renamesuccess', function(tree, node, newname, oldname) { this.change_path(this.path)}, this);
        this.tree.on('beforeopen', this.tree_onDownload, this);

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
    
    menu_DropDelete: function(n, dd, e, data){
       if (e.selections)
           this.deleteFile(e.selections[0]);
       else
           this.tree.deleteNode(e.node);
   },
   
   menu_DropRename: function(n, dd, e, data){
       if (e.selections)
           this.renameFile(e.selections[0]);
   },
   
   menu_DropDownload: function(n, dd, e, data){
       if (e.selections)
           this.downloadFile(e.selections[0]);
       else
           this.tree.openNode(e.node);
   },
    // Initialize the menu
    init_menu: function () {
       this.menu = new Ext.Toolbar()
       this.menu.render('menu')
       this.menu.addButton({
           id: 'rename',
           text: 'Rename',
           cls: 'x-btn-text-icon menu-rename', 
           handler: this.menu_onRename, 
           scope: this
           });
       this.menu.addButton({
           id: 'delete',
           text: 'Delete',
            cls: 'x-btn-text-icon menu-delete', 
            handler: this.menu_onDelete, 
            scope: this});
       this.menu.addButton({
           id: 'download',
           text: 'Download', 
           cls: 'x-btn-text-icon menu-download', 
           handler: this.menu_onDownload, 
           scope: this});
       this.menu.addButton({
           id: 'refresh',
           text: 'Refresh', 
           cls: 'x-btn-text-icon menu-refresh', 
           handler: this.menu_onRefresh, 
           scope: this});
       this.textBox = new Ext.form.TextField ({
           cls: 'rged-adress',
           width: 500});
       this.textBox.on('change', this.menu_onChange, this);
       this.textBox.on('specialkey', this.menu_onSpecialKey, this);
       this.menu.addField(this.textBox);
       this.menu.addFill ();
       this.menu.addButton({
           text: 'Logout', 
           cls: 'x-btn-text-icon menu-logout',
           handler: function(o, e) {
               window.location = '/account/logout/';
           }
       });
    },

    // Initilize the global layout
    init_layout: function () {
//         this.northPanel = new Ext.Panel();
//         
//         this.westPanel = new Ext.Panel();
//            
//            this.centerPanel = new Ext.Panel();
            
            var mainLayout = new Ext.Viewport({
                layout:'border',
                items: [
                    {                     
                xtype:'panel',
                region: 'center',
                titlebar: true,
                contentEl:'grid',
                title: 'Files',
                autoScroll:false,
                tabPosition: 'top',
                closeOnTab: true,
                resizeTabs: true,
                fitToFrame: true, autoScroll: true, resizeEl: this.grid, title: 'Files'
            },
                    {
                region: 'west',
                contentEl:'tree',
                split:true,
                width: 250,
                minWidth: 175,
                maxWidth: 400,
                titlebar: true,
                collapsible: true,
                animate: true,
                useShim: true,
                autoScroll: true,
                cmargins: {top:2,bottom:2,right:2,left:2},
                fitToFrame: true, 
                closable: false, 
                title: 'Folders'
            },
                    {
                region: 'north',
                contentEl: 'menu',
                split:false,
                initialSize: 32,
                titlebar: false,
                fitToFrame: true, 
                closable: false
                }
                ]
            });
            
//       mainLayout.beginUpdate();
//        mainLayout.add(this.northPanel = new Ext.Panel({ region:'north',
//            fitToFrame: true, closable: false, contentEl: 'menu'
//        }));
//        mainLayout.add(this.westPanel = new Ext.ContentPanel({ region:'west',
//            fitToFrame: true, closable: false, title: 'Folders', contentEl: 'tree'
//        }));
//        mainLayout.add(this.centerPanel = new Ext.Panel({region:'center',
//            fitToFrame: true, autoScroll: true, resizeEl: this.grid, title: 'Files', contentEl: 'grid'
//        }));
//        mainLayout.endUpdate();

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
//        var colModel = new Ext.grid.ColumnModel([
//                        {id: 'icon', header: '<img src="/images/icons/arrow_up.png" width="16" height="18"/>', width: 25, sortable: false, renderer: icon, dataIndex: 'cls', fixed : true},
//			{id:'name',header: "Name", width: 160, sortable: true, locked:false, dataIndex: 'name'
//                            , editor: new Ext.grid.GridEditor(new Ext.form.TextField({
//                                allowBlank: false}))},
//			{header: "Size", width: 75, sortable: true, renderer: size, dataIndex: 'size'},
//                        {header: "Last Updated", width: 85, sortable: true, renderer: Ext.util.Format.dateRenderer('m/d/Y'), dataIndex: 'lastChange'}
//		]);


        // create the Grid
        this.grid = new Ext.grid.GridPanel({
            store: this.ds,
            columns: [
               {
                   id: 'icon',
                   header: '<img src="/images/icons/arrow_up.png" width="16" height="18"/>',
                   width: 25, sortable: false, renderer: icon, dataIndex: 'cls', 
                   fixed : true
               },
               {
                   id:'name',
                   header: "Name", 
                   width: 160, 
                   sortable: true, 
                   locked:false, 
                   dataIndex: 'name',
                   editor: new Ext.grid.GridEditor(new Ext.form.TextField({
                                allowBlank: false}))},
                {
                    header: "Size", 
                    width: 75, 
                    sortable: true, 
                    renderer: size, 
                    dataIndex: 'size'},
                {
                    header: "Last Updated", 
                    width: 85, 
                    sortable: true, 
                    renderer: Ext.util.Format.dateRenderer('m/d/Y'), 
                    dataIndex: 'lastChange'
                    
                } 
            ],
            sm:  new Ext.grid.RowSelectionModel({singleSelect: true}),
            enableDragDrop : true,
            ddGroup: 'TreeDD',
            autoExpandColumn: 'name',
            loadMask: true
        });

        this.grid.render('grid');
       //this.grid.getSelectionModel().selectFirstRow();
        this.grid.on('celldblclick', this.grid_onCellDblClick, this);
        this.grid.on('cellclick', this.grid_onCellClick, this);
        this.grid.on('cellcontextmenu', this.grid_onCellContextMenu, this);
        this.grid.on('headerdblclick', this.grid_onHeaderClick, this);
        this.grid_installKeyMap();
    },

    grid_onCellDblClick: function( grid, rowIndex, columnIndex, e )
    {
        var rec = grid.getDataSource().getAt(rowIndex);
        var path = rec.get('path');
        var folder = rec.get('cls');
        if (folder == 'folder') {
            this.load_path(path);
        }
        //this.tree.expandPath(path.substrsub, 'path', function (success, node) { if (success) node.select()});
    },
    
    
    grid_onCellClick: function( grid, rowIndex, columnIndex, e )
    {
        var rec = grid.getDataSource().getAt(rowIndex);
        var p = "/root" + rec.get('path');
        if (p.substr(p.length - 1, 1) == '/')
            p = p.substr(0, p.length - 1)
        this.tree.selectPath(p, 'text', function (success, node) { if (success) node.expand() });
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
                                        , text:this.tree.downloadText + ' (Enter)'
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
                               this.rename(this.path + newname, sel.get('path'));
                        }
                }
                , this
        );

        // set focus to no button to avoid accidental deletions
        var msgdlg = Ext.Msg.getDialog();
        msgdlg.setDefaultButton(msgdlg.buttons[2]).focus();
    },

    rename: function (newname, oldname) {
     // setup request options
        options = {
                url: this.tree.renameUrl || this.tree.dataUrl
                , method: this.tree.method
                , scope: this
                , callback: this.cmdCallback
                , params: {
                        cmd: 'rename'
                        , oldname: oldname
                        , newname: newname
                }
        };
        // send request
        conn = new Ext.data.Connection().request(options);
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

    grid_installKeyMap: function() {

            // install keymap
            var keymap = new Ext.KeyMap(this.grid.getGridEl(), [


                    // open
                    { 
                            key: Ext.EventObject.ENTER // F2 key = edit
                            , scope: this
                            , fn: function(key, e) {
                                    var sel = this.grid.selModel.getSelected();
                                    this.downloadFile(sel);
                    }}

                    // edit
                   , { 
                            key: 113 // F2 key = edit
                            , scope: this
                            , fn: function(key, e) {
                                    var sel = this.grid.selModel.getSelected();
                                    this.renameFile(sel);
                    }}

                    // delete
                    , {
                            key: 46 // Delete key
                            , stopEvent: true
                            , scope: this
                            , fn: function(key, e) {
                                    var sel = this.grid.selModel.getSelected();
                                    this.deleteFile(sel);
                    }}

                    // reload
                    , {
                            key: 69 // Ctrl + E = reload
                            , ctrl: true
                            , stopEvent: true
                            , scope: this
                            , fn: function(key, e) {
                                    this.change_path(this.path);
                    }}
            ]);
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
            //if (cur != state)
                //this.change_path(path);
        }, this, true );

        Ext.ux.History.initialize();
        //this.load_path (init);
    },

    init_drop: function() {
        ddel = new Ext.dd.DropZone('delete', {ddGroup: 'TreeDD', notifyOver: function(dd, e, data)
           {
              return 'x-dd-drop-ok';
           }});
       var rged = this;
       ddel.notifyDrop = function(n, dd, e, data){
          rged.menu_DropDelete.apply(rged, arguments);
       };
       var ddren = new Ext.dd.DropZone('rename', {ddGroup: 'TreeDD', notifyOver: function(dd, e, data)
           {
              return 'x-dd-drop-ok';
           }});
       ddren.notifyDrop = function(n, dd, e, data){
          rged.menu_DropRename.apply(rged, arguments);
       };
       var ddown = new Ext.dd.DropZone('download', {ddGroup: 'TreeDD', notifyOver: function(dd, e, data)
           {
              return 'x-dd-drop-ok';
           }});
       ddown.notifyDrop = function(n, dd, e, data){
          rged.menu_DropDownload.apply(rged, arguments);
       };
       var ddgrid = new Ext.dd.DropTarget(this.grid.getView().mainBody, {
           ddGroup: 'TreeDD',
           notifyDrop: function(dd, e, data) 
           { 
               rged.grid_notifyDrop.apply(rged, arguments);
           },

           notifyOver: function(dd, e, data)
           {
              var drop=dd.getDragData(e).selections[0];
              return (drop.data.cls == 'folder')?'x-dd-drop-ok-add':'x-dd-drop-nodrop';
           } });       
    },
    
   grid_notifyDrop: function(dd, e, data) 
   { 
      var drop=dd.getDragData(e).selections[0];
      var drag=data.selections[0];
      if (drop.data.cls == 'folder')
        this.rename(drop.id + "/" + drag.data.name, drag.id);
   },
    
    init : function() {
       Ext.QuickTips.init();
       this.init_tree();
       this.init_menu ();
       this.init_layout ();
       this.init_grid ();
       this.init_drop ();
       var local = this;
       unFocus.History.addEventListener('historyChange', function(path) {local.change_path(path);});
       var path = unFocus.History.getCurrent() || '/';
       this.change_path (path);
    },

    load_path : function (path) {
        if (this.path != path) {
            if (path == '')
                path = '/';
            unFocus.History.addHistory(path);
            //this.change_path(path);
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


