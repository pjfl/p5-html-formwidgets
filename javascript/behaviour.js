/* $Id$ */

var State = new Class( {
   Implements: [ Events, Options ],

   options           : {
      config         : { calendars  : {},
                         tabSwappers: { options: { smooth    : true,
                                                   smoothSize: true } },
                         sliders    : {},
                         submit     : {} },
      formName       : null,
      onStateComplete: $empty,
      popup          : false,
      sessionPath    : '/',
      sessionPrefix  : 'behaviour',
      url            : null
   },

   initialize: function( options ) {
      this.setOptions( options ); var opt = this.options;

      this.config  = $merge( opt.config );
      this.cookies = new Cookies( { path  : opt.sessionPath,
                                    prefix: opt.sessionPrefix } );
   },

   resize: function( changed ) {
      var append, content, footer, foot_height = 0;
      var height = 5, h = window.getHeight(), w = window.getWidth();

      if (! this.options.popup) {
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

      var width = this.sidebar ? this.sidebar.resize( changed, height ) : 0;

      content.setStyle( 'marginLeft', width + 'px' );

      var buttons = $( 'buttonDisp' );

      width = buttons ? buttons.getStyle( 'width' ).toInt() : 0;
      content.setStyle( 'marginRight', width + 'px' );
   },

   restoreFrom: function( cookie_str ) {
      var cookies = cookie_str.split( '+' ), el;

      for (var i = 0, il = cookies.length; i < il; i++) {
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
   },

   setState: function( firstField ) {
      var cookies, el, options = this.options;

      /* Use state cookie to restore the visual state of the page */
      if (cookies = this.cookies.get()) this.restoreFrom( cookies );

      this.submit      = new SubmitUtils( { config  : this.config.submit,
                                            cookies : this.cookies,
                                            formName: options.formName } );
      this.autosizer   = new AutoSize();
      this.calendars   = new Calendars( { config: this.config.calendars,
                                          submit: this.submit } );
      this.checkboxReplacements = new CheckboxReplace();
      this.freeList    = new FreeList();
      this.groupMember = new GroupMember();
      this.sidebar     = new Sidebar( this );
      this.sliders     = new Sliders( { config: this.config.sliders,
                                        submit: this.submit } );
      this.tables      = new TableUtils(
         { formName      : options.formName,
           onSortComplete: function() {
               this.replaceAll() }.bind( this.checkboxReplacements ),
           url           : options.url } );
      this.tabSwappers = new TabSwappers( { config : this.config.tabSwappers,
                                            cookies: this.cookies } );
      this.trees       = new Trees( { sessionPath  : options.sessionPath,
                                      sessionPrefix: options.sessionPrefix } );
      this.wysiwyg     = new WYSIWYG();
      this.linkFade    = new LinkFader();
      this.tips        = new Tips( {
         onHide      : function() { this.fx.start( 0 ) },
         onInitialize: function() {
		      this.fx    = new Fx.Tween( this.tip,
               { duration: 500, property: 'opacity', wait: false } ).set( 0 );
         },
	      onShow      : function() { this.fx.start( 1 ) },
         showDelay   : 666
      } );
      this.resize();
      this.columnizers = new Columnizers();

      this.fireEvent( 'stateComplete' );

      if (firstField && (el = $( firstField ))) el.focus();
   },

   toggle: function( el ) {
      var disp = $( el.id + 'Disp' );

      if (disp.getStyle( 'display' ) != 'none') {
         disp.setStyle( 'display', 'none' ); this.cookies.remove( el.id );
      }
      else {
         disp.setStyle( 'display', '' ); this.cookies.set( el.id, 'true' );
      }

      this.resize();
   },

   toggleState: function( id ) {
      var el; if (! (el = $( id + 'Box' ))) return;

      this.cookies.set( id, (el.checked ? 'true' : 'false') );
   },

   toggleSwap: function( el, s1, s2 ) {
      var disp;

      if (disp = $( el.id + 'Disp' )) {
         if (disp.getStyle( 'display' ) != 'none') {
            disp.setStyle( 'display', 'none' ); this.cookies.remove( el.id );

            if (el = $( el.id )) el.set( 'html', s2 );
         }
         else {
            disp.setStyle( 'display', '' ); this.cookies.set( el.id, s2 );

            if (el = $( el.id )) el.set( 'html', s1 );
         }
      }

      this.resize();
   },

   toggleSwapImg: function( el, s1, s2 ) {
      var disp;

      if (disp = $( el.id + 'Disp' )) {
         if (disp.getStyle( 'display' ) != 'none') {
            disp.setStyle( 'display', 'none' ); this.cookies.remove( el.id );

            if (el = $( el.id + 'Img' )) el.src = s1;
         }
         else {
            disp.setStyle( 'display', '' ); this.cookies.set( el.id, s2 );

            if (el = $( el.id + 'Img' )) el.src = s2;
         }
      }

      this.resize();
   },

   toggleSwapText: function( id, cookie, s1, s2 ) {
      var el = $( id );

      if (this.cookies.get( cookie ) == 'true') {
         this.cookies.set( cookie, 'false' );

         if (el) el.set( 'html', s2 );

         if (el = $( cookie + 'Disp' )) el.setStyle( 'display', 'none' );
      }
      else {
         this.cookies.set( cookie, 'true' );

         if (el) el.set( 'html', s1 );

         if (el = $( cookie + 'Disp' )) el.setStyle( 'display', '' );
      }

      this.resize();
   }
} );

behaviour.loadMore  = new LoadMore(    { url   : behaviour.url } );
behaviour.server    = new ServerUtils( { url   : behaviour.url } );
behaviour.window    = new WindowUtils( { path  : behaviour.sessionPath,
                                         prefix: behaviour.sessionPrefix,
                                         target: behaviour.target } );
behaviour.state     = new State
   ( { formName     : behaviour.formName,
       popup        : behaviour.isPopup,
       sessionPath  : behaviour.sessionPath,
       sessionPrefix: behaviour.sessionPrefix,
       url          : behaviour.url } );

window.onresize = function() { this.state.resize( true ) }.bind( behaviour );
window.onload   = function() {
   this.state.setState( this.firstField ) }.bind( behaviour );

/* Local Variables:
 * mode: javacsript
 * tab-width: 3
 * End:
 */
