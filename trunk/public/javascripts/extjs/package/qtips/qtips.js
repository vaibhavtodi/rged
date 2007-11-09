/*
 * Ext JS Library 2.0 RC 1
 * Copyright(c) 2006-2007, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */

Ext.Tip=Ext.extend(Ext.Panel,{minWidth:40,maxWidth:300,shadow:"sides",defaultAlign:"tl-bl?",autoRender:true,quickShowInterval:250,frame:true,hidden:true,baseCls:"x-tip",floating:{shadow:true,shim:true,useDisplay:true,constrain:false},autoHeight:true,initComponent:function(){Ext.Tip.superclass.initComponent.call(this);if(this.closable&&!this.title){this.elements+=",header"}},afterRender:function(){Ext.Tip.superclass.afterRender.call(this);if(this.closable){this.addTool({id:"close",handler:this.hide,scope:this})}},showAt:function(A){Ext.Tip.superclass.show.call(this);if(this.measureWidth!==false&&(!this.initialConfig||typeof this.initialConfig.width!="number")){var B=this.body.getTextWidth();if(this.title){B=Math.max(B,this.header.child("span").getTextWidth(this.title))}B+=this.getFrameWidth()+(this.closable?20:0)+this.body.getPadding("lr");this.setWidth(B.constrain(this.minWidth,this.maxWidth))}if(this.constrainPosition){A=this.el.adjustForConstraints(A)}this.setPagePosition(A[0],A[1])},showBy:function(A,B){if(!this.rendered){this.render(Ext.getBody())}this.showAt(this.el.getAlignToXY(A,B||this.defaultAlign))},initDraggable:function(){this.dd=new Ext.Tip.DD(this,typeof this.draggable=="boolean"?null:this.draggable);this.header.addClass("x-tip-draggable")}});Ext.Tip.DD=function(B,A){Ext.apply(this,A);this.tip=B;Ext.Tip.DD.superclass.constructor.call(this,B.el.id,"WindowDD-"+B.id);this.setHandleElId(B.header.id);this.scroll=false};Ext.extend(Ext.Tip.DD,Ext.dd.DD,{moveOnly:true,scroll:false,headerOffsets:[100,25],startDrag:function(){this.tip.el.disableShadow()},endDrag:function(A){this.tip.el.enableShadow(true)}});
Ext.ToolTip=Ext.extend(Ext.Tip,{showDelay:500,hideDelay:200,dismissDelay:5000,mouseOffset:[15,18],trackMouse:false,constrainPosition:true,initComponent:function(){Ext.ToolTip.superclass.initComponent.call(this);this.lastActive=new Date();this.initTarget()},initTarget:function(){if(this.target){this.target=Ext.get(this.target);this.target.on("mouseover",this.onTargetOver,this);this.target.on("mouseout",this.onTargetOut,this);this.target.on("mousemove",this.onMouseMove,this)}},onMouseMove:function(A){this.targetXY=A.getXY();if(!this.hidden&&this.trackMouse){this.setPagePosition(this.getTargetXY())}},getTargetXY:function(){return[this.targetXY[0]+this.mouseOffset[0],this.targetXY[1]+this.mouseOffset[1]]},onTargetOver:function(A){if(this.disabled||A.within(this.target.dom,true)){return }this.clearTimer("hide");this.targetXY=A.getXY();this.delayShow()},delayShow:function(){if(this.hidden&&!this.showTimer){if(this.lastActive.getElapsed()<this.quickShowInterval){this.show()}else{this.showTimer=this.show.defer(this.showDelay,this)}}else{if(!this.hidden&&this.autoHide!==false){this.show()}}},onTargetOut:function(A){if(this.disabled||A.within(this.target.dom,true)){return }this.clearTimer("show");if(this.autoHide!==false){this.delayHide()}},delayHide:function(){if(!this.hidden&&!this.hideTimer){this.hideTimer=this.hide.defer(this.hideDelay,this)}},hide:function(){this.clearTimer("dismiss");this.lastActive=new Date();Ext.ToolTip.superclass.hide.call(this)},show:function(){this.showAt(this.getTargetXY())},showAt:function(A){this.lastActive=new Date();this.clearTimers();Ext.ToolTip.superclass.showAt.call(this,A);if(this.dismissDelay&&this.autoHide!==false){this.dismissTimer=this.hide.defer(this.dismissDelay,this)}},clearTimer:function(A){A=A+"Timer";clearTimeout(this[A]);delete this[A]},clearTimers:function(){this.clearTimer("show");this.clearTimer("dismiss");this.clearTimer("hide")},onShow:function(){Ext.ToolTip.superclass.onShow.call(this);Ext.getDoc().on("mousedown",this.onDocMouseDown,this)},onHide:function(){Ext.ToolTip.superclass.onHide.call(this);Ext.getDoc().un("mousedown",this.onDocMouseDown,this)},onDocMouseDown:function(A){if(this.autoHide!==false&&!A.within(this.el.dom)){this.disable();this.enable.defer(100,this)}},onDisable:function(){this.clearTimers();this.hide()},adjustPosition:function(A,D){var C=this.targetXY[1],B=this.getSize().height;if(this.constrainPosition&&D<=C&&(D+B)>=C){D=C-B-5}return{x:A,y:D}},onDestroy:function(){Ext.ToolTip.superclass.onDestroy.call(this);if(this.target){this.target.un("mouseover",this.onTargetOver,this);this.target.un("mouseout",this.onTargetOut,this);this.target.un("mousemove",this.onMouseMove,this)}}});
Ext.QuickTip=Ext.extend(Ext.ToolTip,{interceptTitles:false,tagConfig:{namespace:"ext",attribute:"qtip",width:"qwidth",target:"target",title:"qtitle",hide:"hide",cls:"qclass",align:"qalign"},initComponent:function(){this.target=this.target||Ext.getDoc();this.targets=this.targets||{};Ext.QuickTip.superclass.initComponent.call(this)},register:function(D){var F=D instanceof Array?D:arguments;for(var E=0,A=F.length;E<A;E++){var H=F[E];var G=H.target;if(G){if(G instanceof Array){for(var C=0,B=G.length;C<B;C++){this.targets[Ext.id(G[C])]=H}}else{this.targets[Ext.id(G)]=H}}}},unregister:function(A){delete this.targets[Ext.id(A)]},onTargetOver:function(G){if(this.disabled){return }this.targetXY=G.getXY();var C=G.getTarget();if(!C||C.nodeType!==1||C==document||C==document.body){return }if(this.activeTarget&&C==this.activeTarget.el){this.clearTimer("hide");this.show();return }if(C&&this.targets[C.id]){this.activeTarget=this.targets[C.id];this.activeTarget.el=C;this.delayShow();return }var E,F=Ext.fly(C),B=this.tagConfig;var D=B.namespace;if(this.interceptTitles&&C.title){E=C.title;C.qtip=E;C.removeAttribute("title");G.preventDefault()}else{E=C.qtip||F.getAttributeNS(D,B.attribute)}if(E){var A=F.getAttributeNS(D,B.hide);this.activeTarget={el:C,text:E,width:F.getAttributeNS(D,B.width),autoHide:A!="user"&&A!=="false",title:F.getAttributeNS(D,B.title),cls:F.getAttributeNS(D,B.cls),align:F.getAttributeNS(D,B.align)};this.delayShow()}},onTargetOut:function(A){this.clearTimer("show");if(this.autoHide!==false){this.delayHide()}},showAt:function(B){var A=this.activeTarget;if(A){if(!this.rendered){this.render(Ext.getBody())}if(A.width){this.setWidth(A.width);this.measureWidth=false}else{this.measureWidth=true}this.setTitle(A.title||"");this.body.update(A.text);this.autoHide=A.autoHide;this.dismissDelay=A.dismissDelay||this.dismissDelay;if(A.cls){if(this.lastCls){this.el.removeClass(this.lastCls)}this.el.addClass(A.cls);this.lastCls=A.cls}if(A.align){B=this.el.getAlignToXY(A.el,A.align);this.constrainPosition=false}else{this.constrainPosition=true}}Ext.QuickTip.superclass.showAt.call(this,B)},hide:function(){delete this.activeTarget;Ext.QuickTip.superclass.hide.call(this)}});
Ext.QuickTips=function(){var B,A=[];return{init:function(){if(!B){B=new Ext.QuickTip({elements:"header,body"})}},enable:function(){if(B){A.pop();if(A.length<1){B.enable()}}},disable:function(){if(B){B.disable()}A.push(1)},isEnabled:function(){return B&&!B.disabled},getQuickTip:function(){return B},register:function(){B.register.apply(B,arguments)},unregister:function(){B.unregister.apply(B,arguments)},tips:function(){B.register.apply(B,arguments)}}}();