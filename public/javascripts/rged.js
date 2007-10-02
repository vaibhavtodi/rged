function getIframeDocument(el) {
    var oIframe = Ext.get('center-iframe').dom;
    var oDoc = oIframe.contentWindow || oIframe.contentDocument;
    if(oDoc.document) {
        oDoc = oDoc.document;
    }
    return oDoc;
}

var Rged= function() {
    var northPanel, southPanel, eastPanel, westPanel, centerPanel;
    return {
        init : function() {
           var simpleToolbar = new Ext.Toolbar('center-tb');
           simpleToolbar.addButton({
               text: 'Scroll Bottom', cls: 'x-btn-text-icon scroll-bottom', handler: function(o, e) {
                   var iframeDoc = getIframeDocument('center-iframe');
                   iframeDoc.body.scrollTop = iframeDoc.body.scrollHeight;
               }
           });
           simpleToolbar.addButton({
               text: 'Scroll Top', cls: 'x-btn-text-icon scroll-top', handler: function(o, e) {
                   var iframeDoc = getIframeDocument('center-iframe');
                   iframeDoc.body.scrollTop = 0;
               }
           });
           var mainLayout = new Ext.BorderLayout(document.body, {
                north: { 
                    split: true, initialSize: 25 
                }, 
                west: { 
                    split: true, initialSize: 100, titlebar: true, collapsible: true
                }, 
                center: { titlebar: true}
            });
            mainLayout.beginUpdate();
            mainLayout.add('north', northPanel = new Ext.ContentPanel('menu-div', { 
                fitToFrame: true, closable: false 
            }));
            mainLayout.add('west', westPanel = new Ext.ContentPanel('tree-div', { 
                fitToFrame: true, closable: false, title: 'Folders'
            }));
            mainLayout.add('center', centerPanel = new Ext.ContentPanel('grid-div', { 
                fitToFrame: true, autoScroll: true, resizeEl: 'grid', title: 'Files'
            })); 
            mainLayout.endUpdate();
            northPanel.setContent('This panel will be used for a header');
            //Ext.get('center-iframe').dom.src = 'http://www.google.fr';
        }
    };
}();
Ext.EventManager.onDocumentReady(Rged.init, Rged, true);
