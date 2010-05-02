/* $Id$ */

var State = new Class( {
   initialize: function( options ) {
      this.assets          = options.assets;
      this.cookies         = new Cookies( { path  : options.path,
                                            prefix: options.prefix } );
      this.onStateComplete = options.onStateComplete;
      this.popup           = options.popup;
   },

   resize: function( changed ) {
      var append, buttons, content, elWidth, footer, foot_height = 0;
      var height = 5, h = window.getHeight(), w = window.getWidth();

      if (! this.popup) {
         this.cookies.set( 'width',  w );
         this.cookies.set( 'height', h );
         window.defaultStatus = 'w: ' + w + ' h: ' + h;
      }

      if (! (content = $( 'content' ))) return;

      if (footer = $( 'footerDisp' )) {
         foot_height = footer.getStyle( 'display' ) != 'none'
                     ? footer.getStyle( 'height' ).toInt() : 0;
         height += foot_height;
      }

      if (append = $( 'appendDisp' )) {
         height += append.getStyle( 'height' ).toInt();

         if (footer) append.setStyle( 'marginBottom', foot_height + 'px' );
      }

      content.setStyle( 'marginBottom', height + 'px' );

      if (this.sidebar) elWidth = this.sidebar.resize( changed, height );
      else elWidth = 0;

      content.setStyle( 'marginLeft', elWidth + 'px' );

      if (buttons = $( 'buttonDisp' ))
           elWidth = buttons.getStyle( 'width' ).toInt();
      else elWidth = 0;

      content.setStyle( 'marginRight', elWidth + 'px' );
      return;
   },

   setState: function( first_fld ) {
      var cookie_ref, el;

      /* Use state cookie to restore the visual state of the page */
      if (cookie_ref = this.cookies.get()) {
         var cookies = cookie_ref.split( '+' );

         for (var i = 0; i < cookies.length; i++) {
            if (! cookies[ i ]) continue;

            var pair = cookies[ i ].split( '~' );
            var p0   = unescape( pair[ 0 ] );
            var p1   = unescape( pair[ 1 ] );

            /* Deprecated */
            /* Restore state of any checkboxes whose ids end in Box */
            if (el = $( p0 + 'Box' ))
               el.checked = (p1 == 'true' ? true : false);

            /* Restore the state of any elements whose ids end in Disp */
            if (el = $( p0 + 'Disp' ))
               el.setStyle( 'display', (p1 != 'false' ? '' : 'none') );

            /* Restore the className for elements whose ids end in Icon */
            if (el = $( p0 + 'Icon' )) { if (p1) el.className = p1; }

            /* Restore the source URL for elements whose ids end in Img */
            if (el = $( p0 + 'Img' )) { if (p1) el.src = p1; }
         }
      }

      this.autosizer = new AutoSize();
      this.checkboxReplacements = new CheckboxReplace();
      this.sidebar   = new Sidebar( { state: this } );
      this.setupScroller( 'content' );
      this.trees     = new Trees();
      this.wysiwyg   = new WYSIWYG();
      this.linkFade  = new LinkFader();
      this.tips      = new Tips( {
         initialize: function() {
		      this.fx  = new Fx.Style( this.toolTip, 'opacity',
               { duration: 500, wait: false } ).set( 0 );
         },
	      onShow    : function( toolTip ) { this.fx.start( 1 ) },
         onHide    : function( toolTip ) { this.fx.start( 0 ) },
         showDelay : 666
      } );
      this.resize();
      this.columnizers = new Columnizers();

      // TODO: Either make this look right or drop it
      if ($( 'results' )) {
         new Fx.Style( 'results', 'margin-top',
            { duration: 1500 } ).set( -window.getHeight() ).start( 0 );
      }

      if (this.onStateComplete) this.onStateComplete.call( this );

      if (first_fld && (el = $( first_fld ))) el.focus();
   },

   setupScroller: function( id ) {
      if (! this.scroller) return;

      this.scroller = new Scroller( id, { area: 150, velocity: 1 } );

      id = $( id );
      id.setStyle( 'cursor', 'url(/static/images/openhand.cur), move' );

      id.addEvent( 'mousedown', function() {
         id.setStyle( 'cursor', 'url(/static/images/closedhand.cur), move' );
         this.scroller.start();
      }.bind( this ) );

      id.addEvent( 'mouseup', function() {
         id.setStyle( 'cursor', 'url(/static/images/openhand.cur), move' );
         this.scroller.stop();
      }.bind( this ) );
   },

   toggle: function( e ) {
      var elem = $( e.id + 'Disp' );

      if (elem.getStyle( 'display' ) != 'none') {
         elem.setStyle( 'display', 'none' ); this.cookies.remove( e.id );
      }
      else {
         elem.setStyle( 'display', '' ); this.cookies.set( e.id, 'true' );
      }

      this.resize();
   },

   toggleState: function( id ) {
      var elem = $( id + 'Box' );

      this.cookies.set( id, (elem.checked ? 'true' : 'false') );
   },

   toggleSwap: function( e, s1, s2 ) {
      var elem;

      if (elem = $( e.id + 'Disp' )) {
         if (elem.getStyle( 'display' ) !=  'none') {
            elem.setStyle( 'display', 'none' );
            this.cookies.remove( e.id );

            if (elem = $( e.id )) elem.setHTML( s2 );
         }
         else {
            elem.setStyle( 'display', '' );
            this.cookies.set( e.id, s2 );

            if (elem = $( e.id )) elem.setHTML( s1 );
         }
      }

      this.resize();
   },

   toggleSwapImg: function( e, s1, s2 ) {
      var elem;

      if (elem = $( e.id + 'Disp' )) {
         if (elem.getStyle( 'display' ) != 'none') {
            elem.setStyle( 'display', 'none' );
            this.cookies.remove( e.id );

            if (elem = $( e.id + 'Img' )) elem.src = s1;
         }
         else {
            elem.setStyle( 'display', '' );
            this.cookies.set( e.id, s2 );

            if (elem = $( e.id + 'Img' )) elem.src = s2;
         }
      }

      this.resize();
   },

   toggleSwapText: function( id, cookie, s1, s2 ) {
      var elem = $( id );

      if (this.cookies.get( cookie ) == 'true') {
         this.cookies.set( cookie, 'false' );

         if (elem) elem.setHTML( s2 );

         if (elem = $( cookie + 'Disp' )) elem.setStyle( 'display', 'none' );
      }
      else {
         this.cookies.set( cookie, 'true' );

         if (elem) elem.setHTML( s1 );

         if (elem = $( cookie + 'Disp' )) elem.setStyle( 'display', '' );
      }

      this.resize();
   }
} );

behaviour.freeList    = new FreeList(    { form  : behaviour.formName } );
behaviour.groupMember = new GroupMember( { form  : behaviour.formName } );
behaviour.loadMore    = new LoadMore(    { url   : behaviour.url } );
behaviour.server      = new ServerUtils( { url   : behaviour.url } );
behaviour.submit      = new SubmitUtils( { form  : behaviour.formName,
                                           path  : behaviour.sessionPath,
                                           prefix: behaviour.sessionPrefix } );
behaviour.table       = new TableUtils(  { form  : behaviour.formName,
                                           url   : behaviour.url } );
behaviour.window      = new WindowUtils( { path  : behaviour.sessionPath,
                                           prefix: behaviour.sessionPrefix,
                                           target: behaviour.target } );
behaviour.state       = new State
   ( { assets         : behaviour.assetsPath,
       onStateComplete: function() {
         var cbr = this.checkboxReplacements;
         behaviour.table.sortComplete = cbr.replaceAll.bind( cbr ); },
       path           : behaviour.sessionPath,
       popup          : behaviour.isPopup,
       prefix         : behaviour.sessionPrefix } );

window.onresize = function() { this.resize( true ); }.bind( behaviour.state );

/* Local Variables:
 * mode: java
 * tab-width: 3
 * End:
 */
