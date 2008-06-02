/* $Id$ */

var State = new Class({
   options: {
      accordion : null,
      cookies   : null,
      linkFade  : null,
      scroller  : false,
      tips      : null
   },

   initialize: function( options ) {
      this.setOptions( options );
      this.cookies   = new Cookies( { path  : options.path,
                                      prefix: options.prefix } );
   },

   getAccordionHeight: function( elem ) {
      var togglers_len = $$( 'div.sideBarHeader' ).length;
      var height       = elem.getSize().size.y - ( 25 * togglers_len ) - 15;
      return Math.max( 1, height );
   },

   resize: function() {
      var append, content, elem, elemHeight, elemWidth, height = 5;
      var h = window.getHeight(), w = window.getWidth();

      this.cookies.set( 'width',  w );
      this.cookies.set( 'height', h );
      window.defaultStatus = 'w: ' + w + ' h: ' + h;

      if (! (content = $( 'content' ))) return;

      if (elem = $( 'footerDisp' )) {
         elemHeight = elem.getStyle( 'height' ).toInt();
         height    += elem.getStyle( 'display' ) != 'none' ? elemHeight : 0;
      }

      if (append = $( 'append' )) {
         height += append.getStyle( 'height' ).toInt();

         if (elem = $( 'footerDisp' )) {
            if (elem.getStyle( 'display' ) != 'none') {
               elemHeight = elem.getStyle( 'height' ).toInt();
               append.setStyle( 'marginBottom', elemHeight + 'px' );
            }
            else { append.setStyle( 'marginBottom', '0px' ) }
         }
      }

      content.setStyle( 'marginBottom', height + 'px' );

      if (elem = $( 'sideBarDisp' )) {
         elem.setStyle( 'marginBottom', height + 'px' );

         if (this.accordion) {
            this.accordion.resize( this.getAccordionHeight( elem ), null );
         }

         if (elem.getStyle( 'display' ) != 'none') {
            elemWidth = elem.getStyle( 'width' ).toInt();
            content.setStyle( 'marginLeft', elemWidth + 'px' );
            if (this.accordion) this.accordion.reload();
         }
         else { content.setStyle( 'marginLeft', '0px' ) }
      }
      else { content.setStyle( 'marginLeft', '0px' ) }

      if (elem = $( 'buttonDisp' )) {
         elemWidth = elem.getStyle( 'width' ).toInt();
         content.setStyle( 'marginRight', elemWidth + 'px' );
      }
      else { content.setStyle( 'marginRight', '0px' ) }

      return;
   },

   setState: function( first_fld ) {
      var cookie_ref, cookies, elem, height, i, p0, p1, pair, sbs = false;

      /* Initialize the fading links event handlers */
      this.linkFade  = new LinkFader( { links: document.links,
                                        view : document.defaultView } );

      /* Use state cookie to restore the visual state of the page */
      if (cookie_ref = this.cookies.get()) {
         cookies = cookie_ref.split( '+' );

         for (i = 0; i < cookies.length; i++) {
            if (cookies[i]) {
               pair = cookies[i].split( '~' );
               p0 = unescape( pair[0] );
               p1 = unescape( pair[1] );

               /* Restore state of any checkboxes whose ids end in Box */
               if (elem = $( p0 + 'Box' )) {
                  elem.checked = (p1 == 'true' ? true : false);
               }

               /* Restore the state of any elements whose ids end in Disp */
               if (elem = $( p0 + 'Disp' )) {
                  elem.setStyle( 'display', (p1 != 'false' ? '' : 'none') );
               }

               /* Restore the source URL for elements whose ids end in Img */
               if (elem = $( p0 + 'Img' )) { if (p1) elem.src = p1; }

               /* Remember the state of the sidebar being open or closed */
               if (p0 == 'sideBar') sbs = true;
            }
         }
      }

      if (elem = $( 'sideBarDisp' )) {
         height = this.getAccordionHeight( elem );

         this.accordion
            = new Accordion( 'div.sideBarHeader', 'div.sideBarPanel', {
               fixedHeight : height,
               opacity     : false,
               onActive    : function(toggler, element){
                  toggler.setStyle( 'background-color', '#663' );
                  toggler.setStyle( 'color', '#FFC' );
               },
               onBackground: function(toggler, element){
                  toggler.setStyle( 'background-color', '#CC9' );
                  toggler.setStyle( 'color', '#000' );
               }
            }, $( 'accordionDiv' ));

         if (sbs == false) elem.setStyle( 'display', 'none' );
      }

      this.tips = new Tips( $$( '.tips' ), { showDelay: 666 } );

      if (this.scroller) {
         this.scroller
            = new Scroller( 'content', { area: 150, velocity: 1 });

         $( 'content' ).addEvent( 'mousedown', function() {
            this.setStyle( 'cursor',
                           'url(/static/images/closedhand.cur), move' );
            this.scroller.start();
         } );

         $( 'content' ).addEvent( 'mouseup', function() {
            this.setStyle( 'cursor',
                           'url(/static/images/openhand.cur), move' );
            this.scroller.stop();
         } );
      }

      this.resize();

      if (first_fld) $( first_fld ).focus();
   },

   Toggle: function( e ) {
      var elem = $( e.id + 'Disp' );

      if (elem.getStyle( 'display' ) != 'none') {
         elem.setStyle( 'display', 'none' ); this.cookies.delete( e.id );
      }
      else {
         elem.setStyle( 'display', '' ); this.cookies.set( e.id, true );
      }

      this.resize();
   },

   ToggleState: function( id ) {
      var elem = $( id + 'Box' );

      this.cookies.set( id, (elem.checked ? 'true' : 'false') );
   },

   ToggleSwap: function( e, s1, s2 ) {
      var elem;

      if (elem = $( e.id + 'Disp' )) {
         if (elem.getStyle( 'display' ) !=  'none') {
            elem.setStyle( 'display', 'none' );
            this.cookies.delete( e.id );

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

   ToggleSwapImg: function( e, s1, s2 ) {
      var elem;

      if (elem = $( e.id + 'Disp' )) {
         if (elem.getStyle( 'display' ) != 'none') {
            elem.setStyle( 'display', 'none' );
            this.cookies.delete( e.id );

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

   ToggleSwapText: function( id, cookie, s1, s2 ) {
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
});

State.implement( new Options );

function Expand_Collapse() {}

var freeListObj = new FreeList();
var loadMoreObj = new LoadMore(      { url   : url } );
var serverObj   = new ServerMethods( { url   : url } );
var stateObj    = new State(         { path  : sessionPath,
                                       prefix: sessionPrefix } );
var submitObj   = new SubmitUtils(   { path  : sessionPath,
                                       prefix: sessionPrefix } );
var tableObj    = new TableUtils(    { url   : url } );
var windowObj   = new WindowUtils(   { path  : sessionPath,
                                       prefix: sessionPrefix } );

if (target && target == 'top') windowObj.placeOnTop();

onresize = stateObj.resize();
