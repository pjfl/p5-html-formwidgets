/* $Id$ */

/* Local Variables:
 * mode: javascript
 * tab-width: 3
 * End: */

var Behaviour = new Class( {
   Implements: [ Events, Options ],

   config            : {
      anchors        : {},
      calendars      : {},
      inputs         : {},
      lists          : {},
      scrollPins     : {},
      server         : {},
      sidebars       : {},
      sliders        : {},
      spinners       : {},
      tables         : {},
      tabSwappers    : {}
   },

   options           : {
      contentId      : 'content',
      cookieDomain   : '',
      cookiePath     : '/',
      cookiePrefix   : 'behaviour',
      defaultURL     : null,
      formName       : null,
      iconClasses    : [ 'down_point_icon', 'up_point_icon' ],
      minMarginBottom: 5,
      minMarginLeft  : 0,
      minMarginRight : 10,
      popup          : false,
      statusUpdPeriod: 5000,
      target         : null
   },

   initialize: function( options ) {
      this.setOptions( options ); this.collection = [];

      window.addEvent( 'load',   function() {
         this.load( options.firstField ) }.bind( this ) );
      window.addEvent( 'resize', function() { this.resize() }.bind( this ) );
   },

   collect: function( object ) {
      this.collection.include( object ); return object;
   },

   getContentMarginBottom: function() {
      var content; if (! (content = $( this.options.contentId ))) return 0;

      return content.getStyle( 'marginBottom' ).toInt();
   },

   load: function( first_field ) {
      var opt = this.options;

      this.cookies     = new Cookies( {
         domain        : opt.cookieDomain,
         path          : opt.cookiePath,
         prefix        : opt.cookiePrefix } );
      this.stylesheet  = new PersistantStyleSheet( { cookies: this.cookies } );

      this._restoreStateFromCookie();

      this.submit      = new SubmitUtils( {
         context       : this,
         formName      : opt.formName } );
      this.window      = new WindowUtils( {
         context       : this,
         target        : opt.target,
         url           : opt.defaultURL } );

      this.autosizer   = new AutoSize( { context: this } );
      this.calendars   = new Calendars( { context: this } );
      this.checkboxReplacements = new CheckboxReplace( { context: this } );
      this.freeList    = new FreeList( { context: this } );
      this.groupMember = new GroupMember( { context: this } );
      this.liveGrids   = new LiveGrids( {
         context       : this,
         iconClasses   : opt.iconClasses,
         url           : opt.defaultURL } );
      this.noticeBoard = new NoticeBoard( { context: this } );
      this.rotateList  = new RotateList( { context: this } );
      this.server      = new ServerUtils( {
         context       : this,
         url           : opt.defaultURL } );
      this.sidebar     = new Sidebar ( { context: this } );
      this.sliders     = new Sliders( { context: this } );
      this.spinners    = new Spinners( { context: this } );

      var table_rebuild = function() {
         this.checkboxReplacements.build();
         this.autosizer.build() }.bind( this );

      this.tables      = new TableUtils( {
         context       : this,
         formName      : opt.formName,
         onRowAdded    : table_rebuild } );
      this.tableSort   = new TableSort( {
         context       : this,
         onSortComplete: table_rebuild } );
      this.tabSwappers = new TabSwappers( { context: this } );
      this.togglers    = new Togglers( { context: this } );
      this.trees       = new Trees( {
         context       : this,
         cookieDomain  : opt.cookieDomain,
         cookiePath    : opt.cookiePath,
         cookiePrefix  : opt.cookiePrefix } );
      this.wysiwyg     = new WYSIWYG( { context: this } );
      this.linkFade    = new LinkFader( { context: this } );

      // TODO: This is clumsy and needs fixing
      if (window.Chosens  != undefined)
         this.chosens  = new Chosens( { context: this } );
      if (window.Typeface != undefined)
         this.typeface = this.collect( window._typeface_js );

      this.resize();

      this.columnizers = new Columnizers( { context: this } );
      this.scrollPins  = new ScrollPins( {
         context       : this,
         log           : this.window.log,
         onAttach      : function( el ) {
            this.addEvent( 'build', function() {
               this.set( 'opacity', 0 ).set( 'tween', { duration: 1500 } );
            }.bind( el.pin.markup ) );

            this.addEvent( 'show', function() {
               this.tween( 'opacity', 1 ) }.bind( el.pin.markup ) ); },
         onInitialize  : function() {
            this.fireEvent.delay( 1000, this, [ 'show' ] ) },
         trayPadding   : 0 } );
      this.tips        = new Tips( {
         context       : this,
         onHide        : function() { this.fx.start( 0 ) },
         onInitialize  : function() {
            this.fx    = new Fx.Tween( this.tip, {
               duration: 500, property: 'opacity' } ).set( 0 ); },
         onShow        : function() { this.fx.start( 1 ) },
         showDelay     : 666 } );

      if (opt.statusUpdPeriod && !opt.popup)
         this.statusUpdater.periodical( opt.statusUpdPeriod, this );

      var el; if (first_field && (el = $( first_field ))) el.focus();
   },

   rebuild: function() {
      this.collection.each( function( object ) { object.build() } );
   },

   resize: function() {
      var opt = this.options, h = window.getHeight(), w = window.getWidth();

      if (! opt.popup) {
         this.cookies.set( 'height', h ); this.cookies.set( 'width',  w );
      }

      var content; if (! (content = $( opt.contentId ))) return;

      var foot_height = 0, margin_bottom = opt.minMarginBottom;

      var footer; if (footer = $( 'footerDisp' )) {
         foot_height = footer.isDisplayed()
                     ? footer.getStyle( 'height' ).toInt() : 0;
         margin_bottom += foot_height;
      }

      var append; if (append = $( 'appendDisp' )) {
         margin_bottom += append.getStyle( 'height' ).toInt();

         if (footer) append.setStyle( 'marginBottom', foot_height + 'px' );
      }

      content.setStyle( 'marginBottom', margin_bottom + 'px' );

      var sb = this.sidebar, margin_left = opt.minMarginLeft;

      if (sb) { sb.resize(); margin_left = sb.getWidth() }

      content.setStyle( 'marginLeft', margin_left + 'px' );

      var buttons = $( 'buttonDisp' ), margin_right = opt.minMarginRight;

      if (buttons) margin_right = buttons.getStyle( 'width' ).toInt();

      content.setStyle( 'marginRight', margin_right + 'px' );
      content.fireEvent( 'resize' );
   },

   _restoreStateFromCookie: function() {
      /* Use state cookie to restore the visual state of the page */
      var cookie_str; if (! (cookie_str = this.cookies.get())) return;

      var cookies = cookie_str.split( '+' ), el;

      for (var i = 0, cl = cookies.length; i < cl; i++) {
         if (! cookies[ i ]) continue;

         var pair = cookies[ i ].split( '~' );
         var p0   = unescape( pair[ 0 ] ), p1 = unescape( pair[ 1 ] );

         /* Restore the state of any elements whose ids end in Disp */
         if (el = $( p0 + 'Disp' )) { p1 != 'false' ? el.show() : el.hide(); }
         /* Restore the className for elements whose ids end in Icon */
         if (el = $( p0 + 'Icon' )) { if (p1) el.className = p1; }
         /* Restore the source URL for elements whose ids end in Img */
         if (el = $( p0 + 'Img'  )) { if (p1) el.src = p1; }
      }
   },

   statusUpdater: function() {
      var h = window.getHeight(), w = window.getWidth();

      var swatch_time = Date.swatchTime();

      window.defaultStatus = 'w: ' + w + ' h: ' + h + ' @' + swatch_time;
   }
} );
