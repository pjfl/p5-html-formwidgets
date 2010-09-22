/* $Id$ */

var Behaviour = new Class( {
   Implements: [ Events, Options ],

   options            : {
      config          : {
         anchors      : {},
         calendars    : {},
         scrollPins   : { fadeInDuration: 1500,  showDelay: 1000,
                          trayPadding   : 0 },
         server       : {},
         sidebars     : {},
         sliders      : {},
         tabSwappers  : {
            defaults  : { smooth        : true,  smoothSize: true } },
         tips         : { fadeInDuration: 500,   showDelay : 666  } },
      cookiePath      : '/',
      cookiePrefix    : 'behaviour',
      formName        : null,
      minContentHeight: 5,
      onStateComplete : $empty,
      popup           : false,
      target          : null,
      url             : null
   },

   initialize: function( options ) {
      this.setOptions( options ); var opt = this.options;

      this.config  = $merge( opt.config );
      this.cookies = new Cookies( { path  : opt.cookiePath,
                                    prefix: opt.cookiePrefix } );

      window.addEvent( 'load',   function() {
         this.load( options.firstField ) }.bind( this ) );
      window.addEvent( 'resize', function() {
         this.resize( true ) }.bind( this ) );
   },

   load: function( firstField ) {
      var cfg = this.config, el, opt = this.options;

      this.stylesheet  = new PersistantStyleSheet( { cookies: this.cookies } );
      this._restoreFromCookie();
      this.checkboxReplacements = new CheckboxReplace();

      var f_replace_boxes = function() {
         this.build() }.bind( this.checkboxReplacements );

      this.submit      = new SubmitUtils( {
         config        : cfg.anchors,
         formName      : opt.formName,
         cookiePath    : opt.cookiePath,
         cookiePrefix  : opt.cookiePrefix } );
      this.window      = new WindowUtils( {
         config        : cfg.anchors,
         path          : opt.cookiePath,
         prefix        : opt.cookiePrefix,
         target        : opt.target } );

      this.autosizer   = new AutoSize();
      this.calendars   = new Calendars( {
         config        : cfg.calendars,
         submit        : this.submit } );
      this.freeList    = new FreeList();
      this.groupMember = new GroupMember();
      this.loadMore    = new LoadMore( this, opt.url );
      this.server      = new ServerUtils( {
            config     : cfg.server,
            url        : opt.url } );
      this.sidebar     = new Sidebar ( this, { config: cfg.sidebars } );
      this.sliders     = new Sliders( {
         config        : cfg.sliders,
         submit        : this.submit } );
      this.tables      = new TableUtils( {
         formName      : opt.formName,
         onRowAdded    : f_replace_boxes,
         onSortComplete: f_replace_boxes,
         url           : opt.url } );
      this.tabSwappers = new TabSwappers( {
         config        : cfg.tabSwappers,
         cookiePath    : opt.cookiePath,
         cookiePrefix  : opt.cookiePrefix } );
      this.togglers    = new Togglers( this, { config: cfg.anchors } );
      this.trees       = new Trees( {
         cookiePath    : opt.cookiePath,
         cookiePrefix  : opt.cookiePrefix } );
      this.wysiwyg     = new WYSIWYG();
      this.linkFade    = new LinkFader();

      this.resize();

      this.columnizers = new Columnizers();
      this.scrollPins  = new ScrollPins( {
         config        : cfg.scrollPins,
         debug         : true,
         log           : this.window.log,
         onAttach      : function( el ) {
            this.addEvent( 'build', function() {
               this.set( 'opacity', 0 )
                   .set( 'tween', { duration: cfg.scrollPins.fadeInDuration } );
            }.bind( el.pin.markup ) );

            this.addEvent( 'show', function() {
               this.tween( 'opacity', 1 ) }.bind( el.pin.markup ) );
         },
         onInitialize  : function() {
            this.fireEvent.delay( cfg.scrollPins.showDelay, this, [ 'show' ] ) }
      } );
      this.tips        = new Tips( {
         onHide        : function() { this.fx.start( 0 ) },
         onInitialize  : function() {
            this.fx    = new Fx.Tween( this.tip, {
               duration: cfg.tips.fadeInDuration,
               property: 'opacity' } ).set( 0 ); },
         onShow        : function() { this.fx.start( 1 ) },
         showDelay     : cfg.tips.showDelay } );

      this.fireEvent( 'load' );

      if (firstField && (el = $( firstField ))) el.focus();
   },

   resize: function( changed ) {
      var append, content, footer, foot_height = 0, opt = this.options;
      var h = window.getHeight(), w = window.getWidth();
      var height = opt.minContentHeight;

      if (! opt.popup) {
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
      content.fireEvent( 'resize' );
   },

   _restoreFromCookie: function() {
      /* Use state cookie to restore the visual state of the page */
      var cookie_str; if (! (cookie_str = this.cookies.get())) return;

      var cookies = cookie_str.split( '+' ), el;

      for (var i = 0, cl = cookies.length; i < cl; i++) {
         if (! cookies[ i ]) continue;

         var pair = cookies[ i ].split( '~' );
         var p0   = unescape( pair[ 0 ] );
         var p1   = unescape( pair[ 1 ] );

         /* Deprecated */
         /* Restore state of any checkboxes whose ids end in Box */
         if (el = $( p0 + 'Box' )) el.checked = (p1 == 'true' ? true : false);

         /* Restore the state of any elements whose ids end in Disp */
         if (el = $( p0 + 'Disp' ))
            el.setStyle( 'display', (p1 != 'false' ? '' : 'none') );

         /* Restore the className for elements whose ids end in Icon */
         if (el = $( p0 + 'Icon' )) { if (p1) el.className = p1; }

         /* Restore the source URL for elements whose ids end in Img */
         if (el = $( p0 + 'Img' )) { if (p1) el.src = p1; }
      }
   }
} );

/* Local Variables:
 * mode: javascript
 * tab-width: 3
 * End:
 */
