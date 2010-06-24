/* @(#)$Id: 15html-formwidgets.js 1017 2010-06-24 23:42:29Z pjf $

   Portions of this code are taken from MooTools 1.2 which is:
      Copyright (c) 2006-2008 [Valerio Proietti](http://mad4milk.net/).
*/

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

      var options = this.options;

      if (options.alwaysHide) options.wait = true;

      if ($chk( options.show )) {
         options.display = false; this.previous = options.show;
      }

      if (options.start) {
         options.display = false; options.show = false;
      }

      if (options.opacity) this.effects.opacity = 'fullOpacity';

      if (options.width) this.effects.width = options.fixedWidth
                                            ? 'fullWidth' : 'offsetWidth';

      if (options.height) this.effects.height = options.fixedHeight
                                              ? 'fullHeight' : 'scrollHeight';

      for (var i = 0, l = this.togglers.length; i < l; i++)
         this.addSection( this.togglers[ i ], this.elements[ i ] );

      this.elements.each( function( el, i ) {
         if (options.show === i) {
            this.fireEvent( 'active', [ this.togglers, i , el ] );
         } else {
            for (var fx in this.effects) el.setStyle( fx, 0 );
         }
      }, this );

      if ($chk( options.display ) || options.initialDisplayFx === false)
         this.display( options.display, options.initialDisplayFx );

      if (options.fixedHeight !== false) options.returnHeightToAuto = false;

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
      var options   = this.options;

      toggler.store( 'accordion:display', displayer );
      toggler.addEvent( options.trigger, displayer );

      if (options.height)
         el.setStyles( { 'padding-top': 0, 'padding-bottom': 0 } );

      if (options.width)
         el.setStyles( { 'padding-left': 0, 'padding-right': 0 } );

      if (options.fixedWidth) {
         el.fullWidth = options.fixedWidth;
         el.setStyle( 'overflow-x', 'auto' );
      }
      else { el.setStyle( 'overflow-x', 'hidden' ) }

      if (options.fixedHeight) {
         el.fullHeight = options.fixedHeight;
         el.setStyle( 'overflow-y', 'auto' );
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

      useFx = $pick( useFx, true ); var obj = {}, options = this.options;

      if (options.returnHeightToAuto) {
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

      if ((this.timer && options.wait)
          || (index === this.previous && ! options.alwaysHide)) return this;

      this.previous = index;

      this.elements.each( function( el, i ) {
         var hide = false; obj[ i ] = {};

         if (i != index) {
            hide = true;
         } else if (options.alwaysHide
                    && ((el.offsetHeight > 0 && options.height)
                        || el.offsetWidth > 0 && options.width)) {
            hide = this.selfHidden = true;
         }

         this.fireEvent( hide ? 'background' : 'active',
                         [ this.togglers, i,  el ] );

         for (var fx in this.effects)
            obj[ i ][ fx ] = hide ? 0 : el[ this.effects[ fx ] ];
      }, this );

      this.internalChain.chain( function() {
         if (options.returnHeightToAuto && ! this.selfHidden) {
            var el = this.elements[ index ];

            if (el) el.setStyle( 'height', 'auto' );
         };
      }.bind(this) );

      return useFx ? this.start( obj ) : this.set( obj );
   },

   redisplay: function() {
      var index = this.previous; this.previous = -1;

      return this.display( index );
   },

   reload: function( index ) {
      if (! index || index >= this.togglers.length) index = 0;

      var toggler = this.togglers[ index ];

      if ($defined( toggler ) && $defined( toggler.onclick )) toggler.onclick();
   },

   resize: function( height, width ) {
      this.elements.each( function( el ) {
         if (height) el.fullHeight = this.options.fixedHeight = height;
         if (width)  el.fullWidth  = this.options.fixedWidth  = width;
      }, this );

      return this.redisplay();
   }
} );

/*

A mooTools plugin by Gary Glass (www.bookballoon.com)
mailto:bookballoon -at- bookballoon.com

Based on a jQuery plugin by Chrys Bader (www.chrysbader.com).
Thanks to Aaron Newton for reviews and improvements.

Copyright (c) 2009 Gary Glass (www.bookballoon.com)
Dual licensed under the MIT (MIT-LICENSE.txt)
and GPL (GPL-LICENSE.txt) licenses.

Usage: new AutoSize( options );

*/

var AutoSize = new Class( {
   Implements: [ Events, Options ],

   options     : {
      interval : 1100,       // update interval in milliseconds
      margin   : 30,         // gap (in px) to maintain between last line
                             // of text and bottom of textarea
      minHeight: 48,         // minimum height of textarea
      selector : '.autosize' // element class to search for
   },

   initialize: function( options ) {
      this.setOptions( options ); options = this.options; this.collection = [];

      if (options.selector) $$( options.selector ).each( this.build, this );
   },

   build: function( el ) {
      var autoSizer = {};

      autoSizer.element = $( el );
      autoSizer.dummy = new Element( 'div', {
         class : 'autosize_dummy',
         styles: {
            'overflow-y': 'auto',
            'position'  : 'absolute',
            'top'       : '0px',
            'left'      : '-9999px'
         }
      } ).setStyles
         ( el.getStyles
           ( 'font-size', 'font-family', 'width', 'line-height', 'padding' )
           ).injectBefore( el );
      autoSizer.html = '';
      autoSizer.minHeight
         = Math.max( this.options.minHeight, el.getSize().y );
      this.resize.periodical( this.options.interval, this, autoSizer );
      this.collection.include( autoSizer );
   },

   resize: function( autoSizer ) {
      var el = autoSizer.element, html = el.value;

      html = html.replace( /\r\n|\n/g, '<br />' );

      if (autoSizer.html == html ) return;

      autoSizer.html = html; autoSizer.dummy.set( 'html', html );

      var options       = this.options;
      var dummyHeight   = autoSizer.dummy.getSize().y;
      var triggerHeight = dummyHeight + options.margin;
      var newHeight     = Math.max( autoSizer.minHeight, triggerHeight );

      if (el.clientHeight != newHeight) {
         new Fx.Tween( el, {
            duration  : 1000,
            property  : 'height',
            transition: Fx.Transitions.linear } ).start( newHeight );
      }

      return;
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
      this.setOptions( options ); options = this.options;

      if (options.selector) $$( options.selector ).each( this.build, this );
   },

   build: function( el ) {
      var button, config, options = this.options, submit = options.submit;

      if (! (config = options.config[ el.id ])) return;

      if (submit && (button = $( el.id + '_clear' )))
         button.addEvent( 'click', function() { submit.clearField( el.id ) } );

      Calendar.setup( $extend( config, {
               inputField: el.id, button: el.id + '_trigger' } ) );
   }
} );

var CheckboxReplace = new Class( {
   Implements: [ Events, Options ],

   options               : {
      checkboxSelector   : 'input[type=checkbox]',
      radiobuttonSelector: 'input[type=radio]',
      replaceAll         : true,
      suffix             : '_replacement'
   },

   initialize: function( options ) {
      this.setOptions( options );
      this.boxes = [];

      if (this.options.replaceAll) this.replaceAll();
   },

   replaceAll: function() {
      var checks = document.getElements( this.options.checkboxSelector    );
      var radios = document.getElements( this.options.radiobuttonSelector );

      checks.each( this.replace.bind( this ) );
      radios.each( this.replace.bind( this ) );
   },

   replace: function( el ) {
      var oldbox = $( el ), newbox, suffix = this.options.suffix;
      var newId  = oldbox.name + (oldbox.type == 'checkbox'
                                  ? '' : oldbox.value) + suffix ;

      if (! (newbox = $( newId ))) {
         newbox = new Element( 'span', {
               class: 'checkbox' + (oldbox.checked ? ' checked' : ''),
               id   : newId,
               name : oldbox.name
         } );
         this.boxes.push( [ oldbox, newbox ] );
         oldbox.setStyles( { position: 'absolute', left: '-9999px' } );
         newbox.injectBefore( oldbox );
      }

      newbox.addEvent( 'click', function() {
         if (oldbox.getProperty( 'disabled' )) return;

         newbox.toggleClass( 'checked' );

         if (newbox.hasClass( 'checked' )) {
            oldbox.setProperty( 'checked', 'checked' );

            if (oldbox.type == 'radio') {
               this.boxes.each( function( other ) {
                  if (other[ 0 ]      != oldbox
                   && other[ 0 ].name == oldbox.name
                   && other[ 1 ].hasClass      ( 'checked' )) {
                      other[ 0 ].removeProperty( 'checked' );
                      other[ 1 ].toggleClass   ( 'checked' );
                  }
               } );
            }
         }
         else oldbox.removeProperty( 'checked' );
      }.bind( this ) );

      return;
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

      this.setOptions( options );
      // this is where we'll put the real content
      this.cache = new Element( 'div' );
      this.cache.adopt( el.getChildren().clone() );
      this.node  = $( this.options.target || el );

      if (! this.node.data) this.node.data = new Hash( { lastWidth: 0 } );

      // images loading after dom load can screw up the column heights,
      // so recolumnize after images load
      if (! this.options.ignoreImageLoading && ! this.options.target) {
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

      this.columnizeIt();

      if (! this.options.buildOnce) {
         window.addEvent( 'resize', function() {
            this.columnizeIt();
         }.bind( this ) );
      }
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

   columnizeIt: function() {
      var data = this.node.data, size = this.node.getSize();

      if (data.get( 'lastWidth' ) == size.x || data.get( 'columnizing' ))
         return;

      data.set( 'lastWidth', size.x ); data.set( 'columnizing', true );

      var options = this.options;
      var numCols = options.columns
                  ? options.columns : Math.round( size.x / options.width );

      if (numCols <= 1) return this.singleColumnizeIt();

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
            var el = new Element( 'span', { class: className, styles: style } );

            el.injectInside( this.node );
         }

         // fill all but the last column (unless overflowing)
         var i = 0;

         while (i < numCols - (options.overflow ? 0 : 1)
                || horizontal && destroyable.childNodes.length) {
            if (this.node.childNodes.length <= i) {
               // we ran out of columns, make another
               var el = new Element( 'span',
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

   singleColumnizeIt: function() {
      var options = this.options;
      var style   = { float: options.float, padding: '0px 1.5%', width: '97%' };
      var col     = new Element( 'span', { class : 'column first last',
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
   Implements: [ Options ],

   options             : {
      classNames       : [ 'zero', 'one', 'two', 'three', 'four', 'five',
                           'six', 'seven', 'eight', 'nine', 'ten',
                           'eleven', 'twelve', 'thirteen', 'fourteen',
                           'fifteen' ],
      columnizerOptions: {},
      selector         : '.multiColumn'
   },

   initialize: function( options ) {
      this.setOptions( options ); options = this.options; this.collection = [];

      if (options.selector) $$( options.selector ).each( function( el ) {
         var cols    = el.getProperty( 'class' ).split( ' ' )[ 0 ];
         var options = this.options.columnizerOptions;

         options.columns = this.options.classNames.indexOf( cols );
         this.collection.include( new Columnizer( el, options ) );
      }.bind( this ) );
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
      this.setOptions( options ); options = this.options;

      var cname = (options.prefix ? options.prefix + '_' : '') + options.name;
      var copts = { domain: options.domain, duration: options.expire,
                    path  : options.path,   secure  : options.secure };

      this.cookie = new Cookie( cname, copts );
   },

   get: function( name ) {
      var val = this.cookie.read();

      if (name && val) {
         var cookies = val.split( '+' );

         for (var i = 0, cl = cookies.length; i < cl; i++) {
            var pair = cookies[ i ].split( '~' );

            if (unescape( pair[ 0 ] ) == name) return unescape( pair[ 1 ] );
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
      this.setOptions( options );

      if (this.options.selector)
         $$( this.options.selector ).each( function( el ) {
            $( el.id + '_add' ).addEvent( 'click', function( e ) {
               e = new Event( e ); e.stop(); return this.addItem( el.id );
            }.bind( this ) );

            $( el.id + '_remove' ).addEvent( 'click', function( e ) {
               e = new Event( e ); e.stop(); return this.removeItem( el.id );
            }.bind( this ) );
         }, this );
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
      this.setOptions( options );

      if (this.options.selector)
         $$( this.options.selector ).each( function( el ) {
            $( el.id + '_add' ).addEvent( 'click', function( e ) {
               e = new Event( e ); e.stop(); return this.addItem( el.id );
            }.bind( this ) );

            $( el.id + '_remove' ).addEvent( 'click', function( e ) {
               e = new Event( e ); e.stop(); return this.removeItem( el.id );
            }.bind( this ) );
         }, this );
   },

   addItem: function( id ) {
      var all = $( id ), members = $( id + '_current' );

      for (var i = all.length - 1; i >= 0; i--) {
         if (all.options[ i ].selected != true) continue;

         var value = all.options[ i ].value;

         if (! this.deleteHidden( id + '_deleted', value )) {
            var name = all.name.replace( /^_/g, '' ) + '_added';

            new Element( 'input', {
               name:  name, type: 'hidden', value: value
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
      selector: 'fade',   // Class name matching links to fade
      speed   : 20        // Millisecs between colour changes
   },

   initialize: function( options ) {
      this.setOptions( options );

      $$( 'a' ).each( function( el ) {
         var ignoreIt = el.className.indexOf( this.options.selector ) < 0;

         if (! ignoreIt && ! el.onmouseover && ! el.onmouseout) {
            el.onmouseover = this.startFade.bind( this, el );
            el.onmouseout  = this.clearFade.bind( this, el );
         }
      }.bind( this ) );
   },

   clearFade: function( el ) {
      if (el.timer) $clear( el.timer );

      el.timer = this.fade.periodical( this.options.speed, this, [ el, 0 ] );
      return;
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
      return;
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
      return;
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
   initialize: function( options ) {
      this.url = options.url;
   },

   request: function( action, id, val, onComplete ) {
      if (onComplete) this.onComplete = onComplete;

      new Request( { onSuccess: this.updateContent.bind( this ),
                     url      : this.url + action } ).get( {
                        'content-type': 'text/xml', 'id': id, 'val': val } );
   },

   updateContent: function( text, xml ) {
      var rows = xml.documentElement.getElementsByTagName( 'items' );
      var id   = xml.documentElement.getAttribute( 'id' );
      var html = '';

      $each( rows, function( row ) {
         for (var i = 0; i < row.childNodes.length; i++) {
            html += row.childNodes[ i ].nodeValue;
         }
      } );

      $( id ).set( 'html', html.unescapeHTML() );

      if (this.onComplete) this.onComplete.call( this );
   }
} );

var Sidebar = new Class( {
   Implements: [ Options ],

   options                : {
      accordion           : 'accordionDiv',
      panel               : 0,
      prefix              : 'sidebar',
      togglerHeight       : 25,
      togglersMarginHeight: 15,
      width               : 250
   },

   initialize: function( state, options ) {
      this.setOptions( options );
      this.cookies = state.cookies;
      this.state   = state;

      var options  = this.options, prefix = options.prefix, sb;

      if (! (sb = $( prefix + 'Disp' ))) return;

      var sb_state = this.cookies.get( prefix ) ? true : false;
      var sb_panel = this.cookies.get( prefix + 'Panel' ) || options.panel;
      var sb_width = this.cookies.get( prefix + 'Width' ) || options.width;

      this.cookies.set( prefix + 'Width', sb_width );

      /* Setup the slide in/out effect */
      this.slider  = new Fx.Slide( prefix + 'Container', {
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

               this.state.resize();
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
            this.state.resize(); this.slider.slideIn();
         }

         return false;
      }.bind( this ) );

      /* Setup the horizontal resize grippy for the side bar */
      sb.makeResizable( {
         handle   : $( prefix + 'Grippy' ),
         limit    : { x: [ 150, 450 ] },
         modifiers: { x: 'width', y: false },
         onDrag   : function() { this.state.resize( true ) }.bind( this )
      } );

      var toggler_class = '.' + prefix + 'Header';

      /* Create an Accordion widget in the side bar */
      this.accordion = new Fx.Accordion( $( options.accordion ), {
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
      }, toggler_class, '.' + prefix + 'Panel' );

      /* Redisplay and reload the last accordion side bar panel */
      if (sb_state) this.accordion.reload( sb_panel );

      this.accordion.display( sb_panel );
      return;
   },

   getAccordionHeight: function( el, togglers ) {
      var options = this.options;
      var height  = (options.togglerHeight * togglers.length)
                   + options.togglersMarginHeight;

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

var ServerUtils = new Class( {
   initialize: function( options ) {
      this.url = options.url;
   },

   checkField: function( id, val ) {
      new Request( {
         'onSuccess': this.updateContent, 'url': this.url + 'check_field'
      } ).get( { 'content-type': 'text/xml', 'id': id, 'val': val } );
   },

   postData: function( url, data ) {
      new Request( { 'url': url } ).post( data );
   },

   updateContent: function( text, xml ) {
      var doc    = xml.documentElement;
      var el     = $( doc.getAttribute( 'id' ) );
      var result = doc.getAttribute( 'result' );

      el.set( 'html', result );
      el.className = result ? doc.getAttribute( 'class_name' ) : 'hidden';
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
      this.setOptions( options ); options = this.options; this.collection = [];

      if (options.selector) $$( options.selector ).each( this.build, this );
   },

   build: function( el ) {
      var config, options = this.options, submit = options.submit;

      if (! (config = options.config[ el.id ])) return;

      var name       = config.name;       delete config[ 'name'       ];
      var default_v  = config.default_v;  delete config[ 'default_v'  ];
      var knob_class = config.knob_class; delete config[ 'knob_class' ];
      var knob       = el.getElement( knob_class );

      config = $extend( config, {
         onChange: function( value ) {
            submit.setField.call( submit, name, value ) }
      } );

      this.collection.include( new Slider( el, knob, config ).set( default_v ));
   }
} );

var SubmitUtils = new Class( {
   Implements: [ Options ],

   options          : {
      config        : {},
      formName      : null,
      chooseSelector: '.chooser_button',
      submitSelector: '.submit'
   },

   initialize: function( options ) {
      this.cookies = options.cookies; delete options[ 'cookies' ];

      this.setOptions( options ); options = this.options;

      this.form = document.forms ? document.forms[ options.formName ] : $empty;

      if (options.chooseSelector)
         $$( options.chooseSelector ).each( this.attachChooser, this );

      if (options.submitSelector)
         $$( options.submitSelector ).each( this.attachSubmit, this );
   },

   attachChooser: function( el ) {
      var config; if (! (config = this.options.config[ el.id ])) return;

      var winPrefs  = 'width=' + config.width + ', screenX=' + config.screen_x;
          winPrefs += ', height=' + config.height + ', screenY=';
          winPrefs += config.screen_y + ', dependent=yes, titlebar=no, ';
          winPrefs += 'scrollbars=yes';

      el.addEvent( 'click', function() {
         return this.chooser( config.field, config.href, winPrefs );
      }.bind( this ) );
   },

   attachSubmit: function( el ) {
      var config; if (! (config = this.options.config[ el.id ])) return;

      var ev = config.event || 'click';

      el.addEvent( ev, function() {
         return this[ config.method ].apply( this, config.args );
      }.bind( this ) );
   },

   chooser: function( name, base, winPrefs ) {
      var value = this.form.elements[ name ].value || '';

      if (value.indexOf( '%' ) < 0) this.form.submit();
      else {
         var uri  = base + '?form=' + this.options.formName;
             uri += '&field=' + name + '&value=' + value;

         top.chooser = window.open( uri, 'chooser', winPrefs );
         top.chooser.opener = top;
      }

      return false;
   },

   clearField: function( name ) {
      return this.setField( name, '' );
   },

   confirmSubmit: function( button, text ) {
      if (text.length < 1 || window.confirm( text )) {
         this.submitForm( button );
         return true;
      }

      return false;
   },

   refresh: function( name, value ) {
      if (name) this.cookies.set( name, value );

      this.form.submit();
   },

   returnValue: function( formName, name, value ) {
      if (formName && name && opener) {
         var forms = opener.document.forms[ formName ], field;

         if (forms && (field = forms.elements[ name ])) {
            field.value = value; if (field.focus) field.focus();
         }
      }

      window.close();
      return false;
   },

   setField: function( name, value ) {
      var els;

      if (name && (els = this.form.elements[ name ])) els.value = value;

      return value;
   },

   submitForm: function( button ) {
      this.setField( '_method', button ); this.form.submit(); return false;
   },

   submitOnReturn: function( ev, button ) {
      ev = new Event( ev );

      if (ev.key == 'enter') {
         if (document.forms) this.submitForm( button );
         else window.alert( 'Document contains no forms' );
      }

      return false;
   }
} );

var TableUtils = new Class( {
   Implements: [ Events, Options ],

   options          : {
      editSelector  : 'table.form',
      formName      : null,
      gridSelector  : '.liveGrid',
      gridSize      : 10,
      gridToggle    : true,
      iconClasses   : [ 'a', 'b' ],
      inputCellClass: 'dataField',
      rowClass      : 'form_row',
      rowSelector   : 'tr[id*=_row]',
      sortSelector  : 'th.sort',
      textCellClass : 'dataValue',
      url           : null
   },

   initialize: function( options ) {
      this.setOptions( options ); var opt = this.options;

      this.form = document.forms ? document.forms[ opt.formName ] : $empty;

      this.sortables = new Hash();

      if (opt.editSelector)
         $$( opt.editSelector ).each( function( el ) {
            $( el.id + '_add' ).addEvent( 'click', function( ev ) {
               ev = new Event( ev ); ev.stop();

               return this.addRows( el.id, true );
            }.bind( this ) );

            $( el.id + '_remove' ).addEvent( 'click', function( ev ) {
               ev = new Event( ev ); ev.stop(); return this.removeRows( el.id );
            }.bind( this ) );
         }, this );

      if (opt.gridSelector)
         $$( opt.gridSelector ).each( function( el ) {
            el.addEvent( 'click', function( ev ) {
               ev = new Event( ev ); ev.stop(); return this.liveGrid( el.id );
            }.bind( this ) );
         }, this );

      if (opt.sortSelector)
         $$( opt.sortSelector ).each( function( el ) {
            el.addEvent( 'click', function( ev ) {
               ev = new Event( ev ); ev.stop(); return this.sortRows( el.id );
            }.bind( this ) );
         }, this );
   },

   addRows: function( table_id, edit ) {
      var cNo   = 0, aelem, elem, opt = this.options;
      var rows  = $( table_id ).getElements( opt.rowSelector );
      var nrows = rows ? rows.length : 0;

      if (! (elem = $( table_id + '_edit' ))) return false;

      var row   = new Element( 'tr', {
         class: opt.rowClass, id: table_id + '_row' + nrows
      } );

      while (aelem = $( table_id + '_add' + cNo )) {
         var cell = new Element( 'td' );

         if (edit) {
            var type  = aelem.tag == 'textarea' ? 'textarea' : 'input';
            var input = new Element( type, {
               class: 'ifield',
               name : table_id + '_' + nrows + '_' + cNo,
               value: aelem.value
            } );

            if (aelem.cols) input.setAttribute( 'cols', aelem.cols );
            if (aelem.rows) input.setAttribute( 'rows', aelem.rows );
            if (aelem.size) input.setAttribute( 'size', aelem.size );
            if (aelem.maxlength)
               input.setAttribute( 'maxlength', aelem.maxlength );

            cell.appendChild( input );
            cell.setAttribute( 'class', opt.inputCellClass );
         }
         else {
            cell.appendText( aelem.value );
            cell.setAttribute( 'class', opt.textCellClass );
         }

         row.appendChild( cell ); aelem.value = ''; cNo++;
      }

      if (edit) {
         var input = new Element( 'input', {
            name: table_id + '_select' + nrows, type: 'checkbox'
         } );
         var cell  = new Element( 'td', {
            align: 'center', class: (cNo % 2 == 0 ? 'even' : 'odd')
         } );

         cell.appendChild( input ); row.appendChild( cell );
      }

      row.injectBefore( elem );
      this.form.elements[ '_' + table_id + '_nrows' ].value = nrows + 1;
      return false;
   },

   createGrid: function( text, xml ) {
      var keyid  = this.gridKey + '_' + this.gridId;
      var count  = parseInt( xml.documentElement.getAttribute( 'totalcount' ));
      var rows   = xml.documentElement.getElementsByTagName( 'items' );
      var urlkey = this.options.url + this.gridKey + '_grid_rows';
      var opts   = {
         bufferSize    : 7,
         gridSize      : this.options.gridSize,
         prefetchBuffer: true,
         onScroll      : this.updateHeader.bind( this ),
         onFirstContent: this.updateHeader.bind( this, 0 ),
         totalRows     : count
      };
      var html   = '';

      $each( rows, function( row ) { html += row.childNodes[ 0 ].nodeValue } );

      $( keyid + 'Disp' ).set( 'html', html.unescapeHTML() );

      this.gridObj = new LiveGrid( keyid + '_grid', urlkey, opts );
   },

   liveGrid: function( elId ) {
      var el, pair = elId.split( '_' ), key = pair[ 0 ], id = pair[ 1 ];

      if (! key || ! id || ! (el = $( elId + 'Disp' ))) return;

      var options = this.options;

      if (options.gridToggle && el.getStyle( 'display' ) != 'none') {
         el.setStyle( 'display', 'none' );

         if (el = $( elId + 'Icon' )) el.className = options.iconClasses[ 0 ];

         this.gridKey = null; this.gridId = null; this.gridObj = null;
         return;
      }

      if (this.gridKey && this.gridId) {
         var keyid = this.gridKey + '_' + this.gridId, prev;

         if (prev = $( keyid + 'Disp' )) prev.setStyle( 'display', 'none' );
         if (prev = $( keyid + 'Icon' ))
            prev.className = options.iconClasses[ 0 ];

         this.gridKey = null; this.gridId = null; this.gridObj = null;
      }

      el.setStyle( 'display', '' ); this.gridKey = key; this.gridId = id;

      if (el = $( elId + 'Icon' )) el.className = options.iconClasses[ 1 ];

      new Request( {
         onSuccess: this.createGrid.bind( this ),
         url      : options.url + key +  '_grid_table' } ).get( {
            'content-type': 'text/xml', 'id': id, 'val': options.gridSize } );
      return;
   },

   removeRows: function( table_id ) {
      var table;

      if (table = $( table_id )) {
         var nrows = 0, selector = this.options.rowSelector;

         table.getElements( selector ).map( function( row, index ) {
            var cb = this.form.elements[ table_id + '_select' + index ];

            if (cb && cb.checked) row.destroy();
            else nrows++;
         }.bind( this ) );

         this.form.elements[ '_' + table_id + '_nrows' ].value = nrows;
      }

      return;
   },

   sortRows: function( id ) {
      var a        = id.split( '.' );
      var table_id = a[ 0 ], column_type = a[ 2 ];
      var table    = $( table_id );
      var columns  = table.getElements( 'th' );
      var col_ids  = columns.map( function( column ) { return column.id } );

      if (! col_ids.contains( id )) return;

      var col_id   = col_ids.indexOf( id );
      var order    = this._get_sort_order( table_id, col_ids[ 0 ], id );
      var row_ids  = [];

      table.getElements( this.options.rowSelector ).map( function( row, index ){
         var field = this._get_sort_field( row.cells[ col_id ], column_type );

         return [ field, row.clone( true, true ), row_ids[ index ] = row.id ];
      }.bind( this ) ).sort( function( a, b ) {
         return a[ 0 ] < b[ 0 ] ? order[ 0 ]
             : (a[ 0 ] > b[ 0 ] ? order[ 1 ] : 0);
      } ).map( function( sorted_rows, index ) {
         var old_row_id = row_ids[ index ], new_row = sorted_rows[ 1 ];

         new_row.removeAttribute( 'id' ); new_row.replaces( $( old_row_id ) );

         return [ new_row, sorted_rows[ 2 ] ];
      } ).map( function( sorted_rows, index ) {
         var row = sorted_rows[ 0 ]; row.id = sorted_rows[ 1 ]; return row;
      } );

      this.fireEvent( 'sortComplete' );

      return;
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

   updateHeader: function( offset ) {
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
      cookiePrefix   : 'tabswapper_',
      cookies        : false,
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
   },

   tabs: [],

   initialize: function( el, options ) {
      this.setOptions( options ); var opt = this.options;

      this.cookieName = opt.cookies ? opt.cookiePrefix + el.id : null;

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
      var opt = this.options, name, panel;

      if (name = this.cookieName) panel = opt.cookies.get( name );

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
      var name;

      if (name = this.cookieName) this.options.cookies.set( name, index );

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

   options: { cookies: false, config: {}, selector: '.tabswapper' },

   initialize: function( options ) {
      this.setOptions( options ); var opt = this.options; this.collection = [];

      if (opt.selector) $$( opt.selector ).each( this.build, this );
   },

   build: function( el ) {
      var opt = this.options;
      var cfg = $merge( opt.config[ 'options' ], opt.config[ el.id ] );

      if (opt.cookies) cfg.cookies = opt.cookies;

      this.collection.include( new TabSwapper( el, cfg ) );
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
      this.setOptions( options );
      this.collection = [];
      this.tip = this.createTipMarkup();

      if (this.options.selector)
         $$( this.options.selector ).each( this.build, this );

      this.fireEvent( 'initialize' );
   },

   attach: function( el ) {
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

   build: function( el ) {
      this.collection.include( el );
      this.storeTitleAndText( el )
      this.attach( el );
   },

   createTipMarkup: function() {
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
      this.setup( el ); this.position( ev, el ); $clear( this.timer );
      this.timer = this.show.delay( this.options.showDelay, this, el );
   },

   elementLeave: function( ev, el ) {
      $clear( this.timer );
      this.timer = this.hide.delay( this.options.hideDelay, this, el );
   },

   elementMove: function( ev, el ) {
      this.position( ev, el );
   },

   hide: function( el ) {
      this.timer = $clear( this.timer );
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

         if ((pos + tip[ z ] - scroll[ z ]) > win[ z ])
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
      var max   = Math.floor( window.getWidth() / 4 );
      var text  = el.retrieve( 'tip:text'  ) || '';
      var title = el.retrieve( 'tip:title' ) || '';
      var w     = 10 * Math.max( title.length, text.length );

      w = w < 100 ? 100 : w > max ? max : w;

      this.titleCell.setStyle( 'width', parseInt( w ) + 'px' );
      this.title.empty().appendText( title || this.options.spacer );
      this.textCell.setStyle( 'width', parseInt( w ) + 'px' );
      this.text.empty().appendText( text || this.options.spacer );
   },

   show: function( el ) {
      this.timer = $clear( this.timer );

      if (this.options.timeout)
         this.timer = this.hide.delay( this.options.timeout, this );

      this.fireEvent( 'show', [ this.tip, el ] );
   },

   storeTitleAndText: function( el ) {
      if (el.retrieve( 'tip:title' )) return;

      var options = this.options;
      var title   = this._read( options.title, el );
      var text    = this._read( options.text,  el );

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

var Trees = new Class( {
   Implements: [ Options ],

   options          : {
      classPrefix   : 'tree',
      cookiePrefix  : 'tree',
      selector      : '.tree',
      sessionPath   : '/',
      sessionPrefix : 'html_formwidgets',
      usePersistance: true
   },

   initialize: function( options ) {
      this.setOptions( options ); options = this.options; this.collection = [];

      if (options.usePersistance) {
         var prefix = options.sessionPrefix + '_' + options.cookiePrefix;

         this.cookies = new Cookies( { path  : options.sessionPath,
                                       prefix: prefix } );
      }

      if (options.selector) $$( options.selector ).each( this.build, this );
   },

   attachControls: function( id ) {
      $( id + '_collapse_button' ).addEvent
         ( 'click', this.collapseTree.bind( this, id ) );
      $( id + '_expand_button' ).addEvent
         ( 'click', this.expandTree.bind( this, id ) );
   },

   attachToggler: function( dt, dd, klass, event ) {
      $$( '#' + dt.id + ' span.' + klass ).each( function( el ) {
         el.addEvent( event, function( e ) {
            e = new Event( e ); e.stop(); return this.toggle( dt, dd );
         }.bind( this ) );
      }, this );
   },

   attachTogglers: function( dt, dd ) {
      var prefix = this.options.classPrefix;

      this.attachToggler( dt, dd, prefix + '_node_ctrl', 'click'    );
      this.attachToggler( dt, dd, prefix + '_node_icon', 'dblclick' );
   },

   build: function( el, index ) {
      if (! el || ! el.childNodes || el.childNodes.length == 0) return;

      var dt, first = ! this.collection[ index ], node;

      this.collection[ index ] = true;

      if (first) this.attachControls( el.id );

      for (var i = 0, il = el.childNodes.length; i < il; i++) {
         if (! (node = $( el.childNodes[ i ] ))) continue;

         if (node.nodeName == 'DT') { dt = node; continue; }

         if (node.nodeName != 'DD') continue; var dd = node;

         this.setState( dt, dd, first ); this.attachTogglers( dt, dd );

         for (var j = 0, jl = dd.childNodes.length; j < jl; j++) {
            if ((node = $( dd.childNodes[ j ] )) && node.nodeName == 'DL')
               this.build( node, index );
         }
      }
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

      for (var i = 0, il = el.childNodes.length; i < il; i++) {
         if (! (node = $( el.childNodes[ i ] ))) continue;

         if (itemId != null && itemId == node.id) return true;

         if (node.nodeName == 'DT') { dt = node; continue; }

         if (node.nodeName != 'DD') continue; var dd = node;

         for (var j = 0, jl = dd.childNodes.length; j < jl; j++) {
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
      var list  = $( treeId ), o, ret;

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
   initialize: function( options ) {
      this.cname = options.prefix ? options.prefix + '_session' : 'session';
      this.copts = { path: options.path || '/', domain: options.domain || '' };

      if ($defined( options.customLogFn )) {
         if (typeof options.customLogFn != 'function')
            throw "customLogFn is not a function";
         else this.customLogFn = options.customLogFn;
      }

      this.quiet = false;

      if (options.target == 'top') this.placeOnTop();
   },

   log: function( message ) {
      if (this.quiet) return;

      message = "html-formwidgets.js: " + message;

      if (this.customLogFn) { this.customLogFn( message ); }
      else if (window.console && window.console.log) {
         window.console.log( message );
      }
   },

   openWindow: function( href, options ) {
      new Browser.Popup( href, options ); return false;
   },

   placeOnTop: function() {
      if (self != top) {
         if (document.images) top.location.replace( window.location.href );
         else top.location.href = window.location.href;
      }
   },

   wayOut: function( href ) {
      Cookie.dispose( this.cname, this.copts );

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
      this.setOptions( options ); var opt = this.options; this.collection = [];

      if (opt.selector) $$( opt.selector ).each( this.build, this );
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

   build: function( el, index ) {
      var opt    = this.options;
      var editor = {
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
            this.toggleView( editor );
         }.bind( self );
      }( this, editor );

      editor.iframe.addEvent( 'load', this.loader );

      new Element( 'span', {
         class: opt.defaultClass
      } ).injectBefore( el ).adopt( editor.toolbar, editor.iframe, el );

      this.initialiseToolbar( editor );

      window.addEvent( 'submit', function() {
         if (editor.open) this.toTextarea( editor );
      }.bind( this ) );

      this.collection.include( editor );
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

      var but = this.options.buttons[ b ];
      var doc = editor.doc, val = v || but[ 3 ];

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
      var height, width, iframe = editor.iframe;
      var toolbar = editor.toolbar, opt = this.options;

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
      var opt      = this.options;
      var panels   = opt.toolbars[ editor.barNum ];
      var barWidth = 0;
      var rowWidth = 0;

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
      var opt = this.options;
      var x   = 0 - opt.iconGridSize * (butNum % opt.iconsPerRow);
      var y   = 0 - opt.iconGridSize * Math.floor( butNum / opt.iconsPerRow );

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
 * mode: java
 * tab-width: 3
 * End:
 */
