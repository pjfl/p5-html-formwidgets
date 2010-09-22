/* @(#)$Id: 15html-formwidgets.js 1069 2010-09-04 22:23:22Z pjf $

   Portions of this code are taken from MooTools 1.2 which is:
   Copyright (c) 2006-2008 [Valerio Proietti](http://mad4milk.net/).
*/

Options.implement( {
   build: function() {
      var selector = this.options.selector;

      if (selector) $$( selector ).each( function( el ) {
         if (! this.collection.contains( el )) {
            this.collection.include( el );
            this.attach( el );
         }
      }, this );
   },

   setBuildOptions: function( options ) {
      options         = options || {};
      this.debug      = options.debug || false;  delete options[ 'debug' ];
      this.log        = options.log   || $empty; delete options[ 'log'   ];
      this.collection = [];

      return this.setOptions( options );
   },
} );

String.implement( {
   escapeHTML: function() {
      var text = this;
      text = text.replace( /\</g, '&lt;'   );
      text = text.replace( /\>/g, '&gt;'   );
      text = text.replace( /\"/g, '&quot;' );
      text = text.replace( /\&/g, '&amp;'  );
      return text;
   },

   unescapeHTML: function() {
      var text = this;
      text = text.replace( /\&lt\;/g,   '<' );
      text = text.replace( /\&gt\;/g,   '>' );
      text = text.replace( /\&quot\;/g, '"' );
      text = text.replace( /\&amp\;/g,  '&' );
      return text;
   }
} );

/*

Description: An Fx.Elements extension which allows you to easily
             create accordion type controls.

License: MIT-style license.

Authors: Valerio Proietti, Peter Flanigan

Class: Accordion
   The Accordion class creates a group of elements that
   are toggled when their handles are clicked. When one elements
   toggles in, the others toggles back.  Inherits methods, properties,
   options and events from <Fx.Elements>.

Arguments:
   togglers - required, a collection of elements, the elements handlers
              that will be clickable.
   elements - required, a collection of elements the transitions will
              be applied to.
   options  - optional, see options below, and <Fx.Base> options and events.

Options:
   show - integer, the Index of the element to show at start.
   display - integer, the Index of the element to show at start (with
             a transition). defaults to 0.
   fixedHeight - integer, if you want the elements to have a fixed
                 height. defaults to false.
   fixedWidth - integer, if you want the elements to have a fixed
                width. defaults to false.
   height - boolean, will add a height transition to the accordion if
            true. defaults to true.
   opacity - boolean, will add an opacity transition to the accordion
             if true. defaults to true.
   width - boolean, will add a width transition to the accordion if
           true. defaults to false, css mastery is required to make this work!
   alwaysHide - boolean, will allow to hide all elements if true,
                instead of always keeping one element shown. defaults to false.
Events:
   onActive - function to execute when an element starts to show
   onBackground - function to execute when an element starts to hide
*/

Fx.Accordion = new Class( {
   Extends: Fx.Elements,

   options              : {
      alwaysHide        : false,
      display           : 0,
      fixedHeight       : false,
      fixedWidth        : false,
      height            : true,
      initialDisplayFx  : true,
      onActive          : Class.empty,
      onBackground      : Class.empty,
      opacity           : true,
      returnHeightToAuto: true,
      show              : false,
      trigger           : 'click',
      wait              : false,
      width             : false
   },

   initialize: function() {
      var params = Array.link( arguments, {
         'container': Element.type,
         'options'  : Object.type,
         'togglers' : $defined,
         'elements' : $defined
      } );

      this.parent( params.elements, params.options );
      this.togglers      = $$( params.togglers );
      this.container     = params.container;
      this.internalChain = new Chain();
      this.previous      = -1;
      this.effects       = {};

      var opt = this.options;

      if (opt.alwaysHide) opt.wait = true;

      if ($chk( opt.show )) {
         opt.display = false; this.previous = opt.show;
      }

      if (opt.start) { opt.display = false; opt.show = false; }

      if (opt.opacity) this.effects.opacity = 'fullOpacity';

      if (opt.width) {
         this.effects.width = opt.fixedWidth ? 'fullWidth' : 'offsetWidth';
      }

      if (opt.height) {
         this.effects.height = opt.fixedHeight ? 'fullHeight' : 'scrollHeight';
      }

      for (var i = 0, l = this.togglers.length; i < l; i++) {
         var toggler = this.togglers[ i ];

         if (i == 0) toggler.addClass( 'accordion_header_first' );

         this.addSection( toggler, this.elements[ i ] );
      }

      this.elements.each( function( el, i ) {
         if (opt.show === i) {
            this.fireEvent( 'active', [ this.togglers, i , el ] );
         } else {
            for (var fx in this.effects) el.setStyle( fx, 0 );
         }
      }, this );

      if ($chk( opt.display ) || opt.initialDisplayFx === false)
         this.display( opt.display, opt.initialDisplayFx );

      if (opt.fixedHeight !== false) opt.returnHeightToAuto = false;

      this.addEvent( 'complete',
                     this.internalChain.callChain.bind( this.internalChain ) );
   },

   /*
   Property: addSection
      Dynamically adds a new section into the accordion at the
      specified position.

   Arguments:
      toggler - (dom element) the element that toggles the accordion
                section open.
      element - (dom element) the element that stretches open when the
                toggler is clicked.
      pos     - (integer) the index where these objects are to be inserted
                within the accordion.
   */

   addSection: function( toggler, el, pos ) {
      toggler = $( toggler ); el = $( el );

      var test = this.togglers.contains( toggler );
      var len  = this.togglers.length;

      if (len && (! test || pos)) {
         pos = $pick( pos, len - 1 );

         toggler.injectBefore( this.togglers[ pos ] );
         el.injectAfter( toggler );
      }
      else if (this.container && ! test){
         toggler.inject( this.container ); el.inject( this.container );
      }

      this.togglers.include( toggler ); this.elements.include( el );

      var idx       = this.togglers.indexOf( toggler );
      var displayer = this.display.bind( this, idx );
      var opt       = this.options;

      toggler.store( 'accordion:display', displayer );
      toggler.addEvent( opt.trigger, displayer );

      if (opt.height) el.setStyles( { 'padding-top': 0, 'padding-bottom': 0 } );

      if (opt.width) el.setStyles( { 'padding-left': 0, 'padding-right': 0 } );

      if (opt.fixedWidth) {
         el.fullWidth = opt.fixedWidth; el.setStyle( 'overflow-x', 'auto' );
      }
      else { el.setStyle( 'overflow-x', 'hidden' ) }

      if (opt.fixedHeight) {
         el.fullHeight = opt.fixedHeight; el.setStyle( 'overflow-y', 'auto' );
      }
      else { el.setStyle( 'overflow-y', 'hidden' ) }

      if (! test) {
         for (var fx in this.effects) el.setStyle( fx, 0 );
      }

      el.fullOpacity = 1;
      return this;
   },

   detach: function() {
      this.togglers.each( function( toggler ) {
         toggler.removeEvent( this.options.trigger,
                              toggler.retrieve( 'accordion:display' ) );
      }, this );
   },

   /*
   Property: display
      Shows a specific section and hides all others. Useful when
      triggering an accordion from outside.

   Arguments:
      index - integer, the index of the item to show, or the actual
              element to show.
   */

   display: function( index, useFx ) {
      if (! this.check( index, useFx ) ) return this;

      useFx = $pick( useFx, true ); var obj = {}, opt = this.options;

      if (opt.returnHeightToAuto) {
         var prev = this.elements[ this.previous ];

         if (prev && ! this.selfHidden) {
            for (var fx in this.effects) {
               prev.setStyle( fx, prev[ this.effects[ fx ] ] );
            }
         }
      }

      index = $type( index ) == 'element'
            ? this.elements.indexOf( index ) : index;

      if (index >= this.elements.length) index = 0;

      if ((this.timer && opt.wait)
          || (index === this.previous && ! opt.alwaysHide)) return this;

      this.previous = index;

      this.elements.each( function( el, i ) {
         var hide = false; obj[ i ] = {};

         if (i != index) {
            hide = true;
         } else if (opt.alwaysHide
                    && ((el.offsetHeight > 0 && opt.height)
                      || el.offsetWidth  > 0 && opt.width)) {
            hide = this.selfHidden = true;
         }

         this.fireEvent( hide ? 'background' : 'active',
                         [ this.togglers, i,  el ] );

         for (var fx in this.effects)
            obj[ i ][ fx ] = hide ? 0 : el[ this.effects[ fx ] ];
      }, this );

      this.internalChain.chain( function() {
         if (opt.returnHeightToAuto && ! this.selfHidden) {
            var el = this.elements[ index ];

            if (el) el.setStyle( 'height', 'auto' );
         };
      }.bind(this) );

      return useFx ? this.start( obj ) : this.set( obj );
   },

   redisplay: function( useFx ) {
      var index = this.previous; this.previous = -1;

      return this.display( index, useFx );
   },

   reload: function( index ) {
      if (! index || index >= this.togglers.length) index = 0;

      var toggler = this.togglers[ index ];

      if ($defined( toggler )) toggler.fireEvent( this.options.trigger );
   },

   resize: function( height, width ) {
      this.elements.each( function( el ) {
         if (height) el.fullHeight = this.options.fixedHeight = height;
         if (width)  el.fullWidth  = this.options.fixedWidth  = width;
      }, this );

      return this.redisplay();
   }
} );

var AutoSize = new Class( {
   Implements: [ Events, Options ],

   options      : {
      animate   : true,       // animate transition or just set new height
      duration  : 1000,       // time taken to animate height change in ms
      interval  : 1100,       // update interval in milliseconds
      margin    : 30,         // gap (in px) to maintain between last line
                              // of text and bottom of textarea
      max_y     : 1000,       // maximum height of textarea
      min_y     : 48,         // minimum height of textarea
/*    onResize  : $emtpy,   */// fire this event when resize method called
/*    onComplete: $empty,   */// fire this event when animation complete
      selector  : '.autosize' // element class to search for
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      var auto_size = {}, opt = this.options, styles = el.getStyles
      ( 'font-family', 'font-size', 'letter-spacing',
        'line-height', 'padding',   'text-decoration', 'width' );

      auto_size.clone   = new Element( 'textarea', {
         styles         : {
            'overflow-y': 'hidden',
            'position'  : 'absolute',
            'top'       : '0px',
            'left'      : '-9999px' },
         tabIndex       : -1
      } ).setStyles( styles ).inject( el, 'before' );
      auto_size.element = el;
      auto_size.fx      = new Fx.Tween( el, {
         duration       : opt.duration,
         onComplete     : function() {
            if (opt.onComplete) opt.onComplete.call( this, auto_size ); },
         property       : 'height',
         transition     : Fx.Transitions.linear } );
      auto_size.min_y   = Math.max( el.getSize().y, opt.min_y );

      this.resize.periodical( opt.interval, this, auto_size );
   },

   resize: function( auto_size ) {
      var clone = auto_size.clone, el = auto_size.element;

      clone.setStyle( 'height', 0 ).value = el.value; clone.scrollTop = 10000;

      var opt = this.options, new_y = clone.getScroll().y + opt.margin;

      new_y = Math.min( Math.max( new_y, auto_size.min_y ), opt.max_y );

      if (el.clientHeight == new_y) return;

      if (opt.animate) auto_size.fx.start( new_y );
      else el.setStyle( 'height', new_y );

      this.fireEvent( 'resize', [ auto_size ] );
   }
} );

var Calendars = new Class( {
   Implements: [ Options ],

   options    : {
      config  : {},
      selector: '.calendars',
      submit  : $empty
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      var button, cfg, opt = this.options, submit = opt.submit;

      if (! (cfg = opt.config[ el.id ])) return;

      if (submit && (button = $( el.id + '_clear' )))
         button.addEvent( 'click', function() {
            submit.clearField( el.id ) } );

      Calendar.setup( $extend( cfg, {
         inputField: el.id, button: el.id + '_trigger' } ) );
   }
} );

var CheckboxReplace = new Class( {
   Implements: [ Options ],

   options               : {
      checkboxSelector   : 'input[type=checkbox]',
      radiobuttonSelector: 'input[type=radio]',
      suffix             : '_replacement'
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   build: function() {
      var opt = this.options;

      [ opt.checkboxSelector, opt.radiobuttonSelector ]
         .each( function( selector ) {
            if (selector) $$( selector ).each( function( el ) {
               this.collection.include( el );
               this.attach( el );
            }, this );
         }, this );
   },

   attach: function( el ) {
      var handler, replacement = this.getReplacement( el );

      if (! (handler = replacement.retrieve( 'click' )))
         replacement.store( 'click', handler = this.toggle.bind( this, el ) );

      replacement.addEvent( 'click', handler );
   },

   getReplacement: function( el ) {
      var new_id = el.name
                 + (el.type == 'checkbox' ? '' : el.value)
                 + this.options.suffix;

      var replacement; if (replacement = $( new_id )) return replacement;

      el.setStyles( { position: 'absolute', left: '-9999px' } );

      return new Element( 'span', {
         'class': 'checkbox' + (el.checked ? ' checked' : ''),
         id     : new_id,
         name   : el.name
      } ).inject( el, 'after' );
   },

   toggle: function( el ) {
      if (el.getProperty( 'disabled' )) return;

      var replacement = this.getReplacement( el );

      replacement.toggleClass( 'checked' );

      if (replacement.hasClass( 'checked' )) {
         el.setProperty( 'checked', 'checked' );

         if (el.type == 'radio') {
            this.collection.each( function( box ) {
               replacement = this.getReplacement( box );

               if (box != el && box.name == el.name
                   && replacement.hasClass( 'checked' )) {
                  replacement.removeClass ( 'checked' );
                  box.removeProperty( 'checked' );
               }
            }.bind( this ) );
         }
      }
      else el.removeProperty( 'checked' );
   }
} );

/* Originally created by: Adam Wulf adam.wulf@gmail.com Version 1.4.0
 * http://welcome.totheinter.net/columnizer-jquery-plugin/
 */

var Columnizer = new Class( {
   Implements: [ Events, Options ],

   options     : {
      accuracy : false,
      // true to build columns once regardless of window resize
      // false to rebuild when content box changes bounds
      buildOnce : false,
      // Percentage left + right padding in CSS for column class
      columnPadding : 1.5,
      // optional # of columns instead of width
      columns : false,
      // this function is called after content is columnized
      // should columns float left or right
      float : 'left',
      height : false,
      // re-columnizing when images reload might make things
      // run slow. so flip this to true if it's causing delays
      ignoreImageLoading : true,
      // ensure the last column is never the tallest column
      lastNeverTallest : false,
      // an object with options if the text should overflow
      // it's container if it can't fit within a specified height
      overflow : false,
      // if the content should be columnized into a
      // container node other than it's own node
      target : false,
      // default width of columnx
      width : 400
   },

   initialize: function( el, options ) {
      el = $( el );

      if (options.columns && $type( options.columns ) != 'number')
         options.columns = null;

      this.setOptions( options ); var opt = this.options;
      // this is where we'll put the real content
      this.cache = new Element( 'div' );
      this.cache.adopt( el.getChildren().clone() );
      this.node  = $( opt.target || el );

      if (! this.node.data) this.node.data = new Hash( { lastWidth: 0 } );

      // images loading after dom load can screw up the column heights,
      // so recolumnize after images load
      if (! opt.ignoreImageLoading && ! opt.target) {
         if (! this.node.data.get( 'imageLoaded' )) {
            this.node.data.set( 'imageLoaded', true );

            var images = el.getElements( 'img' );

            if (images.length > 0) {
               // only bother if there are actually images...
               var func = function( obj, el, images ) {
                  return function() {
                     if (! this.node.data.get( 'firstImageLoaded' )) {
                        this.node.data.set( 'firstImageLoaded', true );
                        new Columnizer( el, this.options ); // Recurse
                        images.removeEvent( 'abort', func );
                        images.removeEvent( 'load',  func );
                     }
                  }.bind( obj );
               }(this, el, images);

               images.addEvents( { abort: func, load: func } );
               return;
            }
         }
      }

      this.build();

      if (! opt.buildOnce)
         window.addEvent( 'resize', function() { this.build() }.bind( this ) );
   },

   build: function() {
      var data = this.node.data, size = this.node.getSize();

      if (data.get( 'lastWidth' ) == size.x || data.get( 'columnizing' ))
         return;

      data.set( 'lastWidth', size.x ); data.set( 'columnizing', true );

      var options = this.options;
      var numCols = options.columns
                  ? options.columns : Math.round( size.x / options.width );

      if (numCols <= 1) return this.singleColumnize();

      var maxLoops     = 3;
      var horizontal   = false;
      var padding      = options.columnPadding;
      var width        = (100 - (2 * padding * numCols)) / numCols;
      var style        = { float  : options.float,
                           padding: '0px ' + padding + '% 0px ' + padding + '%',
                           width  : Math.floor( width ) + '%' };
      var targetHeight = size.y / numCols;

      if (options.overflow) {
         maxLoops     = 1;
         targetHeight = options.overflow.height;
      }
      else if (options.height && options.width) {
         maxLoops     = 1;
         horizontal   = true;
         targetHeight = options.height;
      }

      for (var loopCount = 0; loopCount < maxLoops; loopCount++) {
         var destroyable = this.cache.clone();

         this.node.empty(); destroyable.setOpacity( 0 ); // Hide

         // create the columns
         for (var i = 0; i < numCols; i++) {
            var className = (i == 0) ? 'column first' : 'column';
            var className = (i == numCols - 1)
                          ? (className + ' last') : className;
            var el = new Element( 'div', { class: className, styles: style } );

            el.injectInside( this.node );
         }

         // fill all but the last column (unless overflowing)
         var i = 0;

         while (i < numCols - (options.overflow ? 0 : 1)
                || horizontal && destroyable.childNodes.length) {
            if (this.node.childNodes.length <= i) {
               // we ran out of columns, make another
               var el = new Element( 'div',
                                     { class: className, styles: style } );

               el.injectInside( this.node );
            }

            var col = $( this.node.childNodes[ i ] );

            this.columnize( col, destroyable, col, targetHeight );

            // make sure that the last item in the column isn't a 'dontend'
            if (! $( destroyable.firstChild ).hasClass( 'dontend' ))
               this.split( col, destroyable, col, targetHeight );

            while (this.checkDontEndColumn( col.lastChild )) {
               var para = $( col.lastChild );

               para.dispose(); para.injectTop( destroyable );
            }

            i++;
         }

         var columns = this.node.getChildren();

         if (options.overflow && ! horizontal) {
            var overflow = $( options.overflow.id );
            var kids     = destroyable.getChildren();

            overflow.empty().adopt( kids.clone() );
         }
         else if (! horizontal) {
            // the last column in the series
            var col = columns.getLast();

            while (destroyable.childNodes.length ) {
               col.appendChild( destroyable.childNodes[ 0 ] );
            }

            var lastIsMax = false;
            var max       = 0;
            var min       = 10000000;
            var totalH    = 0;

            columns.each( function( col ) {
               var h = col.getSize().y; lastIsMax = false; totalH += h;

               if (h > max) { max = h; lastIsMax = true; }
               if (h < min) { min = h; }
            } );

            var avgH = totalH / numCols;

            if (options.lastNeverTallest && lastIsMax) {
               // the last column is the tallest so allow columns
               // to be taller and retry
               targetHeight += 30;

               if (loopCount == maxLoops - 1) maxLoops++;
            }
            else if (max - min > 30) {
               targetHeight = avgH + 30; // too much variation, try again
            }
            else if (Math.abs( avgH - targetHeight ) > 20) {
               targetHeight = avgH; // too much variation, try again
            }
            else {
               loopCount = maxLoops; // solid, we're done
            }
         }
         else {
            // it's scrolling horizontally, fix width/classes of the columns
            columns.each( function( col, i ) {
               col.width( this.options.width + 'px' );

               if (i == 0) {
                  col.addClass( 'first' );
               }
               else if (i == this.node.childNodes.length - 1) {
                  col.addClass( 'last' );
               }
               else {
                  col.removeClass( 'first' );
                  col.removeClass( 'last' );
               }
            }.bind( this ) );

            this.node.width( (columns.length * options.width) + 'px' );
         }

         var el = new Element( 'br', { styles: { clear: 'both' }  } );

         el.injectInside( this.node );
      }

      this.node.data.set( 'columnizing', false );

      if (options.overflow) options.overflow.fireEvent( 'complete' );

      this.fireEvent( 'complete' );
   },

   checkDontEndColumn: function( el ) {
      el = $( el );

      if (! $defined( el ))          return false;
      if ($type( el ) != 'element')  return false;
      if (el.hasClass( 'dontend' ))  return true;
      if (el.childNodes.length == 0) return false;

      return this.checkDontEndColumn( el.lastChild );
   },

   columnize: function( putInHere, pullOutHere, parentColumn, height ) {
      while (parentColumn.getSize().y < height
             && pullOutHere.childNodes.length ) {
         putInHere.appendChild( pullOutHere.childNodes[ 0 ] );
      }

      if (putInHere.childNodes.length == 0) return;

      // now we're too tall, undo the last one
      var kids = putInHere.childNodes, kid = kids[ kids.length - 1 ];

      putInHere.removeChild( kid );

      var is_textnode = $type( kid ) == 'textnode'
                     || $type( kid ) == 'whitespace';

      if (is_textnode) {
         // it's a text node, split it up
         var oText    = kid.nodeValue;
         var counter2 = this.options.accuracy
                      ? this.options.accuracy : this.options.width / 18;
         var columnText, latestTextNode = null;

         while (parentColumn.getSize().y < height && oText.length) {
            if (oText.indexOf( ' ', counter2 ) != '-1')
               columnText = oText.substring( 0, oText.indexOf( ' ', counter2));
            else columnText = oText;

            latestTextNode = document.createTextNode( columnText );
            putInHere.appendChild( latestTextNode );

            if (oText.length > counter2)
               oText = oText.substring( oText.indexOf( ' ', counter2 ) );
            else oText = '';
         }

         if (parentColumn.getSize().y >= height
             && latestTextNode != null) {
            // too tall :(
            putInHere.removeChild( latestTextNode );
            oText = latestTextNode.nodeValue + oText;
         }

         if (oText.length) kid.nodeValue = oText;
         else return false; // we ate the whole text node, move on
      }


      if (pullOutHere.childNodes.length)
         pullOutHere.insertBefore( kid, pullOutHere.firstChild );
      else pullOutHere.appendChild( kid );

      return is_textnode;
   },

   singleColumnize: function() {
      var options = this.options;
      var style   = { float: options.float, padding: '0px 1.5%', width: '97%' };
      var col     = new Element( 'div', { class : 'column first last',
                                           styles: style } );

      this.node.empty(); col.injectInside( this.node );

      if (options.overflow) {
         var destroyable  = this.cache.clone();
         var targetHeight = options.overflow.height;

         this.columnize( col, destroyable, col, targetHeight );

         // make sure that the last item in the column isn't a 'dontend'
         if (! $( destroyable.firstChild ).hasClass( 'dontend' ))
            this.split( col, destroyable, col, targetHeight );

         while (this.checkDontEndColumn( col.lastChild )) {
            var para = $( col.lastChild );

            para.dispose(); para.injectTop( destroyable );
         }

         var overflow = $( options.overflow.id ).empty();

         while ($defined( destroyable.firstChild )) {
            var para = $( destroyable.firstChild );

            para.dispose(); para.injectInside( overflow );
         }
      }
      else this.cache.injectInside( col );

      this.node.data.set( 'columnizing', false );

      if (options.overflow) options.overflow.fireEvent( 'complete' );

      this.fireEvent( 'complete' );
   },

   split: function( putInHere, pullOutHere, parentColumn, height ) {
      if (! pullOutHere.childNodes.length) return;

      var cloneMe = pullOutHere.firstChild, clone = cloneMe.clone();

      if (! $type( clone ) == 'element' || clone.hasClass( 'dontend' )) return;

      clone.injectInside( putInHere );

      if (clone.tag == 'img'
          && parentColumn.getSize().y < height + 20) {
         cloneMe.dispose();
      }
      else if (! cloneMe.hasClass( 'dontsplit' )
               && parentColumn.getSize().y < height + 20) {
         cloneMe.dispose();
      }
      else if (clone.tag == 'img' || cloneMe.hasClass( 'dontsplit' )) {
         clone.dispose();
      }
      else {
         clone.empty();

         if (! this.columnize( clone,  cloneMe,  parentColumn, height )
             && cloneMe.childNodes.length) {
            this.split( clone, cloneMe, parentColumn, height ); // Recurse
         }

         if (clone.childNodes.length == 0) {
            // it was split, but nothing is in it :(
            clone.dispose();
         }
      }

      return;
   }
} );

var Columnizers = new Class( {
   Implements   : [ Options ],

   options      : {
      classNames: [ 'zero', 'one', 'two', 'three', 'four', 'five', 'six',
                    'seven', 'eight', 'nine', 'ten', 'eleven', 'twelve',
                    'thirteen', 'fourteen', 'fifteen' ],
      config    : {},
      selector  : '.multiColumn'
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      var opt   = this.options,
          klass = el.getProperty( 'class' ).split( ' ' )[ 0 ],
          cols  = opt.classNames.indexOf( klass ),
          cfg   = $merge( opt.config, { columns: cols } );

      el.columnizer = new Columnizer( el, cfg );
   }
} );

var Cookies = new Class( {
   Implements: [ Options ],

   options  : {
      domain: '',
      expire: 90,
      name  : 'state',
      path  : '/',
      prefix: '',
      secure: false
   },

   initialize: function( options ) {
      this.setOptions( options ); var opt = this.options;

      var cName = (opt.prefix ? opt.prefix + '_' : '') + opt.name;
      var cOpts = { domain: opt.domain, duration: opt.expire,
                    path  : opt.path,   secure  : opt.secure };

      this.cookie = new Cookie( cName, cOpts );
   },

   get: function( name ) {
      var val = this.cookie.read();

      if (name && val) {
         var cookies = val.split( '+' );

         for (var i = 0, cl = cookies.length; i < cl; i++) {
            var pair = cookies[ i ].split( '~' );

            if (unescape( pair[ 0 ] ) == name)
               return pair[ 1 ] != 'null' ? unescape( pair[ 1 ] ) : null;
         }

         return '';
      }

      return val;
   },

   remove: function( name ) {
      var i, val = this.cookie.read();

      if (val && name) name = escape( name );
      else return false;

      if ((i = val.indexOf( name + '~' )) < 0) return false;

      var j = val.substring( i ).indexOf( '+' );

      if (i == 0) val = (j < 0) ? '' : val.substring( j + 1 );

      if (i > 0) {
         val = (j < 0) ? val.substring( 0, i - 1 )
                       : val.substring( 0, i - 1 ) + val.substring( i + j );
      }

      return this.cookie.write( val );
   },

   set: function( name, cookie ) {
      var i, val = this.cookie.read();

      if (name) name = escape( name );
      else return;

      if (cookie) cookie = escape( cookie );

      if (val) {
         if ((i = val.indexOf( name + '~' )) >= 0) {
            var j = val.substring( i ).indexOf( '+' );

            if (i == 0) {
               val = (j < 0) ? name + '~' + cookie
                             : name + '~' + cookie + val.substring( j );
            }
            else {
               val = (j < 0) ? val.substring( 0, i ) + name + '~' + cookie
                             : val.substring( 0, i ) + name + '~' + cookie
                               + val.substring( i + j );
            }
         }
         else { val += '+' + name + '~' + cookie }
      }
      else { val = name + '~' + cookie }

      return this.cookie.write( val );
   }
} );

var FreeList = new Class( {
   Implements: [ Options ],

   options: { selector: 'input.freelist' },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      $( el.id + '_add' ).addEvent( 'click', function( ev ) {
         ev = new Event( ev ); ev.stop(); return this.addItem( el.id );
      }.bind( this ) );

      $( el.id + '_remove' ).addEvent( 'click', function( ev ) {
         ev = new Event( ev ); ev.stop(); return this.removeItem( el.id );
      }.bind( this ) );
   },

   addItem: function( id ) {
      var el = $( id ), list = $( id + '_list' ), options = list.options;

      new Element( 'input', {
         name: id, type: 'hidden', value: el.value
      } ).injectAfter( list );

      options[ options.length ] = new Option( el.value );
      el.value = null;
      el.focus();
      return false;
   },

   removeItem: function( id ) {
      var el = $( id ), list = $( id + '_list' ), options = list.options;

      for (var i = options.length - 1; i >= 0; i--) {
         if (options[ i ].selected != true) continue;

         var value = options[ i ].value;

         $$( 'input[name=' + id + ']' ).some( function( el ) {
            if (el.type == 'hidden' && el.value == value) {
               el.destroy(); return true;
            }

            return false;
         } );

         options[ i ].destroy();
      }

      el.focus();
      return false;
   }
} );

var GroupMember = new Class( {
   Implements: [ Options ],

   options: { selector: 'select.groupmembers' },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      $( el.id + '_add' ).addEvent( 'click', function( ev ) {
         ev = new Event( ev ); ev.stop(); return this.addItem( el.id );
      }.bind( this ) );

      $( el.id + '_remove' ).addEvent( 'click', function( ev ) {
         ev = new Event( ev ); ev.stop(); return this.removeItem( el.id );
      }.bind( this ) );
   },

   addItem: function( id ) {
      var all = $( id ), members = $( id + '_current' );

      for (var i = all.length - 1; i >= 0; i--) {
         if (all.options[ i ].selected != true) continue;

         var value = all.options[ i ].value;

         if (! this.deleteHidden( id + '_deleted', value )) {
            var name = all.name.replace( /^_/g, '' ) + '_added';

            new Element( 'input', {
               name: name, type: 'hidden', value: value
            } ).injectAfter( members );
         }

         members.options[ members.length ] = all.options[ i ];
         // This suddenly started happening, weird but works after v0.1.657
         // all.options[ i ] = null;
      }

      return false;
   },

   deleteHidden: function( id, value ) {
      return $$( 'input[name=' + id + ']' ).some( function( el ) {
         if (el.type == 'hidden' && el.value == value) {
            el.destroy(); return true;
         }

         return false;
      } );
   },

   removeItem: function( id ) {
      var all = $( id ), members = $( id + '_current' );

      for (var i = members.length - 1; i >= 0; i--) {
         if (members.options[ i ].selected != true) continue;

         var value = members.options[ i ].value;

         if (! this.deleteHidden( id + '_added', value )) {
            var name = all.name.replace( /^_/g, '' )+ '_deleted' ;

            new Element( 'input', {
               name: name, type: 'hidden', value: value
            } ).injectAfter( members );
         }

         all.options[ all.length ] = members.options[ i ];
         // This suddenly started happening, weird but works after v0.1.657
         // members.options[ i ] = null;
      }

      return false;
   }
} );

var LinkFader = new Class( {
   Implements: [ Options ],

   options    : {
      fc      : 'ff0000', // Fade to colour
      inBy    : 6,        // Fade in colour inc/dec by
      outBy   : 6,        // Fade out colour inc/dec by
      selector: '.fade',  // Class name matching links to fade
      speed   : 20        // Millisecs between colour changes
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      el.addEvent( 'mouseover', this.startFade.bind( this, el ) );
      el.addEvent( 'mouseout',  this.clearFade.bind( this, el ) );
   },

   clearFade: function( el ) {
      if (el.timer) $clear( el.timer );

      el.timer = this.fade.periodical( this.options.speed, this, [ el, 0 ] );
   },

   currentColour: function( el ) {
      var cc = el.getStyle( 'color' ), temp = '';

      if (cc.length == 4 && cc.substring( 0, 1 ) == '#') {
         for (var i = 0; i < 3; i++) {
            temp += cc.substring( i + 1, i + 2 ) + cc.substring( i + 1, i + 2);
         }

         cc = temp;
      }
      else if (cc.indexOf('rgb') != -1) { cc = cc.rgbToHex().substring(1, 7) }
      else if (cc.length == 7)          { cc = cc.substring( 1, 7 ) }
      else                              { cc = this.options.fc }

      return cc;
   },

   fade: function( el, d ) {
      var cc = this.currentColour( el ).hexToRgb( true );
      var tc = (d == 1)  ? this.options.fc.hexToRgb( true )
             : el.colour ? el.colour.hexToRgb( true )
                         : [ 0, 0, 0 ];

      if (tc[ 0 ] == cc[ 0 ] && tc[ 1 ] == cc[ 1 ] && tc[ 2 ] == cc[ 2 ]) {
         return el.timer = $clear( el.timer );
      }

      el.setStyle( 'color', this.nextColour( tc, cc, d ) );
   },

   nextColour: function( tc, cc, d ) {
      var change = (d == 1) ? this.options.inBy : this.options.outBy;
      var colour;

      for (var i = 0; i < 3; i++) {
         var diff, nc = cc[ i ];

         if (! colour) colour = 'rgb(';
         else colour += ',';

         if (tc[ i ]-cc[ i ] > 0) { diff   = tc[ i ] - cc[ i ] }
         else                     { diff   = cc[ i ] - tc[ i ] }
         if (diff  < change)      { change = diff }
         if (cc[ i ] > tc[ i ])   { nc     = cc[ i ] - change }
         if (cc[ i ] < tc[ i ])   { nc     = cc[ i ] + change }
         if (nc    < 0)           { nc     = 0 }
         if (nc    > 255)         { nc     = 255 }

         colour += nc;
      }

      colour += ')';
      return colour;
   },

   startFade: function( el ) {
      if (el.timer) {
         el.timer = $clear( el.timer );

         if (el.colour) el.setStyle( 'color', el.colour.hexToRgb() );
      }

      el.colour = this.currentColour( el );
      el.timer  = this.fade.periodical( this.options.speed, this, [ el, 1 ] );
   }
} );

var LiveGrid = new Class( {
   initialize: function( tableId, url, options ) {
      this.url      = url;
      this.tableId  = tableId;
      this.options  = options = options || {};
      this.table    = $( tableId );
      this.metaData = new LiveGridMetaData( options );
      this.buffer   = new LiveGridBuffer( this.metaData );

      this.lastDisplayedStartPos = -1;
      this.timeoutHander         = null;
      this.additionalParms       = options.requestParameters || {};
      this.processingRequest     = null;
      this.unprocessedRequest    = null;

      if (options.prefetchBuffer || options.prefetchOffset) {
         var offset = 0;

         if (options.prefetchOffset) {
            this.scroller.moveScroll( options.prefetchOffset );
            offset = options.prefetchOffset;
         }

         this.fetchBuffer( offset, false );
      }
      else { this.scroller = new LiveGridScroller( this ) }
   },

   ajaxUpdate: function( text, xml ) {
      this.timeoutHandler = $clear( this.timeoutHandler );

      try {
         var totalrows =  xml.documentElement.getAttribute( 'totalcount' );

         if (totalrows) this.setTotalRows( totalrows );
      }
      catch (err) {}

      this.buffer.update( text, xml );

      if (this.unprocessedRequest == null)
         this.updateContent( this.processingRequest.requestOffset );

      this.processingRequest = null;

      if (! this.scroller) {
         this.scroller = new LiveGridScroller( this );

         if (this.options.onFirstContent) this.options.onFirstContent( this );
      }

      if (this.options.onComplete) this.options.onComplete( this );

      this.processQueuedRequest();
      return;
   },

   fetchBuffer: function( offset, sequence_buffers ) {
      var page, page_size;

      if (this.processingRequest) {
         this.unprocessedRequest = new LiveGridRequest( offset );
         return;
      }

      this.processingRequest = new LiveGridRequest( offset );

      if (! this.ajaxRequest) {
         var options = {}; Object.extend( options, this.options );

         options.onSuccess = this.ajaxUpdate.bind( this );
         options.url       = this.url;
         this.ajaxRequest  = new Request( options );
      }

      page_size = this.metaData.getBufferSize() * this.metaData.getPageSize();
      page      = Math.floor( offset / page_size );

      if (sequence_buffers)
         page  += offset - page * page_size > page_size / 2 ? 1 : -1;

      if (page < 0) page = 0;

      var callParms = { 'content-type': 'text/xml', 'id'       : this.tableId,
                        'page'        : page,       'page_size': page_size };

      Object.extend( callParms, this.additionalParms );
      this.ajaxRequest.get( callParms );
      this.timeoutHandler = setTimeout( this.handleTimedOut.bind(this), 10000);
      return;
   },

   handleTimedOut: function() {
      //server did not respond in n secs assume that there could have been
      //an error or something, and allow requests to be processed again...
      this.processingRequest = null;
      this.processQueuedRequest();
      return;
   },

   processQueuedRequest: function() {
      if (this.unprocessedRequest != null) {
         this.requestContentRefresh( this.unprocessedRequest.requestOffset );
         this.unprocessedRequest = null
      }

      return;
   },

   replaceCellContents: function( buffer, start ) {
      if (start == this.lastDisplayedStartPos) return;

      this.table.set( 'html', buffer.getRows( start ).join( '' ) );
      this.lastDisplayedStartPos = start
      return;
   },

   requestContentRefresh: function( offset ) {
      if ( this.buffer.isFullyInRange( offset ) ) {
         this.updateContent( offset );

         if (this.buffer.needsMorePages( offset ))
            this.fetchBuffer( offset, true );
      }
      else if (this.buffer.isClose( offset )) {
         this.fetchBuffer( offset, true );
      }
      else { this.fetchBuffer( offset, false ) }

      return;
   },

   setRequestParams: function( params ) {
      this.additionalParms = params;
      return;
   },

   setTotalRows: function( newTotalRows ) {
      this.metaData.setTotalRows( newTotalRows );
      this.scroller.updateSize();
      return;
   },

   updateContent: function( offset ) {
      return this.replaceCellContents( this.buffer, offset );
   }
} );

var LiveGridBuffer = new Class( {
   initialize: function( metaData ) {
      this.start    = 0;
      this.size     = 0;
      this.metaData = metaData;
      this.rows     = [];
   },

   getRows: function( start ) {
      return this.rows.slice( start, start + this.metaData.getPageSize() );
   },

   isClose: function( start ) {
      return this.rows[start] || this.rows[start + this.metaData.getPageSize()];
   },

   isFullyInRange: function( start ) {
      return this.rows[start] && this.rows[start + this.metaData.getPageSize()];
   },

   needsMorePages: function( start ) {
      return this.needsPrevPage( start ) || this.needsNextPage( start );
   },

   needsNextPage: function( start ) {
      return ! this.rows[ start + 2 * this.metaData.getPageSize() ];
   },

   needsPrevPage: function( start ) {
      return ! this.rows[ start - this.metaData.getPageSize() ];
   },

   update: function( text, xml ) {
      var doc    = xml.documentElement;
      var rows   = doc.getElementsByTagName( 'items' );

      this.start = parseInt( doc.getAttribute( 'offset' ) );
      this.size  = parseInt( doc.getAttribute( 'count'  ) );

      for (var i = 0, size = this.size; i < size; i++) {
         this.rows[ this.start + i ]
            = rows[ i ].childNodes[ 0 ].nodeValue.unescapeHTML();
      }

      return;
   }
} );

var LiveGridMetaData = new Class( {
   initialize: function( options ) {
      this.bufferSize   = options.bufferSize   || 7;
      this.onscroll     = options.onScroll     || null;
      this.onscrollidle = options.onScrollidle || null;
      this.pageSize     = options.pageSize     || 10;
      this.totalRows    = options.totalRows    || 0;
   },

   getBufferSize: function()    { return this.bufferSize },

   getPageSize:   function()    { return this.pageSize },

   getTotalRows:  function()    { return this.totalRows },

   setTotalRows:  function( n ) { this.totalRows = n }
} );

var LiveGridRequest = new Class( {
   initialize: function( requestOffset, options ) {
      this.requestOffset = requestOffset;
   }
} );

var LiveGridScroller = new Class( {
   initialize: function( liveGrid ) {
      this.liveGrid      = liveGrid;
      this.metaData      = liveGrid.metaData;
      this.scrollTimeout = null;
      this.lastScrollPos = 0;
      this.createScrollBar();
   },

   adjustScrollTop: function() {
      var sd = this.scrollerDiv, rem = sd.scrollTop % this.lineHeight;

      this.unplug();

      if (rem != 0)
         sd.scrollTop +=
            (this.lastScrollPos < sd.scrollTop ? this.lineHeight : 0) - rem;

      this.lastScrollPos = sd.scrollTop;
      this.plugin();
      return;
   },

   createScrollBar: function() {
      var table         = this.liveGrid.table;
      var visibleHeight = table.offsetHeight;
      var pageSize      = this.metaData.getPageSize();
      var lineHeight    = visibleHeight / pageSize;
      var height        = this.metaData.getTotalRows() * lineHeight;

      this.lineHeight   = lineHeight;
      this.heightDiv    = new Element( 'div', {
         styles: { height: parseInt( height ) + 'px', width: '1px' }
      } );
      this.scrollerDiv  = new Element( 'div', {
         styles     : {
            height  : visibleHeight + 'px',
            overflow: 'auto',
            position: 'relative',
            width   : '19px' }
      } );
      this.scrollerDiv.setStyle( 'left',
                                 Browser.Engine.trident ? '-6px' : '-4px' );
      this.scrollerDiv.appendChild( this.heightDiv );
      this.scrollerDiv.injectAfter( table.parentNode );
      this.plugin();

      if (Browser.Engine.trident) {
         table.onmousewheel = function( evt ) {
            this.scrollerDiv.scrollTop
               += (event.wheelDelta >= 0 < 0 ? -1 : 1) * this.lineHeight;
            this.handleScroll( true );
         }.bind( this );
      }
      else {
         table.addEventListener( 'DOMMouseScroll', function( evt ) {
            this.scrollerDiv.scrollTop
               += (evt.detail < 0 ? -1 : 1) * this.lineHeight;
            this.handleScroll( true );
         }.bind( this ), true );
      }

      return;
   },

   handleScroll: function( skiptimeout ) {
      if (this.scrollTimeout) this.scrollTimeout = $clear( this.scrollTimeout );

      var contentOffset = parseInt( this.scrollerDiv.scrollTop
                * this.metaData.getTotalRows() / this.heightDiv.offsetHeight );

      if (this.metaData.onscroll)
         this.metaData.onscroll( contentOffset, this.metaData );

      if (skiptimeout == true) this.scrollIdle();
      else this.scrollTimeout = setTimeout( this.scrollIdle.bind( this ), 100 );

      return;
   },

   isUnPlugged: function() { return this.scrollerDiv.onscroll == null },

   moveScroll: function( rowOffset ) {
      this.scrollerDiv.scrollTop = this.heightDiv.offsetHeight
                                     * rowOffset / this.metaData.getTotalRows();
      return;
   },

   plugin: function() {
      this.scrollerDiv.onscroll = this.handleScroll.bind( this ); return;
   },

   scrollIdle: function() {
      if (this.scrollTimeout) this.scrollTimeout = $clear( this.scrollTimeout );

      // this.adjustScrollTop();
      var contentOffset = parseInt( this.scrollerDiv.scrollTop *
                 this.metaData.getTotalRows() / this.heightDiv.offsetHeight );

      this.liveGrid.requestContentRefresh( contentOffset );

      if ( this.metaData.onscrollidle ) this.metaData.onscrollidle();

      return;
   },

   unplug: function() { this.scrollerDiv.onscroll = null; return },

   updateSize: function() {
      var table = this.liveGrid.table, visibleHeight = table.offsetHeight;

      this.heightDiv.style.height = parseInt( visibleHeight *
         this.metaData.getTotalRows() / this.metaData.getPageSize() ) + 'px';
      return;
   }
} );

var LoadMore = new Class( {
   initialize: function( behaviour, url ) {
      this.behaviour = behaviour;
      this.url       = url;
   },

   request: function( action, id, val, onComplete ) {
      if (onComplete) this.onComplete = onComplete;

      new Request( { onSuccess: this._success.bind( this ),
                     url      : this.url + action
      } ).get( { 'content-type': 'text/xml', 'id': id, 'val': val } );
   },

   _success: function( text, xml ) {
      var doc = xml.documentElement, html = '';

      $each( doc.getElementsByTagName( 'items' ), function( item ) {
         for (var i = 0, il = item.childNodes.length; i < il; i++) {
            html += item.childNodes[ i ].nodeValue;
         }
      } );

      $( doc.getAttribute( 'id' ) ).set( 'html', html.unescapeHTML() );

      if (this.onComplete) this.onComplete.call( this.behaviour );
   }
} );

var PersistantStyleSheet = new Class( {
   initialize: function( options ) {
      var opt = options || {}; this.cookies = opt.cookies || $empty;

      this.setActive( this.cookies.get( 'stylesheet' ) || this.getPreferred() );

      window.addEvent( 'unload', function() {
         this.cookies.set( 'stylesheet', this.getActive() );
      }.bind( this ) );
   },

   getActive: function() {
      var active;

      $$( 'link' ).some( function( el ) {
         return (el.rel.indexOf( 'style' ) != -1
                 && ! el.disabled && (active = el.title)) ? true : false;
      } );

      return active;
   },

   getPreferred: function() {
      var preferred;

      $$( 'link' ).some( function( el ) {
         return (el.rel.indexOf( 'style' ) != -1
                 && el.rel.indexOf( 'alt' ) == -1 && (preferred = el.title))
              ? true : false;
      } );

      return preferred;
   },

   setActive: function( active ) {
      $$( 'link' ).each( function( el ) {
         if (el.rel.indexOf( 'style' ) != -1 && el.title)
            el.disabled = el.title != active ? true : false;
      } );
   }
} );

/* Adds markers to the page scrollbar to indicate the location of key
   elements on the page. Inspired by a simmilar mechanism used on MSNBC.com

   Was rewritten from from a Scriptaculous extension which was

   Copyright (c) 2010, Jarvis Badgley - chiper[at]chipersoft[dot]com

   Usage:

   var sp = new ScrollPins( { config: { Pintray: { pins: {
      // anchor elements are referenced via css selectors
      'hr'          : { image: 'pins/pin_gray.png' },
      // document order doesn't matter, only the order in the object
      'div'         : { image: 'pins/pin_empty.png' },
      // this line overwrites the pin created by 'div'
      'div.red'     : { image:'pins/pin_red.png' },
      // use a css selector to identify the pin contents
      'div.orange'  : { selector:'button' },
      // use an element id to get the pin contents
      'div.blue'    : { element:'bluepin' },
      // or add the element directly by variable
      //If the element was already in use as a pin, it gets cloned
      'div.lavender': { element:document.body.getChildren()[0] },
      //remove pins created by higher up in the array
      'div.eggplant': null
   } } } } );
 */

var ScrollPins = new Class( {
   Implements: [ Events, Options ],

   options             : {
      config           : {},
      scrollBarWidth   : 19,
      scrollDuration   : 500,
      scrollMargin     : 0,
      selector         : '.pintray',
      tag              : 'li',
      target           : window,
      trayPadding      : 10,
      trayPaddingBottom: undefined,
      trayPaddingTop   : undefined
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();

      this.fireEvent( 'initialize' );
   },

   build: function() {
      var opt = this.options;

      if (opt.selector) $$( opt.selector ).each( function( pintray ) {
         var cfg = $merge( opt, opt.config, (opt.config[ pintray.id ] || {}) );

         if ($type( cfg.target ) != 'window') cfg.target = $( cfg.target );

         pintray.cfg = cfg; pintray.pins = pintray.pins || [];

         Hash.each( cfg.pins || {}, function( value, key ) {
            this.createMarkup( pintray, key, value );
         }, this );

         this.resize( pintray );

         pintray.pins.each( function( el ) { this.attach( el ) }, this );

         if (! this.collection.contains( pintray )) {
            cfg.target.addEvent( 'resize', this.resize.bind( this, pintray ) );
            this.collection.include( pintray );
         }
      }, this );

      this.fireEvent( 'build' );
   },

   attach: function( el ) {
      if (el.attached) return; el.attached = true;

      var cfg      = el.pin.pintray.cfg,
          margin   = el.getStyle( 'margin-top' ).toInt(),
          position = el.getPosition( cfg.target ),
          padding  = $type( cfg.target ) != 'window'
                   ? cfg.target.getStyle( 'padding-top' ).toInt() : 0;

      if (this.debug)
         this.log( 'ScrollPins attach: ' + position.y + ' ' + margin
                   + ' ' + padding );

      el.pin.addEvent( 'click', function() {
         new Fx.Scroll( cfg.target, { duration: cfg.scrollDuration } )
                .start( position.x, position.y - margin - padding );
      } );

      this.fireEvent( 'attach', [ el ] );
   },

   createMarkup: function( pintray, key, value ) {
      // key   contains a selector for the node we want the pin to point at
      // value contains an object indicating what the pin should be made of
      var template = value ? this._getTemplate( value ) : false;

      if (template) template.pin_used = template.pin_used || 0;

      $$( key ).each( function( el ) {
         if (el.pin) el.pin.destroy(); if (! template) return;

         var cfg    = pintray.cfg,
             markup = template.pin_used++ ? template.clone( true )
                                          : template.show();

         if (cfg.title) markup.title = cfg.title.call( this, el );

         el.pin = new Element( cfg.tag ).inject( pintray );

         el.pin.grab( el.pin.markup = markup ); el.pin.pintray = pintray;

         pintray.pins.include( el );
      }, this );
   },

   _getTemplate: function( obj ) {
      return obj.icon     ? new Element( 'span', { class: obj.icon  } )
           : obj.image    ? new Element( 'img',  { src  : obj.image } )
           : obj.selector ? $$( obj.selector )[ 0 ]
           : obj.element  ?  $( obj.element  )
                          : false;
   },

   resize: function( pintray ) {
      this._resizePintray( pintray );

      pintray.pins.each( function( el ) {
         var cfg         = el.pin.pintray.cfg,
             padding_bot = $pick( cfg.trayPaddingBottom, cfg.trayPadding ),
             padding_top = $pick( cfg.trayPaddingTop,    cfg.trayPadding ),
             real_height = cfg.target.getScrollHeight(),
             view_height = cfg.target.getHeight(),
             pin_height  = el.pin.getHeight(),
             offset      = el.getPosition( cfg.target ).y,
             maximum     = view_height - padding_top - pin_height - padding_bot,
             pin_top     = padding_top + (offset * maximum / real_height);

         if (this.debug)
            this.log( 'ScrollPins resize: ' + padding_bot + ' '
                    + padding_top + ' ' + real_height + ' ' + view_height + ' '
                    + pin_height  + ' ' + offset      + ' ' + maximum     + ' '
                    + pin_top );

         el.isVisible() && el.parentNode ? el.pin.show() : el.pin.hide();
         pin_top = Math.max( Math.min( pin_top, maximum ), padding_top );
         el.pin.setStyle( 'top', pin_top.round() + 'px' );
      }, this );
   },

   _resizePintray: function( pintray ) {
      var cfg = pintray.cfg, target = cfg.target;

      if ($type( target ) == 'window') return;

      var margin_right = target.getStyle( 'margin-right' ).toInt(),
          right        = target.getStyle( 'right' ).toInt() + margin_right,
          margin_top   = target.getStyle( 'margin-top' ).toInt(),
          top          = target.getStyle( 'top' ).toInt() + margin_top;

      pintray.setStyles( { right: (cfg.scrollBarWidth + right) + 'px',
                           top  : top + 'px' } );
   }
} );

var ServerUtils = new Class( {
   Implements: [ Options ],

   options    : {
      config  : {},
      selector: '.server',
      url     : null
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      var cfg; if (! (cfg = this.options.config[ el.id ])) return;

      el.addEvent( cfg.event || 'click', function() {
         return this[ cfg.method ].apply( this, cfg.args );
      }.bind( this ) );
   },

   checkField: function( id ) {
      new Request( { onSuccess: this._success.bind( this ),
                     url      : this.options.url + 'check_field'
      } ).get( { 'content-type': 'text/xml', 'id': id, 'val': $( id ).value } );
   },

   _success: function( text, xml ) {
      var doc    = xml.documentElement;
      var el     = $( doc.getAttribute( 'id' ) );
      var result = doc.getAttribute( 'result' );

      el.set( 'html', result );
      el.className = result ? doc.getAttribute( 'class_name' ) : 'hidden';
   }
} );

var Sidebar = new Class( {
   Implements: [ Options ],

   options                : {
      accordion           : 'accordionDiv',
      config              : {},
      panel               : 0,
      panelClass          : '.accordion_panel',
      prefix              : 'sidebar',
      togglerClass        : '.accordion_header',
      togglerHeight       : 29,
      togglersMarginHeight: 15,
      width               : 250
   },

   initialize: function( behaviour, options ) {
      this.setOptions( options );
      this.cookies   = behaviour.cookies;
      this.loadMore  = behaviour.loadMore;
      this.behaviour = behaviour;

      var opt = this.options, prefix = opt.prefix, sb;

      if (! (sb = $( prefix + 'Disp' ))) return;

      var sb_state = this.cookies.get( prefix ) ? true : false;
      var sb_panel = this.cookies.get( prefix + 'Panel' ) || opt.panel;
      var sb_width = this.cookies.get( prefix + 'Width' ) || opt.width;

      this.cookies.set( prefix + 'Width', sb_width );

      /* Setup the slide in/out effect */
      this.slider = new Fx.Slide( prefix + 'Container', {
         mode      : 'horizontal',
         onComplete: function() {
            var sb_icon = $( prefix + 'Icon' );

            /* When the effect is complete toggle the state */
            if (this.cookies.get( prefix )) {
               if (sb_icon) sb_icon.className = 'pushedpin_icon';

               var panel = this.cookies.get( prefix + 'Panel' );

               this.accordion.reload( panel );
               this.accordion.display( panel );
            }
            else {
               if (sb_icon) sb_icon.className = 'pushpin_icon';

               this.behaviour.resize();
            }
         }.bind( this ),
         transition: Fx.Transitions.Circ.easeInOut
      } );

      /* Setup the event handler to turn the side bar on/off */
      $( prefix ).addEvent( 'click', function( ev ) {
         ev = new Event( ev ); ev.stop();

         if (this.cookies.get( prefix )) {
            this.cookies.remove( prefix ); this.slider.slideOut();
         }
         else {
            this.cookies.set( prefix, 'pushedpin_icon' );
            this.behaviour.resize(); this.slider.slideIn();
         }

         return false;
      }.bind( this ) );

      /* Setup the horizontal resize grippy for the side bar */
      sb.makeResizable( {
         handle   : $( prefix + 'Grippy' ),
         limit    : { x: [ 150, 450 ] },
         modifiers: { x: 'width', y: false },
         onDrag   : function() { this.resize( true ) }.bind( this.behaviour )
      } );

      var toggler_class = opt.togglerClass;

      /* Create an Accordion widget in the side bar */
      this.accordion = new Fx.Accordion( $( opt.accordion ), {
         fixedHeight : this.getAccordionHeight( sb, $$( toggler_class ) ),
         opacity     : false,
         onActive    : function( togglers, index, element ) {
            var prefix = this.options.prefix, toggler = togglers[ index ];

            toggler.swapClass( 'inactive', 'active' );
            this.cookies.set( prefix + 'Panel', togglers.indexOf( toggler ));
         }.bind( this ),
         onBackground: function( togglers, index, element ) {
            togglers[ index ].swapClass( 'active', 'inactive' );
         }
      }, toggler_class, opt.panelClass );

      /* Add event handler to sidebar panel headers */
      $$( toggler_class ).each( function( el ) {
         var cfg; if (! (cfg = this.options.config[ el.id ])) return;

         el.addEvent( 'click', function() {
            if (cfg.action && cfg.name) {
               this.loadMore.request( cfg.action, cfg.name,
                                      cfg.value,  cfg.onComplete );
            }

            return false;
         }.bind( this ) )
      }, this );

      /* Redisplay and reload the last accordion side bar panel */
      if (sb_state) this.accordion.reload( sb_panel );

      this.accordion.display( sb_panel, false );
      return;
   },

   getAccordionHeight: function( el, togglers ) {
      var opt = this.options;
      var height  = (opt.togglerHeight * togglers.length)
                   + opt.togglersMarginHeight;

      return Math.max( 1, el.getSize().y - height );
   },

   resize: function( changed, height ) {
      var elWidth, prefix = this.options.prefix, sb, sb_state;

      if (! (sb = $( prefix + 'Disp' ))) return 0;

      if (sb_state = this.cookies.get( prefix )) sb.setStyle( 'display', '' );

      sb.setStyle( 'marginBottom', height + 'px' );

      // Calculate and set vertical offset for side bar grippy
      var sb_height     = sb.getSize().y;
      var grippy_height = $( prefix + 'Grippy' ).getSize().y;
      var offset        = Math.max( 1, Math.round( sb_height / 2 )
                                       - Math.round( grippy_height / 2 ) );

      $( prefix + 'Grippy' ).setStyle( 'marginTop', offset + 'px' );

      if (this.accordion) {
         var ah = this.getAccordionHeight( sb, this.accordion.togglers );

         this.accordion.resize( ah, null );
      }

      if (sb_state) {
         if (changed) {
            elWidth = sb.getStyle( 'width' ).toInt();
            this.cookies.set( prefix + 'Width',  elWidth );
            this.slider.wrapper.setStyle( 'width', elWidth + 'px' );
         }
         else elWidth = this.cookies.get( prefix + 'Width' );
      }
      else elWidth = 0;

      sb.setStyle( 'width', elWidth + 'px' );
      return elWidth;
   }
} );

var Sliders = new Class( {
   Implements: [ Options ],

   options    : {
      config  : {},
      selector: '.slider',
      submit  : $empty
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      var cfg, opt = this.options, slider, submit = opt.submit;

      if (! (cfg = opt.config[ el.id ])) return;

      var name       = cfg.name;       delete cfg[ 'name'       ];
      var default_v  = cfg.default_v;  delete cfg[ 'default_v'  ];
      var knob_class = cfg.knob_class; delete cfg[ 'knob_class' ];
      var knob       = el.getElement( knob_class );

      cfg = $extend( cfg, {
         onChange: function( value ) {
            submit.setField.call( submit, name, value ) }
      } );

      el.slider = new Slider( el, knob, cfg ).set( default_v );
   }
} );

var SubmitUtils = new Class( {
   Implements: [ Options ],

   options          : {
      chooseSelector: '.chooser_button',
      config        : {},
      cookiePath    : '/',
      cookiePrefix  : 'html_formwidgets',
      formName      : null,
      submitSelector: '.submit'
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); var opt = this.options;

      this.cookies = new Cookies( { path  : opt.cookiePath,
                                    prefix: opt.cookiePrefix } );
      this.form    = document.forms ? document.forms[ opt.formName ] : $empty;
      this.build();
   },

   build: function() {
      var opt = this.options;

      if (opt.chooseSelector)
         $$( opt.chooseSelector ).each( this.attachChooser, this );

      if (opt.submitSelector)
         $$( opt.submitSelector ).each( this.attachSubmit, this );
   },

   attachChooser: function( el ) {
      var cfg; if (! (cfg = this.options.config[ el.id ])) return;

      var win_prefs  = 'width=' + cfg.width + ', screenX=' + cfg.screen_x;
          win_prefs += ', height=' + cfg.height + ', screenY=';
          win_prefs += cfg.screen_y + ', dependent=yes, titlebar=no, ';
          win_prefs += 'scrollbars=yes';

      el.addEvent( 'click', function() {
         return this.chooser( el.value, cfg.field, cfg.href, win_prefs );
      }.bind( this ) );
   },

   attachSubmit: function( el ) {
      var cfg; if (! (cfg = this.options.config[ el.id ])) return;

      el.addEvent( cfg.event || 'click', function() {
         return this[ cfg.method ].apply( this, cfg.args );
      }.bind( this ) );
   },

   chooser: function( button, name, base, win_prefs ) {
      var value = this.form.elements[ name ].value || '';

      if (value.indexOf( '%' ) < 0) this.submitForm( button );
      else {
         var uri  = base + '?form=' + this.options.formName;
             uri += '&field=' + name + '&value=' + value;

         top.chooser = window.open( uri, 'chooser', win_prefs );
         top.chooser.opener = top;
      }

      return false;
   },

   clearField: function( name ) {
      return this.setField( name, '' );
   },

   confirmSubmit: function( button, text ) {
      if (text.length < 1 || window.confirm( text )) {
         $$( 'input[name=_method]' ).some( function( el ) {
            return (el.value == button) ? true : false;
         } ) ? this.form.submit() : this.submitForm( button );

         return true;
      }

      return false;
   },

   historyBack: function() {
      window.history.back(); return false;
   },

   postData: function( url, data ) {
      new Request().post( url, data );
   },

   refresh: function( name, value ) {
      if (name) this.cookies.set( name, value );

      this.form.submit();
      return false;
   },

   returnValue: function( form_name, name, value ) {
      if (form_name && name && opener) {
         var el, form = opener.document.forms[ form_name ];

         if (form && (el = form.elements[ name ])) {
            el.value = value; if (el.focus) el.focus();
         }
      }

      window.close();
      return false;
   },

   setField: function( name, value ) {
      var el;

      if (name && (el = this.form.elements[ name ])) el.value = value;

      return el ? el.value : null;
   },

   submitForm: function( button ) {
      new Element( 'input', {
         name: '_method', type: 'hidden', value: button }
      ).injectAfter( $( 'top' ) );

      this.form.submit();
      return true;
   },

   submitOnReturn: function( button ) {
      ev = new Event();

      if (ev.key == 'enter') {
         if (document.forms) return this.submitForm( button );
         else window.alert( 'Document contains no forms' );
      }

      return false;
   }
} );

var TableUtils = new Class( {
   Implements: [ Events, Options ],

   options           : {
      editRowClass   : 'editable_row',
      editSelector   : 'table.editable',
      formName       : null,
      gridSelector   : '.live_grid',
      gridSize       : 10,
      gridToggle     : true,
      iconClasses    : [ 'a', 'b' ],
      inputCellClass : 'data_field',
/*    onRowAdded     : $empty, */
/*    onRowsRemoved  : $empty, */
/*    onSortComplete : $empty, */
      sortableOptions: {
         constrain   : true,
         handle      : 'td.row_select',
         revert      : { duration: 500, transition: 'elastic:out' } },
      sortRowClass   : 'sortable_row',
      sortSelector   : 'th.sort',
      textCellClass  : 'data_value',
      url            : null
   },

   initialize: function( options ) {
      this.setBuildOptions( options );
      this.form      = document.forms
                     ? document.forms[ this.options.formName ] : $empty;
      this.sortables = new Hash();
      this.build();
   },

   build: function() {
      var opt = this.options;

      if (opt.editSelector) $$( opt.editSelector ).each( function( el ) {
         el.getElements( 'tr.' + opt.editRowClass ).each( function( row ) {
            $uid( row );
         } );

         el.sortables = new Sortables( el.getElement( 'tbody' ),
                                       opt.sortableOptions );

         $( el.id + '_add' ).addEvent( 'click', function( ev ) {
            ev = new Event( ev ); ev.stop(); return this.addRow( el, true );
         }.bind( this ) );

         $( el.id + '_remove' ).addEvent( 'click', function( ev ) {
            ev = new Event( ev ); ev.stop(); return this.removeRows( el );
         }.bind( this ) );
      }, this );

      if (opt.gridSelector) $$( opt.gridSelector ).each( function( el ) {
         el.addEvent( 'click', function( ev ) {
            ev = new Event( ev ); ev.stop(); return this.liveGrid( el );
         }.bind( this ) );
      }, this );

      if (opt.sortSelector) $$( opt.sortSelector ).each( function( el ) {
         el.addEvent( 'click', function( ev ) {
            ev = new Event( ev ); ev.stop(); return this.sortRows( el );
         }.bind( this ) );
      }, this );
   },

   addRow: function( table, edit ) {
      var cNo    = 0, el, opt = this.options;
      var row    = new Element( 'tr', {
         class: opt.editRowClass + ' ' + opt.sortRowClass } );
      var new_id = $uid( row );

      while (el = $( table.id + '_add' + cNo )) {
         var cell = new Element( 'td' );

         if (edit) {
            var type  = el.tag == 'textarea' ? 'textarea' : 'input';
            var input = new Element( type, {
               class: 'ifield',
               name : table.id + '_' + new_id + '_' + cNo,
               value: el.value
            } );

            if (el.cols)      input.set( 'cols',      el.cols );
            if (el.rows)      input.set( 'rows',      el.rows );
            if (el.size)      input.set( 'size',      el.size );
            if (el.maxlength) input.set( 'maxlength', el.maxlength );

            cell.appendChild( input ); cell.set( 'class', opt.inputCellClass );
         }
         else {
            cell.appendText( el.value ); cell.set( 'class', opt.textCellClass );
         }

         row.appendChild( cell ); el.value = ''; cNo++;
      }

      if (edit) {
         var input = new Element( 'input', {
            name: table.id + '_select' + new_id, type: 'checkbox'
         } );
         var cell  = new Element( 'td', {
            class: 'row_select ' + (cNo % 2 == 0 ? 'even' : 'odd')
         } );

         cell.appendChild( input ); row.appendChild( cell );
      }

      var rows  = table.getElements( 'tr.' + opt.editRowClass );
      var nrows = rows ? rows.length : 0;

      this.form.elements[ '_' + table.id + '_nrows' ].value = nrows;
      row.injectBefore( $( table.id + '_edit' ) );
      table.sortables.attach();
      this.fireEvent( 'rowAdded' );
      return false;
   },

   _createGrid: function( text, xml ) {
      var keyid  = this.gridKey + '_' + this.gridId,
          count  = parseInt( xml.documentElement.getAttribute( 'totalcount' ) ),
          rows   = xml.documentElement.getElementsByTagName( 'items' ),
          urlkey = this.options.url + this.gridKey + '_grid_rows',
          html   = '',
          opts   = {
             bufferSize    : 7,
             gridSize      : this.options.gridSize,
             prefetchBuffer: true,
             onScroll      : this._updateHeader.bind( this ),
             onFirstContent: this._updateHeader.bind( this, 0 ),
             totalRows     : count };

      $each( rows, function( row ) { html += row.childNodes[ 0 ].nodeValue } );

      $( keyid + 'Disp' ).set( 'html', html.unescapeHTML() );

      this.gridObj = new LiveGrid( keyid + '_grid', urlkey, opts );
   },

   _get_sort_field: function( cell, type ) {
      var el = cell ? cell.firstChild : '', field = '';

      if      (el && el.nodeName == '#text') field = el.nodeValue;
      else if (el && el.nodeName == 'INPUT') field = el.value;

      if (type && type == 'date') {
         field = Date.parse( field ) || Date.parse( '01 Jan 1970' );
      }
      else if (type && type == 'money') {
         field = field.substring( 1 );
         field.replace( /[^0-9.]/g, '' );
         field = parseFloat( field ) || 0;
      }
      else if (type && type == 'numeric') {
         field.replace( /[^+\-0-9.]/g, '' );
         field = parseFloat( field ) || 0;
      }
      else field = field + '';

      return field;
   },

   _get_sort_order: function( table_id, default_column, column_id ) {
      var sortable = this.sortables.get( table_id )
                  || { sort_column: default_column, reverse: 0 };
      var reverse  = sortable.reverse;

      if (column_id == sortable.sort_column) reverse = 1 - reverse;
      else reverse = 0;

      sortable.reverse = reverse; sortable.sort_column = column_id;
      this.sortables.set( table_id, sortable );
      return reverse ? [ 1, -1 ] : [ -1, 1 ];
   },

   liveGrid: function( anchor ) {
      var el, a = anchor.id.split( '_' ), key = a[ 0 ], id = a[ 1 ];

      if (! key || ! id || ! (el = $( anchor.id + 'Disp' ))) return;

      var opt = this.options;

      if (opt.gridToggle && el.getStyle( 'display' ) != 'none') {
         el.setStyle( 'display', 'none' );

         if (el = $( anchor.id + 'Icon' )) el.className = opt.iconClasses[ 0 ];

         this.gridKey = null; this.gridId = null; this.gridObj = null;
         return;
      }

      if (this.gridKey && this.gridId) {
         var keyid = this.gridKey + '_' + this.gridId, prev;

         if (prev = $( keyid + 'Disp' )) prev.setStyle( 'display', 'none' );
         if (prev = $( keyid + 'Icon' )) prev.className = opt.iconClasses[ 0 ];

         this.gridKey = null; this.gridId = null; this.gridObj = null;
      }

      el.setStyle( 'display', '' ); this.gridKey = key; this.gridId = id;

      if (el = $( anchor.id + 'Icon' )) el.className = opt.iconClasses[ 1 ];

      new Request( {
         onSuccess: this._createGrid.bind( this ),
         url      : opt.url + key +  '_grid_table' } ).get( {
            'content-type': 'text/xml', 'id': id, 'val': opt.gridSize } );
      return;
   },

   removeRows: function( table ) {
      var rows      = table.getElements( 'tr.' + this.options.editRowClass ),
          nrows     = rows ? rows.length : 0,
          destroyed = 0;

      rows.map( function( row ) {
         row.getElements( 'td.row_select' ).map( function( cell ) {
            cell.getElements( 'input[type=checkbox]' ).map( function( cb ) {
               if (cb.checked) { row.destroy(); destroyed++ }
            } );
         } );
      } );

      this.form.elements[ '_' + table.id + '_nrows' ].value = nrows - destroyed;

      if (destroyed > 0) this.fireEvent( 'rowsRemoved' );

      return false;
   },

   sortRows: function( table_header ) {
      var id       = table_header.id,
          a        = id.split( '.' ),
          table_id = a[ 0 ], column_type = a[ 2 ],
          table    = $( table_id ),
          columns  = table.getElements( 'th' ),
          col_ids  = columns.map( function( column ) { return column.id } );

      if (! col_ids.contains( id )) return;

      var col_id   = col_ids.indexOf( id ),
          order    = this._get_sort_order( table_id, col_ids[ 0 ], id ),
          selector = 'tr.' + this.options.sortRowClass,
          rows     = [];

      table.getElements( selector ).map( function( row, index ) {
         var field = this._get_sort_field( row.cells[ col_id ], column_type );

         rows[ index ] = row;

         return [ field, row.clone( true, true ) ];
      }.bind( this ) ).sort( function( a, b ) {
         return a[ 0 ] < b[ 0 ] ? order[ 0 ]
             : (a[ 0 ] > b[ 0 ] ? order[ 1 ] : 0);
      } ).map( function( sorted_rows, index ) {
         var old_row    = rows[ index ],
             new_row    = sorted_rows[ 1 ],
             new_row_id = new_row.id;

         new_row.removeAttribute( 'id' ); new_row.replaces( old_row );

         return [ new_row, new_row_id ];
      } ).map( function( sorted_rows, index ) {
         var id, row = sorted_rows[ 0 ];

         if (id = sorted_rows[ 1 ]) row.id = id;

         return row;
      } );

      this.fireEvent( 'sortComplete' );
      return;
   },

   _updateHeader: function( offset ) {
      var id, sortInfo, text, urlkey, metaData = this.gridObj.metaData;

      id    = this.gridKey + '_' + this.gridId + '_header';
      text  = 'Listing ' + (offset + 1) + ' - ';
      text += (offset + metaData.getPageSize());
      text += ' of ' + metaData.getTotalRows();
      $( id ).set( 'html', text );

      if (this.gridObj.sortCol) {
         sortInfo  = '&data_grid_sort_col=' + this.gridObj.sortCol;
         sortInfo += '&data_grid_sort_dir=' + this.gridObj.sortDir;
      }
      else sortInfo = '';

      urlkey = this.options.url + this.gridKey + '_gridPage';
      text   = urlkey + '?data_grid_index=' + offset + sortInfo;
      $( id ).href = text;
      return;
   }
} );

/* Clientcide Copyright (c) 2006-2009

Contents: TabSwapper

name: TabSwapper.js
description: Handles the scripting for a common UI layout; the tabbed box.
License: http://www.clientcide.com/wiki/cnet-libraries#license

requires:
 - core: Element.Event, Fx.Tween, Fx.Morph
 - more: Element.Shortcuts, Element.Dimensions, Element.Measure
*/

var TabSwapper = new Class( {
   Implements: [ Options, Events ],

   options           : {
      clickers       : 'a',
      cookieName     : 'tabswapper_',
      cookiePath     : '/',
      cookiePrefix   : 'html_formwidgets',
      deselectedClass: 'off',
      effectOptions  : { duration: 500 },
      initPanel      : 0,
      maxSize        : null,
      mouseoverClass : 'tab_over',
//    onActive       : $empty,
//    onActiveAfterFx: $empty,
//    onBackground   : $empty
      rearrangeDOM   : true,
      sections       : 'dd.panel',
      selectedClass  : 'tab_selected',
      smooth         : false,
      smoothSize     : false,
      tabs           : 'dt',
      usePersistance : true
   },

   tabs: [],

   initialize: function( el, options ) {
      this.setOptions( options ); var opt = this.options;

      this.cookieName = opt.cookieName + el.id;
      this.cookies    = new Cookies( { path  : opt.cookiePath,
                                       prefix: opt.cookiePrefix } );

      var sections = el.getElements( opt.sections );

      tabs = el.getElements( opt.tabs );

      tabs.each( function( tab, index ) {
         this.addTab( $( tab ), $( sections[ index ] ), index );
         this.hideSection( index );
      }, this );

      this.show( this.recall() );
   },

   addTab: function( tab, section, index ) {
      var opt = this.options, clicker = tab.getElement( opt.clickers ) || tab;

      // If the index isn't specified, put the tab at the end
      if (! $defined( index )) index = this.tabs.length;

      // If the tab is already in the interface, just move it
      if (this.tabs.indexOf( tab ) >= 0 && tab.retrieve( 'tabbered' )
          && this.tabs.indexOf( tab ) != index && opt.rearrangeDOM) {
         this.moveTab( this.tabs.indexOf( tab ), index );
         return this;
      }

      // If this isn't the first item, and there's a tab
      // already in the interface at the index 1 less than this
      // insert this after that one
      if (index > 0 && this.tabs[ index - 1 ] && opt.rearrangeDOM) {
         tab.inject( this.tabs[ index - 1 ], 'after' );
         section.inject( this.tabs[ index - 1 ].retrieve( 'section' ), 'after');
      }

      this.tabs.splice( index, 0, tab );

      tab.addEvents( {
         mouseout : function() {
            this.removeClass( opt.mouseoverClass ); }.bind( tab ),
         mouseover: function() {
            this.addClass( opt.mouseoverClass ); }.bind( tab )
      } );

      clicker.addEvent( 'click', function( ev ) {
         ev.preventDefault(); this.show( index );
      }.bind( this ) );

      tab.store( 'tabbered', true    );
      tab.store( 'section',  section );
      tab.store( 'clicker',  clicker );
      return this;
   },

   hideSection: function( idx ) {
      var tab; if (! (tab = this.tabs[ idx ])) return this;

      var section; if (! (section = tab.retrieve( 'section' ))) return this;

      if (section.getStyle( 'display' ) != 'none') {
         this.lastHeight = section.getSize().y;
         section.setStyle( 'display', 'none' );
         tab.swapClass( this.options.selectedClass,
                        this.options.deselectedClass );
         this.fireEvent( 'onBackground', [ tab, section, idx ] );
      }

      return this;
   },

   moveTab: function( from, to ) {
      var tab       = this.tabs[ from ];
      var clicker   = tab.retrieve( 'clicker' );
      var section   = tab.retrieve( 'section' );
      var toTab     = this.tabs[ to ];
      var toClicker = toTab.retrieve( 'clicker' );
      var toSection = toTab.retrieve( 'section' );

      this.tabs.erase( tab ).splice( to, 0, tab );
      tab.inject( toTab, 'before' );
      clicker.inject( toClicker, 'before' );
      section.inject( toSection, 'before' );
      return this;
   },

   recall: function() {
      var opt = this.options, panel;

      if (opt.usePersistance) panel = this.cookies.get( this.cookieName );

      return panel ? panel.toInt() : opt.initPanel;
   },

   removeTab: function( index ) {
      var now = this.tabs[ this.now ];

      if (this.now == index) {
         if (index > 0) this.show( index - 1 );
         else if (index < this.tabs.length) this.show( index + 1 );
      }

      this.now = this.tabs.indexOf( now );
      return this;
   },

   save: function( index ) {
      if (this.options.usePersistance)
         this.cookies.set( this.cookieName, index );

      return this;
   },

   show: function( i ) {
      if (! $chk( this.now )) {
         this.tabs.each( function( tab, idx ) {
            if (i != idx) this.hideSection( idx );
         }, this );
      }

      this.showSection( i ).save( i );
      return this;
   },

   showSection: function( idx ) {
      var opt = this.options, smoothOk = opt.smooth && !Browser.Engine.trident4;

      var tab; if (! (tab = this.tabs[ idx ])) return this;

      var section; if (! (section = tab.retrieve( 'section' ))) return this;

      if (this.now != idx) {
         if (! tab.retrieve( 'tabFx' ))
            tab.store( 'tabFx', new Fx.Morph( section, opt.effectOptions ) );

         var effect   = false;
         var overflow = section.getStyle( 'overflow' );
         var start    = { display: 'block', overflow: 'hidden' };

         if (smoothOk) {
            start.opacity = 0; effect = { opacity: 1 };
         } else if (section.getStyle( 'opacity' ).toInt() < 1) {
            section.setStyle( 'opacity', 1 );

            if (! opt.smoothSize)
               this.fireEvent( 'onActiveAfterFx', [ tab, section, idx ] );
         }

         if (opt.smoothSize) {
            var size = section.getDimensions().height;

            if ($chk( opt.maxSize ) && opt.maxSize < size) size = opt.maxSize;

            if (! effect) effect = {};

            effect.height = size;
         }

         if ($chk( this.now )) this.hideSection( this.now );

         if (opt.smoothSize && this.lastHeight) start.height = this.lastHeight;

         section.setStyles( start );

         if (effect) {
            tab.retrieve( 'tabFx' ).start( effect ).chain( function() {
               this.fireEvent( 'onActiveAfterFx', [ tab, section, idx ] );

               section.setStyles( {
                  height  : this.options.maxSize == effect.height
                          ? this.options.maxSize : 'auto',
                  overflow: overflow
               } );

               var inputs = section.getElements( 'input, textarea' );

               inputs.setStyle( 'opacity', 1 );
            }.bind( this ) );
         }

         this.now = idx; this.fireEvent( 'onActive', [ tab, section, idx ] );
      }

      tab.swapClass( opt.deselectedClass, opt.selectedClass );
      return this;
   }
} );

var TabSwappers = new Class( {
   Implements: [ Options ],

   options          : {
      config        : {},
      cookiePath    : '/',
      cookiePrefix  : 'html_formwidgets',
      selector      : '.tabswapper',
      usePersistance: true
   },

   initialize: function( options ) {
      this.setBuildOptions( options );

      this.config = $merge( this.options.config.defaults );

      var attrs = [ 'cookiePath', 'cookiePrefix', 'usePersistance' ];

      attrs.each( function( attr ) {
         this.config[ attr ] = this.options[ attr ] }, this );
      this.build();
   },

   attach: function( el ) {
      var cfg = $merge( this.config, this.options.config[ el.id ] );

      el.tabSwapper = new TabSwapper( el, cfg );
   }
} );

/*

Description: Class for creating nice tips that follow the mouse cursor
             when hovering an element.

License: MIT-style license

Authors: Valerio Proietti, Christoph Pojer, Peter Flanigan

*/

var Tips = new Class( {
   Implements: [ Events, Options ],

   options         : {
      className    : 'tool',
      fixed        : false,
      hellip       : '\u2026',
      hideDelay    : 100,
      maxTitleChars: 40,
      offsets      : { 'x': 20, 'y': 20 },
      onHide       : function( tip ) { tip.setStyle( 'visibility', 'hidden'  )},
      onShow       : function( tip ) { tip.setStyle( 'visibility', 'visible' )},
      selector     : '.tips',
      separator    : '~',
      showDelay    : 100,
      spacer       : '\u00a0\u00a0\u00a0',
      text         : function( el ) {
         return (el.get( 'rel' )
                 || el.get( 'href' ) || '').replace( 'http://', '' );
      },
      timeout      : 30000,
      title        : 'title'
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.tip = this.createMarkup();

      this.build(); this.fireEvent( 'initialize' );
   },

   attach: function( el ) {
      this.storeTitleAndText( el );

      var events = [ 'enter', 'leave' ];

      if (! this.options.fixed) events.push( 'move' );

      events.each( function( value ) {
         var key = 'tip:' + value, method = 'element' + value.capitalize();
         var handler;

         if (! (handler = el.retrieve( key )))
            handler = this[ method ].bindWithEvent( this, el );

         el.store( key, handler ).addEvent( 'mouse' + value, handler );
      }, this );
   },

   createMarkup: function() {
      var klass  = this.options.className;
      var spacer = this.options.spacer;
      var div    = new Element( 'div', {
         'class' : klass + '-tip',
         'styles': { 'left'      : 0,
                     'position'  : 'absolute',
                     'top'       : 0,
                     'visibility': 'hidden' } } ).inject( document.body );
      var table  = new Element( 'table', {
         'cellpadding': 0, 'cellspacing': 0 } ).inject( div );
      var row    = new Element( 'tr' ).inject( table );

      this.titleCell = new Element( 'td', {
         'class' : klass + '-tip-topLeft' } ).inject( row );
      this.title = new Element( 'span' ).inject( this.titleCell );

      var cell   = new Element( 'td', {
         'class' : klass + '-tip-topRight' } ).inject( row );

      new Element( 'span' ).appendText( spacer ).inject( cell );

      row = new Element( 'tr' ).inject( table );
      this.textCell = new Element( 'td', {
         'class' : klass + '-tip-bottomLeft' } ).inject( row );
      this.text = new Element( 'span' ).inject( this.textCell );

      cell = new Element( 'td', {
         'class' : klass + '-tip-bottomRight' } ).inject( row );
      new Element( 'span' ).appendText( spacer ).inject( cell );

      return div;
   },

   elementEnter: function( ev, el ) {
      $clear( this.timer );
      this.timer = this.show.delay( this.options.showDelay, this, el );
      this.setup( el ); this.position( ev, el );
   },

   elementLeave: function( ev, el ) {
      $clear( this.timer );

      var opt = this.options, delay = Math.max( opt.showDelay, opt.hideDelay );

      this.timer = this.hide.delay( delay, this, el );
   },

   elementMove: function( ev, el ) {
      this.position( ev, el );
   },

   hide: function( el ) {
      this.fireEvent( 'hide', [ this.tip, el ] );
   },

   position: function( ev, el ) {
      var options = this.options, offsets = options.offsets;

      if (options.fixed) {
         var pos = el.getPosition();

         this.tip.setStyles( {
            'left': pos.x + offsets.x, 'top': pos.y + offsets.y
         } );

         return;
      }

      var win    = { 'x': window.getWidth(),      'y': window.getHeight()    };
      var scroll = { 'x': window.getScrollLeft(), 'y': window.getScrollTop() };
      var tip    = { 'x': this.tip.offsetWidth,   'y': this.tip.offsetHeight };
      var prop   = { 'x': 'left',                 'y': 'top'                 };

      for (var z in prop) {
         var pos = ev.page[ z ] + offsets[ z ];

         if (pos + tip[ z ] > scroll[ z ] + win[ z ])
            pos = ev.page[ z ] - offsets[ z ] - tip[ z ];

         this.tip.setStyle( prop[ z ], pos );
      }

      return;
   },

   _read: function( option, el ) {
      return option ? ($type( option ) == 'function'
                       ? option( el ) : el.get( option )) : '';
   },

   setup: function( el ) {
      var max   = Math.floor( window.getWidth() / 4 ),
          text  = el.retrieve( 'tip:text'  ) || '',
          title = el.retrieve( 'tip:title' ) || '',
          w     = 10 * Math.max( title.length, text.length );

      w = w < 100 ? 100 : w > max ? max : w;

      this.titleCell.setStyle( 'width', parseInt( w ) + 'px' );
      this.title.empty().appendText( title || this.options.spacer );
      this.textCell.setStyle( 'width', parseInt( w ) + 'px' );
      this.text.empty().appendText( text || this.options.spacer );
   },

   show: function( el ) {
      if (this.options.timeout)
         this.timer = this.hide.delay( this.options.timeout, this );

      this.fireEvent( 'show', [ this.tip, el ] );
   },

   storeTitleAndText: function( el ) {
      if (el.retrieve( 'tip:title' )) return;

      var options = this.options,
          title   = this._read( options.title, el ),
          text    = this._read( options.text,  el );

      if (title) {
         var pair = title.split( options.separator );

         if (pair.length > 1) {
            title = pair[ 0 ].trim(); text = (pair[ 1 ] + ' ' + text).trim();
         }
      }
      else title = options.hellip;

      if (title.length > options.maxTitleChars) {
         title = title.substr( 0, options.maxTitleChars - 1 ) + options.hellip;
      }

      el.store( 'tip:title', title );
      el.store( 'tip:text',  text  );
      el.erase( 'title' );
   }
} );

var Togglers = new Class( {
   Implements: [ Options ],

   options: { config: {}, selector: '.togglers' },

   initialize: function( behaviour, options ) {
      this.cookies = behaviour.cookies;
      this.resize  = behaviour.resize.bind( behaviour );

      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      var cfg; if (! (cfg = this.options.config[ el.id ])) return;

      el.addEvent( cfg.event || 'click', function() {
         return this[ cfg.method ].apply( this, cfg.args );
      }.bind( this ) );
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

var Trees = new Class( {
   Implements: [ Options ],

   options          : {
      classPrefix   : 'tree',
      cookiePath    : '/',
      cookiePrefix  : 'html_formwidgets',
      cookieSuffix  : 'tree',
      selector      : '.tree',
      usePersistance: true
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); var opt = this.options;

      if (opt.usePersistance) {
         var prefix = opt.cookiePrefix + '_' + opt.cookieSuffix;

         this.cookies = new Cookies( { path  : opt.cookiePath,
                                       prefix: prefix } );
      }

      this.build();
   },

   attach: function( el, branch ) {
      if (! el || ! el.childNodes || el.childNodes.length == 0) return;

      if (! branch) this.attachControls( el.id );

      var dt, node;

      for (var i = 0, ecl = el.childNodes.length; i < ecl; i++) {
         if (! (node = $( el.childNodes[ i ] ))) continue;

         if (node.nodeName == 'DT') { dt = node; continue; }

         if (node.nodeName != 'DD') continue; var dd = node;

         this.setState( dt, dd, ! branch ); this.attachTogglers( dt, dd );

         for (var j = 0, ddcl = dd.childNodes.length; j < ddcl; j++) {
            if ((node = $( dd.childNodes[ j ] )) && node.nodeName == 'DL')
               this.attach( node, true );
         }
      }
   },

   attachControls: function( id ) {
      $( id + '_collapse_button' ).addEvent
         ( 'click', this.collapseTree.bind( this, id ) );
      $( id + '_expand_button' ).addEvent
         ( 'click', this.expandTree.bind( this, id ) );
   },

   attachToggler: function( dt, dd, klass, event ) {
      $$( '#' + dt.id + ' span.' + klass ).each( function( el ) {
         el.addEvent( event, function( ev ) {
            ev = new Event( ev ); ev.stop(); return this.toggle( dt, dd );
         }.bind( this ) );
      }, this );
   },

   attachTogglers: function( dt, dd ) {
      var prefix = this.options.classPrefix;

      this.attachToggler( dt, dd, prefix + '_node_ctrl', 'click'    );
      this.attachToggler( dt, dd, prefix + '_node_icon', 'dblclick' );
   },

   close: function( dt, dd ) {
      var prefix = this.options.classPrefix;

      if (dt.hasClass( prefix + '_node_open' )) {
         dt.swapClass( prefix + '_node_open', prefix + '_node_closed' );
         dd.swapClass( prefix + '_node_open', prefix + '_node_closed' );
      }
      else if (dt.hasClass( prefix + '_node_last_open' )) {
         dt.swapClass( prefix + '_node_last_open',
                       prefix + '_node_last_closed' );
         dd.swapClass( prefix + '_node_last_open',
                       prefix + '_node_last_closed' );
      }

      if (this.options.usePersistance) this.cookies.set( dt.id, '0' );
   },

   collapseTree: function( treeId ) {
      var list = $( treeId );

      return list == null ? false : this.expandCollapseList( list, 'close' );
   },

   expandCollapseList: function( el, dirn, itemId ) {
      if (! el || ! el.childNodes || el.childNodes.length == 0) return false;

      var dt, node;

      for (var i = 0, ecl = el.childNodes.length; i < ecl; i++) {
         if (! (node = $( el.childNodes[ i ] ))) continue;

         if (itemId != null && itemId == node.id) return true;

         if (node.nodeName == 'DT') { dt = node; continue; }

         if (node.nodeName != 'DD') continue; var dd = node;

         for (var j = 0, ddcl = dd.childNodes.length; j < ddcl; j++) {
            if ((node = $( dd.childNodes[ j ] )) && node.nodeName == 'DL') {
               var ret = this.expandCollapseList( node, dirn, itemId );

               if (itemId != null && ret) {
                  if (dirn == 'close') this.close( dt, dd );
                  else this.open( dt, dd );

                  return true;
               }
            }
         }

         if (itemId == null) {
            if (dirn == 'close') this.close( dt, dd );
            else this.open( dt, dd );
         }
      }

      return false;
   },

   expandToItem: function( treeId, itemId ) {
      var list = $( treeId ), o, ret;

      if (list == null) return false;

      if (ret = this.expandCollapseList( list, 'open', itemId )) {
         if (o = $( itemId ) && o.scrollIntoView) o.scrollIntoView( false );
      }

      return ret;
   },

   expandTree: function( treeId ) {
      var list = $( treeId );

      return list == null ? false : this.expandCollapseList( list, 'open' );
   },

   open: function( dt, dd ) {
      var prefix = this.options.classPrefix;

      if (dt.hasClass( prefix + '_node_closed' )) {
         dt.swapClass( prefix + '_node_closed', prefix + '_node_open' );
         dd.swapClass( prefix + '_node_closed', prefix + '_node_open' );
      }
      else if (dt.hasClass( prefix + '_node_last_closed' )) {
         dt.swapClass( prefix + '_node_last_closed',
                       prefix + '_node_last_open' );
         dd.swapClass( prefix + '_node_last_closed',
                       prefix + '_node_last_open' );
      }

      if (this.options.usePersistance) this.cookies.set( dt.id, '1' );
   },

   setState: function( dt, dd, state ) {
      if (this.options.usePersistance) {
         this.cookies.get( dt.id ) == '1'
            ? this.open( dt, dd ) : this.close( dt, dd );
      }
      else {
         if (state) this.open( dt, dd );
         else this.close( dt, dd );
      }
   },

   toggle: function( dt, dd ) {
      var prefix = this.options.classPrefix;

      if (dt.hasClass( prefix + '_node_last_open' )
          || dt.hasClass( prefix + '_node_last_closed' )) {
         dt.toggleClass( prefix + '_node_last_open'   );
         dt.toggleClass( prefix + '_node_last_closed' );
         dd.toggleClass( prefix + '_node_last_open'   );
         dd.toggleClass( prefix + '_node_last_closed' );
      }
      else {
         dt.toggleClass( prefix + '_node_open'   );
         dt.toggleClass( prefix + '_node_closed' );
         dd.toggleClass( prefix + '_node_open'   );
         dd.toggleClass( prefix + '_node_closed' );
      }

      if (this.options.usePersistance) {
         if (dt.hasClass( prefix + '_node_open' )
             || dt.hasClass( prefix + '_node_last_open' ))
            this.cookies.set( dt.id, '1' );
         else this.cookies.set( dt.id, '0' );
      }

      return false;
   }
} );

var WindowUtils = new Class( {
   Implements: [ Options ],

   options        : {
      config      : {},
      cookieName  : 'session',
      customLogFn : false,
      domain      : null,
      path        : '/',
      prefix      : null,
      quiet       : false,
      selector    : '.windows',
      target      : null,
      windowHeight: 600,
      windowWidth : 800
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); var opt = this.options;

      this.cookieName = (opt.prefix ? opt.prefix + '_' : '') + opt.cookieName;
      this.cookieOpts = { path: opt.path, domain: opt.domain };

      if (opt.customLogFn) {
         if ($type( opt.customLogFn ) != 'function')
            throw 'customLogFn is not a function';
         else this.customLogFn = opt.customLogFn;
      }

      if (opt.target == 'top') this.placeOnTop();

      this.build();
   },

   attach: function( el ) {
      var cfg; if (! (cfg = this.options.config[ el.id ])) return;

      el.addEvent( cfg.event || 'click', function() {
         return this[ cfg.method ].apply( this, cfg.args );
      }.bind( this ) );
   },

   log: function( message ) {
      if (this.options.quiet) return;

      message = 'html-formwidgets.js: ' + message;

      if (this.customLogFn) { this.customLogFn( message ) }
      else if (window.console && window.console.log) {
         window.console.log( message );
      }
   },

   openWindow: function( href, options ) {
      var opt = this.options;

      options.height = options.height || opt.windowHeight;
      options.width  = options.width  || opt.windowWidth;

      new Browser.Popup( href, options );
      return false;
   },

   placeOnTop: function() {
      if (self != top) {
         if (document.images) top.location.replace( window.location.href );
         else top.location.href = window.location.href;
      }
   },

   wayOut: function( href ) {
      Cookie.dispose( this.cookieName, this.cookieOpts );

      if (document.images) top.location.replace( href );
      else top.location.href = href;
   }
} );

/* Author  : luistar15, <leo020588 [at] gmail.com>
 * License : MIT License
 * Class   : wysiwyg (rev.06-07-08)
 */

var WYSIWYG = new Class( {
   Implements: [ Events, Options ],

   options             : {
      barNum           : 4,
      buttonWidth      : 24,
      buttons          : {
         anchor        : [ 20, 'Anchor', 'anchor', 'Enter anchor id', '#' ],
         bigger        : [ 72, 'Increase Font Size', 'increasefontsize', null ],
         blockquote    : [ 19, 'Blockquote', 'formatblock', '<BLOCKQUOTE>' ],
         bold          : [ 30, 'Bold', 'bold', null ],
         clear         : [  0, 'Clear', 'selectall+delete', null ],
         copy          : [  3, 'Copy to Clipboard', 'copy', null ],
         cut           : [  4, 'Cut to Clipboard', 'cut', null ],
         div           : [ 56, 'Div Element', 'formatblock', '<DIV>' ],
         elfinder      : [ 58, 'Find Element', 'elfinder',
                               'Enter element selector', '' ],
         flash         : [  9, 'Shockwave Flash', 'flash' ],
         forecolor     : [ 50, 'Text Colour', 'forecolor',
                               'Enter text colour', '#' ],
         fullscreen    : [ 21, 'Full Screen', 'fullscreen' ],
         h1            : [ 67, 'Header Level 1', 'formatblock', '<H1>' ],
         h2            : [ 68, 'Header Level 2', 'formatblock', '<H2>' ],
         h3            : [ 69, 'Header Level 3', 'formatblock', '<H3>' ],
         hilitecolor   : [ 51, 'Highlight Colour', 'hilitecolor',
                               'Enter highlight colour', '#' ],
         horizontalrule: [ 18, 'Horizontal Rule', 'inserthorizontalrule',
                               null ],
         image         : [  8, 'Image', 'insertimage',
                               'Enter the image URL:', 'http://' ],
         indent        : [ 11, 'Indent', 'indent', null ],
         italic        : [ 33, 'Italic', 'italic', null ],
         justifycenter : [ 36, 'Justify Centre', 'justifycenter', null ],
         justifyfull   : [ 17, 'Justify Full', 'justifyfull', null ],
         justifyleft   : [ 35, 'Justify Left', 'justifyleft', null ],
         justifyright  : [ 37, 'Justify Right', 'justifyright', null ],
         link          : [ 31, 'Link', 'createlink', 'Enter the URL:',
                               'http://' ],
         nbsp          : [ 53, 'Non Breaking Space', 'nbsp', null ],
         nexttoolbar   : [ 74, 'Next Toolbar', 'nexttoolbar' ],
         orderedlist   : [ 15, 'Ordered List', 'insertorderedlist', null ],
         outdent       : [ 10, 'Outdent', 'outdent', null ],
         paragraph     : [ 70, 'Paragraph', 'formatblock', '<P>' ],
         paste         : [  5, 'Paste from Clipboard', 'paste', null ],
         preformatted  : [ 17, 'Preformatted Text', 'formatblock', '<PRE>' ],
         redo          : [ 39, 'Redo Previous Action', 'redo', null ],
         removeformat  : [  7, 'Remove Format', 'removeformat', null ],
         smaller       : [ 71, 'Decrease Font Size', 'decreasefontsize', null ],
         strikethrough : [ 16, 'Strikethrough', 'strikethrough', null ],
         subscript     : [ 12, 'Subscript', 'subscript', null ],
         superscript   : [ 13, 'Superscript', 'superscript', null ],
         table         : [ 23, 'Insert Table', 'table' ],
         tableprops    : [ 44, 'Table Properties', 'tableprops' ],
         tablerm       : [ 28, 'Remove Table', 'tablerm' ],
         tbrowbefore   : [ 48, 'Insert Row Before', 'tbrowbefore' ],
         tbrowafter    : [ 47, 'Insert Row After', 'tbrowafter' ],
         tbrowrm       : [ 26, 'Remove Row', 'tbrowrm' ],
         tbcolbefore   : [ 59, 'Insert Column Before', 'tbcolbefore' ],
         tbcolafter    : [ 63, 'Insert Column After', 'tbcolafter' ],
         tbcolrm       : [ 29, 'Remove Column', 'tbcolrm' ],
         tbcellprops   : [ 64, 'Cell Properties', 'tbcellprops' ],
         tbcellsmerge  : [ 40, 'Merge Cells', 'tbcellsmerge' ],
         tbcellsplit   : [ 55, 'Split Cell', 'tbcellsplit' ],
         toggle        : [ 66, 'Toggle View', 'toggleview' ],
         underline     : [ 34, 'Underline', 'underline', null ],
         undo          : [ 38, 'Undo Last Action', 'undo', null ],
         unlink        : [ 32, 'Unlink', 'unlink', null ],
         unorderedlist : [ 14, 'Unordered List', 'insertunorderedlist', null ]
      },
      container     : 'content',
      defaultBody   : '\u00a0',
      defaultClass  : 'wysiwyg_container',
      defaultState  : true,
      iconGridSize  : 30,
      iconsPerRow   : 10,
      iframeMargin  : 80,
      iframePadding : 14,
      minWidth      : 600,
      panels        : {
         alignment  : [ 'justifyleft', 'justifycenter',
                        'justifyright', 'justifyfull' ],
         control    : [ 'toggle', 'clear', 'nexttoolbar' ],
         edit1      : [ 'undo', 'redo' ],
         edit2      : [ 'undo', 'redo', 'copy', 'cut', 'paste', 'pastetext',
                        'pasteformattext', 'removeformat' ],
         edit3      : [ 'undo', 'redo', 'copy', 'cut', 'paste', 'pastetext',
                        'pasteformattext', 'removeformat', 'elfinder' ],
         elements   : [ 'horizontalrule', 'nbsp' ],
         fonts      : [ 'bigger', 'smaller', 'forecolor' ],
         format     : [ 'h1', 'h2', 'h3', 'paragraph',
                        'preformatted', 'div', 'blockquote' ],
         images     : [ 'image' ],
         indent     : [ 'outdent', 'indent' ],
         links      : [ 'link', 'unlink', 'anchor' ],
         lists      : [ 'orderedlist', 'unorderedlist' ],
         media      : [ 'image', 'flash' ],
         style      : [ 'bold', 'italic', 'underline', 'strikethrough',
                        'subscript', 'superscript' ],
         tables     : [ 'table', 'tableprops', 'tablerm',  'tbrowbefore',
                        'tbrowafter', 'tbrowrm', 'tbcolbefore', 'tbcolafter',
                        'tbcolrm', 'tbcellprops', 'tbcellsmerge',
                        'tbcellsplit' ],
         view       : [ 'hilitecolor', 'fullscreen' ]
      },
      selector      : '.wysiwyg',
      spacerWidth   : 10,
      toolbars      : [
         [ 'control', 'style' ],
         [ 'control', 'style', 'alignment', 'lists', 'links' ],
         [ 'control', 'style', 'format', 'fonts', 'alignment',
           'indent', 'lists', 'links', 'elements', 'images' ],
         [ 'control', 'edit1',
           'style', 'format', null, 'fonts', 'alignment',
          'indent', 'lists', 'links', 'elements', 'images' ],
         [ 'control', 'edit2', 'view',
           'style', 'format', null, 'fonts', 'alignment',
           'indent', 'lists', 'links', 'elements', 'images' ],
         [ 'control', 'edit3', 'view',
           'style', 'format', null, 'fonts', 'alignment',
           'indent', 'lists', 'links', 'elements', 'media', null, 'tables' ]
      ]
   },

   initialize: function( options ) {
      this.setBuildOptions( options ); this.build();
   },

   attach: function( el ) {
      var opt    = this.options,
          editor = {
         element: el,
         height : -1,
         barNum : opt.barNum,
         open   : ! opt.defaultState,
         toolbar: new Element( 'span',   { class: 'toolbar' } ),
         iframe : new Element( 'iframe', { frameborder: 0, src: 'about:blank' })
      };

      this.loader = function( self, editor ) {
         return function() {
            editor.iframe.removeEvent( 'load', this.loader );
            editor.doc = editor.iframe.contentWindow.document;
            this.initialiseBody( editor, editor.element.value );
            editor.doc.designMode = 'on';
            return this.toggleView( editor );
         }.bind( self );
      }( this, editor );

      editor.iframe.addEvent( 'load', this.loader );

      new Element( 'div', {
         class: opt.defaultClass
      } ).injectBefore( el ).adopt( editor.toolbar, editor.iframe, el );

      this.initialiseToolbar( editor );

      window.addEvent( 'submit', function() {
         if (editor.open) this.toTextarea( editor );
      }.bind( this ) );

      el.editor = editor;
   },

   addButton: function( editor, b ) {
      var but = this.options.buttons[ b ]; if (! but) return false;
      var el  = Browser.Engine.trident
              ? new Element( 'a', { class: b, href: '//' + b, title: but[ 1 ] })
              : new Element( 'span', { class: b, title: but[ 1 ] } );

      if (b != 'toggle') this.setIcon( el, but[ 0 ] );

      var handler = function( self, editor, b ) {
         return function( ev ) {
            ev = new Event( ev ); ev.stop();

            return b == 'toggle' ? this.toggleView( editor, true )
                                 : this.exec( editor, b );
         }.bind( self );
      }( this, editor, b );

      el.addEvent( 'click', handler ).inject( editor.toolbar );
      return true;
   },

   clean: function( html ) {
      return html
         .replace( /<[^> ]*/g, function( s ) { return s.toLowerCase() } )
         .replace( /<[^>]*>/g, function( s ) {
               s = s.replace( / [^=]+=/g, function( a ) {
                     return a.toLowerCase() } ); return s } )
         .replace( /<[^>]*>/g, function( s ) {
               s = s.replace( /( [^=]+=)([^\"][^ >]*)/g, '$1\"$2\"' );
               return s } )
         .replace( /(<[^>]+) array="[^\"]*"([^>]*>)/g, '$1$2' )
         .replace( /<span style="font-weight: normal;">(.+?)<\/span>/gm, '$1' )
         .replace( /<span style="font-weight: bold;">(.+?)<\/span>/gm,
                   '<strong>$1</strong>' )
         .replace( /<span style="font-style: italic;">(.+?)<\/span>/gm,
                   '<em>$1</em>' )
         .replace( /<span style="(font-weight: bold; ?|font-style: italic; ?){2}">(.+?)<\/span>/gm,
                   '<strong><em>$2</em></strong>' )
         .replace( /<b(\s+|>)/g, '<strong$1' )
         .replace( /<\/b(\s+|>)/g, '</strong$1' )
         .replace( /<i(\s+|>)/g, '<em$1' )
         .replace( /<\/i(\s+|>)/g, '</em$1' )
         .replace( /<u>(.+?)<\/u>/gm,
                   '<span style="text-decoration: underline;">$1</span>' )
         .replace( /<img src="([^\">]*)">/g, '<img alt="Image" src="$1" />' )
         .replace( /(<img [^>]+[^\/])>/g, '$1 />' )
         .replace( /(<[^>]+)\s+>/g, '$1>' )
         .replace( /<br>\s*<\//g, '</' )
         .replace( /^&nbsp\;/g, ' ' )
         .replace( /&nbsp\;$/g, ' ' )
         .replace( /^\s+|\s+$/g, '' );
      /*
         .replace( /<(br|hr)>/g, '<$1 />' )
         .replace(/\s{2,}/g,' ')
         .replace(/<[^>]*>/g,function(s){s=s.replace(/ ([^=]+)="[^\"]*"/g,function(a,b){if(b=='alt'||b=='class'||b=='href'||b=='id'||b=='name'||b=='src'||b=='style'||b=='title'){return a}return''});return s})
         .replace(/<font[^>]*?>(.+?)<\/font>/gm,'$1')
         .replace(/<font>|<\/font>/gm,'')
         .replace(/<(table|tbody|tr|td|th)[^>]*>/g,'<$1>')
         .replace(/<\?xml[^>]*>/g,'')
         .replace(/<[^ >]+:[^>]*>/g,'')
         .replace(/<\/[^ >]+:[^>]*>/g,'')
         .replace(/(<br(\s+\/)?>)([^\n]|[^\r])/g,"$1\r\n$3")
         .replace(/<br(\s+\/)?>$/g, '')
         .replace(/(<[^\/]>|<[^\/][^>]*[^\/]>)\s*<\/[^>]*>/g,'')
      */
   },

   exec: function( editor, b, v ) {
      if (! editor.open) return;

      editor.iframe.contentWindow.focus();

      var but = this.options.buttons[ b ],
          doc = editor.doc,
          val = v || but[ 3 ];

      if (! v && $defined( but[ 4 ] )
          && ! (val = prompt( but[ 3 ], but[ 4 ] ))) return;

      switch (b) {
      case 'anchor':
         var html = '<a id="' + val + '" title="Bookmark: ' + val + '"> </a>';

         return doc.execCommand( 'inserthtml', false, html );
      case 'fullscreen':
         return this.fullscreen( editor );
      case 'nbsp':
         return doc.execCommand( 'inserthtml', false, '\u00a0' );
      case 'nexttoolbar':
         return this.nextToolBar( editor );
      default:
         var cmds = but[ 2 ].split( '+' );

         for (var i = 0, l = cmds.length; i < l; i++) {
            doc.execCommand( cmds[ i ], false, val );
         }
      }

      if (b == 'clear') this.initialiseBody( editor );

      return false;
   },

   fullscreen: function( editor ) {
      var height, width, iframe = editor.iframe,
          toolbar = editor.toolbar, opt = this.options;

      if (editor.height == -1) {
         var container = $( opt.container );

         editor.width  = iframe.getSize().x;
         editor.height = iframe.getSize().y;
         width         = container.getSize().x - opt.iframeMargin;
         height        = container.getSize().y - opt.iframeMargin
                         - toolbar.getSize().y;
      }
      else { width = editor.width; height = editor.height; editor.height = -1; }

      toolbar.setStyle( 'width', (width  + opt.iframePadding) + 'px' );
      iframe.setStyle(  'width',  width  + 'px' );
      iframe.setStyle(  'height', height + 'px' );
   },

   initialiseBody: function( editor, html ) {
      html = html && html.length > 0
           ? html.replace( /&nbsp;/g, '\u00a0' ) : this.options.defaultBody;
      $( editor.doc.body ).set( 'html', html );
   },

   initialiseToolbar: function( editor ) {
      var opt      = this.options,
          panels   = opt.toolbars[ editor.barNum ],
          barWidth = 0,
          rowWidth = 0;

      editor.toolbar.empty();

      panels.each( function( p, index ) {
         if (! p) {
            new Element( 'br' ).inject( editor.toolbar ); rowWidth = 0; return;
         }

         var found = false;

         opt.panels[ p ].each( function( b ) {
            var added = this.addButton( editor, b );

            if (added) rowWidth += opt.buttonWidth;

            found = found || added;
         }, this );

         if (found && $defined( panels[ index + 1 ] )) {
            new Element( 'span', { class: 'spacer' } ).inject( editor.toolbar );

            rowWidth += opt.spacerWidth;
         }

         barWidth = Math.max( barWidth, rowWidth );
      }, this );

      barWidth = Math.max( opt.minWidth, barWidth );
      editor.toolbar.setStyle( 'width', barWidth + 'px' );
      editor.iframe.setStyle( 'width', (barWidth - opt.iframePadding) + 'px' );
   },

   nextToolBar: function( editor ) {
      editor.barNum += 1;

      if (editor.barNum > this.options.toolbars.length - 1) editor.barNum = 0;

      this.initialiseToolbar( editor );
   },

   setIcon: function( el, butNum ) {
      var opt = this.options,
          x   = 0 - opt.iconGridSize * (butNum % opt.iconsPerRow),
          y   = 0 - opt.iconGridSize * Math.floor( butNum / opt.iconsPerRow );

      el.setStyle( 'background-position', x + 'px ' + y + 'px' );
   },

   toEditor: function( editor, view ) {
      var html = editor.element.value.trim() || '';

      this.initialiseBody( editor, html );

      if (view) {
         editor.element.addClass( 'hidden' );
         editor.iframe.removeClass( 'hidden' );
         editor.toolbar.removeClass( 'disabled' );
      }
   },

   toggleView: function( editor, focus ) {
      if (editor.doc.body) {
         editor.open = ! editor.open;

         if (editor.open) this.toEditor( editor, true );
         else this.toTextarea( editor, true );

              if (focus &&   editor.open) editor.iframe.contentWindow.focus();
         else if (focus && ! editor.open) editor.element.focus();
      }

      return false;
   },

   toTextarea: function( editor, view ) {
      var doc; if (! (doc = editor.doc)) return;

      editor.element.value = this.clean( doc.body.innerHTML.unescapeHTML() );

      if (view) {
         editor.element.removeClass( 'hidden' );
         editor.iframe.addClass( 'hidden' );
         editor.toolbar.addClass( 'disabled' );
      }
   }
} );

function Expand_Collapse() {}

/* Local Variables:
 * mode: javascript
 * tab-width: 3
 * End:
 */
