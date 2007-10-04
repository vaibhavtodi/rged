/*
 * Ext JS Library 1.1.1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 *
 * http://www.extjs.com/license
 */

Ext.onReady(function(){

    Ext.QuickTips.init();

    // turn on validation errors beside the field globally
    Ext.form.Field.prototype.msgTarget = 'side';

    /*
     * ================  Simple form  =======================
     */
    var simple = new Ext.form.Form({
        labelWidth: 75, // label settings here cascade unless overridden
        action:'/account/login'
    });
          simple.add(
	    new Ext.form.TextField({
	        fieldLabel: 'Login',
		name: 'login',
		inputType: 'login',
		width:175,
		allowBlank:false
		}),

	    new Ext.form.TextField({
		fieldLabel: 'Password',
		name: 'password',
		inputType: 'password',
		width:175
		})
    );
    simple.addButton('Submit', function(){
		    var thisform = document.getElementById(silmple.id);
		    thisform.method='POST';
		    thisform.action='/account/login';
		    thisform.submit();
		    }
       );
    simple.addButton({
           text: 'Sign up', handler: function(o, e) {
               window.location = '/account/signup';
           }
	   });
    simple.on('actioncomplete', function(form, action) {
		alert("lol");
    });

    simple.render('form-ct');
});

