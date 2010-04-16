/* @(#)$Id: 15html-formwidgets.js 984 2010-04-16 02:04:48Z pjf $

   Portions of this code are taken from MooTools 1.11 which is:
	   Copyright (c) 2007 Valerio Proietti, <http://mad4milk.net>

   Property: setHTML
      Sets the innerHTML of the Element. Should work for application/xhtml+xml

   Arguments:
      html - string; the new innerHTML for the element.

   Example:
      $('myElement').setHTML(newHTML) //the innerHTML of myElement
                                        is now = newHTML
*/

Element.extend( {
   setHTML: function( html ) {
      while (this.firstChild) this.removeChild( this.firstChild );

      return HTMLtoDOM( html, this );
   }
} );

/* Script: String.js
      Contains String prototypes.

   License:
      MIT-style license.

   Class: String
      A collection of The String Object prototype methods.
*/

String.extend( {
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
Script: Accordion.js
   Contains <Accordion>

License:
   MIT-style license.

Class: Accordion
   The Accordion class creates a group of elements that
   are toggled when their handles are clicked. When one elements
   toggles in, the others toggles back.  Inherits methods, properties,
   options and events from <Fx.Elements>.

Note:
   The Accordion requires an XHTML doctype.

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

var Accordion = Fx.Elements.extend( {
   options: {
      onActive    : Class.empty,
      onBackground: Class.empty,
      display     : 0,
      show        : false,
      height      : true,
      width       : false,
      opacity     : true,
      fixedHeight : false,
      fixedWidth  : false,
      wait        : false,
      alwaysHide  : false
   },

   initialize: function() {
      var container, elements, options, togglers;

      $each( arguments, function( argument, i ) {
         switch( $type( argument ) ) {
            case 'object' : options   = argument;      break;
            case 'element': container = $( argument ); break;
            default       : var temp = $$( argument );
                            if (!togglers) togglers = temp;
                            else elements = temp;
         }
      } );

      this.previous  = -1;
      this.togglers  = togglers || [];
      this.elements  = elements || [];
      this.container = $( container );
      this.setOptions( options );

      if (this.options.alwaysHide) this.options.wait = true;

      if ($chk( this.options.show )) {
         this.options.display = false; this.previous = this.options.show;
      }

      if (this.options.start) {
         this.options.display = false; this.options.show = false;
      }

      this.effects = {};

      if (this.options.opacity) this.effects.opacity = 'fullOpacity';

      if (this.options.width)
         this.effects.width = this.options.fixedWidth
                            ? 'fullWidth' : 'offsetWidth';

      if (this.options.height)
         this.effects.height = this.options.fixedHeight
                             ? 'fullHeight' : 'scrollHeight';

      for (var i = 0, l = this.togglers.length; i < l; i++)
         this.addSection( this.togglers[ i ], this.elements[ i ] );

      this.elements.each( function( el, i ) {
         if (this.options.show === i){
            this.fireEvent( 'onActive', [ this.togglers, i, el ] );
         }
         else {
            for (var fx in this.effects) el.setStyle( fx, 0 );
         }
      }, this );

      this.parent( this.elements );

      if ($chk( this.options.display )) this.display( this.options.display );
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

   addSection: function( toggler, element, pos ) {
      toggler  = $( toggler ); element = $( element );

      var test = this.togglers.contains( toggler );
      var len  = this.togglers.length;

      this.togglers.include( toggler ); this.elements.include( element );

      if (len && (!test || pos)){
         pos = $pick( pos, len - 1 );
         toggler.injectBefore( this.togglers[ pos ] );
         element.injectAfter( toggler );
      }
      else if (this.container && !test){
         toggler.inject( this.container ); element.inject( this.container );
      }

      var idx = this.togglers.indexOf( toggler );

      toggler.addEvent( 'click', this.display.bind( this, idx ) );

      if (this.options.height)
         element.setStyles( { 'padding-top': 0, 'padding-bottom': 0 } );

      if (this.options.width)
         element.setStyles( { 'padding-left': 0, 'padding-right': 0 } );

      if (this.options.fixedWidth) {
         element.fullWidth = this.options.fixedWidth;
         element.setStyle( 'overflow-x', 'auto' );
      }
      else { element.setStyle( 'overflow-x', 'hidden' ) }

      if (this.options.fixedHeight) {
         element.fullHeight = this.options.fixedHeight;
         element.setStyle( 'overflow-y', 'auto' );
      }
      else { element.setStyle( 'overflow-y', 'hidden' ) }

      if (!test){
         for (var fx in this.effects) element.setStyle( fx, 0 );
      }

      element.fullOpacity = 1;
      return this;
   },

   /*
   Property: display
      Shows a specific section and hides all others. Useful when
      triggering an accordion from outside.

   Arguments:
      index - integer, the index of the item to show, or the actual
              element to show.
   */

   display: function( index ) {
      index = ($type( index ) == 'element')
            ? this.elements.indexOf( index ) : index;

      if (index >= this.elements.length) index = 0;

      if ((this.timer && this.options.wait)
          || (index === this.previous
              && !this.options.alwaysHide)) return this;

      var obj = {};

      this.previous = index;
      this.elements.each( function( el, i ) {
         var hide = (i != index)
                 || (this.options.alwaysHide && (el.offsetHeight > 0));

         obj[i] = {};
         this.fireEvent( hide ? 'onBackground' : 'onActive',
                         [ this.togglers, i, el ] );

         for (var fx in this.effects)
            obj[i][fx] = hide ? 0 : el[ this.effects[fx] ];
      }, this );

      return this.start( obj );
   },

   showThisHideOpen: function( index ) { return this.display( index ) },

   redisplay: function() {
      var index = this.previous; this.previous = -1;

      return this.display( index );
   },

   reload: function( index ) {
      if (!index || index >= this.togglers.length) index = 0;

      if (!($defined( this.togglers[ index ] )
            && $defined( this.togglers[ index ].onclick ))) return;

      this.togglers[ index ].onclick();
   },

   resize: function( height, width ) {
      this.elements.each( function( el ) {
         if (height) el.fullHeight = this.options.fixedHeight = height;
         if (width)  el.fullWidth  = this.options.fixedWidth  = width;
      }, this );

      return this.redisplay();
   }
} );

Fx.Accordion = Accordion;

/* AUTOGROW TEXTAREA Version 1.0
 * A mooTools plugin by Gary Glass (www.bookballoon.com)
 * mailto:bookballoon -at- bookballoon.com
 *
 * Based on a jQuery plugin by Chrys Bader (www.chrysbader.com).
 * Thanks to Aaron Newton for reviews and improvements.
 *
 * Copyright (c) 2009 Gary Glass (www.bookballoon.com)
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * USAGE:
 *		new AutoSize( 'class_name', options );
 * where 'class_name' is the element class to search for, e.g.:
 *		new AutoSize( '.autosize', {} );
 */

var AutoSize = new Class( {
	options: {
		interval  : 1100, // update interval in milliseconds
		margin    : 24,   // gap (in px) to maintain between last line
                        // of text and bottom of textarea
		minHeight : 48    // minimum height of textarea
	},

   initialize: function( options ) {
      this.setOptions( options );
      this.collection = new Array();

      if (options.elements) $$( options.elements ).each( this.build, this );
   },

   build: function( el, index ) {
      var autoSizer = {};

      autoSizer.element = $( el );
		autoSizer.dummy = new Element( 'div', {
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
         = Math.max( this.options.minHeight, el.getSize().size.y );
		this.resize.periodical( this.options.interval, this, autoSizer );
      this.collection[ index ] = autoSizer;
   },

	resize: function( autoSizer ) {
      var el   = autoSizer.element;
		var html = el.value.replace( /\n|\r\n/g, '<br>X' ).toLowerCase();

		if (autoSizer.html == html ) return;

      autoSizer.html = html; autoSizer.dummy.setHTML( html );

      var options       = this.options;
      var dummyHeight   = autoSizer.dummy.getSize().size.y;
      var triggerHeight = dummyHeight + options.margin;
      var newHeight     = Math.max( autoSizer.minHeight, triggerHeight );

      if (el.clientHeight != triggerHeight) {
         el.effect( 'height', {
            duration  : 1000,
            transition: Fx.Transitions.linear } ).start( newHeight );
      }

      return;
	}
} );

AutoSize.implement( new Options, new Events );

var CheckboxReplace = new Class( {
   initialize: function( options ) {
      this.boxes = new Array();

      if (options.replaceAll) this.replaceAll();
   },

   replaceAll: function() {
      var checks = document.getElements( 'input[type=checkbox]' );
      var radios = document.getElements( 'input[type=radio]'    );

      checks.each( this.replace.bind( this ) );
      radios.each( this.replace.bind( this ) );
   },

   replace: function( el ) {
      var oldbox = $( el );
      var newId  = (oldbox.id || oldbox.name + oldbox.value) + '_replacement';

      if ($( newId )) return;

      var newbox = new Element( 'span', {
         class: 'checkbox' + (oldbox.checked ? ' checked' : ''),
         id   : newId,
         name : oldbox.name + '_replacement'
      } );

      this.boxes.push( [ oldbox, newbox ] );

      oldbox.setStyles( { position: 'absolute', left: '-9999px' } );
      newbox.injectBefore( oldbox );
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
   }
} );

CheckboxReplace.implement( new Events );

/* Originally created by: Adam Wulf adam.wulf@gmail.com Version 1.4.0
 * http://welcome.totheinter.net/columnizer-jquery-plugin/
 */

var Columnizer = new Class( {
   options: {
      accuracy : false,
      // true to build columns once regardless of window resize
      // false to rebuild when content box changes bounds
      buildOnce : false,
      // Percentage left + right padding in CSS for column class
      columnPadding : 1.5,
      // optional # of columns instead of width
      columns : false,
      // this function is called after content is columnized
      doneFunc : Class.empty,
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
      while (parentColumn.getSize().size.y < height
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

         while (parentColumn.getSize().size.y < height && oText.length) {
            if (oText.indexOf( ' ', counter2 ) != '-1')
               columnText = oText.substring( 0, oText.indexOf( ' ', counter2));
            else columnText = oText;

            latestTextNode = document.createTextNode( columnText );
            putInHere.appendChild( latestTextNode );

            if (oText.length > counter2)
               oText = oText.substring( oText.indexOf( ' ', counter2 ) );
            else oText = '';
         }

         if (parentColumn.getSize().size.y >= height
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
      var data = this.node.data, size = this.node.getSize().size;

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

               para.remove(); para.injectTop( destroyable );
            }

            i++;
         }

         var columns = this.node.getChildren();

         if (options.overflow && ! horizontal) {
            var overflow = $( options.overflow.id );
            var kids     = destroyable.getChildren();

            overflow.empty(); overflow.adopt( kids.clone() );
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
               var h = col.getSize().size.y; lastIsMax = false; totalH += h;

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

      if (options.overflow) options.overflow.doneFunc();

      return options.doneFunc();
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

            para.remove(); para.injectTop( destroyable );
         }

         var overflow = $( options.overflow.id ); overflow.empty();

         while ($defined( destroyable.firstChild )) {
            var para = $( destroyable.firstChild );

            para.remove(); para.injectInside( overflow );
         }
      }
      else this.cache.injectInside( col );

      this.node.data.set( 'columnizing', false );

      if (options.overflow) options.overflow.doneFunc();

      return options.doneFunc();
   },

   split: function( putInHere, pullOutHere, parentColumn, height ) {
      if (! pullOutHere.childNodes.length) return;

      var cloneMe = pullOutHere.firstChild, clone = cloneMe.clone();

      if (! $type( clone ) == 'element' || clone.hasClass( 'dontend' )) return;

      clone.injectInside( putInHere );

      if (clone.getTag() == 'img'
          && parentColumn.getSize().size.y < height + 20) {
         cloneMe.remove();
      }
      else if (! cloneMe.hasClass( 'dontsplit' )
               && parentColumn.getSize().size.y < height + 20) {
         cloneMe.remove();
      }
      else if (clone.getTag() == 'img' || cloneMe.hasClass( 'dontsplit' )) {
         clone.remove();
      }
      else {
         clone.empty();

         if (! this.columnize( clone,  cloneMe,  parentColumn, height )
             && cloneMe.childNodes.length) {
            this.split( clone, cloneMe, parentColumn, height ); // Recurse
         }

         if (clone.childNodes.length == 0) {
            // it was split, but nothing is in it :(
            clone.remove();
         }
      }

      return;
   }
} );

Columnizer.implement( new Events, new Options );

var Cookies = new Class( {
   options: {
      domain: '',
      expire: 90,
      name  : 'state',
      path  : '/',
      secure: false
   },

   initialize: function( options ) {
      this.setOptions( options );
      this.cname = options.prefix
                 ? options.prefix + '_' + this.options.name
                 : this.options.name;
      this.copts = { duration: this.options.expire,
                     path    : this.options.path,
                     domain  : this.options.domain,
                     secure  : this.options.secure };
   },

   delete: function( name ) {
      var i, j, opts, pair, val = Cookie.get( this.cname );

      if (val && name) name = escape(name);
      else return false;

      if ((i = val.indexOf( name + '~' )) < 0) return false;

      j = val.substring(i).indexOf( '+' );

      if (i == 0) val = (j < 0) ? '' : val.substring( j + 1 );

      if (i > 0) {
         val = (j < 0) ? val.substring( 0, i - 1 )
                       : val.substring( 0, i - 1 ) + val.substring( i + j );
      }

      return Cookie.set( this.cname, val, this.copts );
   },

   get: function( name ) {
      var cookies, i, pair, val = Cookie.get( this.cname );

      if (name && val) {
         cookies = val.split( '+' );

         for (i = 0; i < cookies.length; i++) {
            pair = cookies[i].split( '~' );

            if (unescape( pair[0] ) == name) return unescape( pair[1] );
         }

         return '';
      }

      return val;
   },

   set: function( name, cookie ) {
      var i, j, opts, pair, val = Cookie.get( this.cname );

      if (name) name = escape( name );
      else return;

      if (cookie) cookie = escape( cookie );

      if (val) {
         if ((i = val.indexOf( name + '~' )) >= 0) {
            j = val.substring( i ).indexOf( '+' );

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

      return Cookie.set( this.cname, val, this.copts );
   }
} );

Cookies.implement( new Options );

var FreeList = new Class( {
   initialize: function( options ) {
      this.form = options.form;
   },

   addItem: function( name ) {
      var form     = document.forms[ this.form ];
      var new_elem = form.elements[ name + '_new' ];
      var cur_elem = form.elements[ name + '_current' ];

      cur_elem.options[ cur_elem.length ] = new Option( new_elem.value );
      this.createHidden( form, name, new_elem.value );
      new_elem.value = '';
      return false;
   },

   createHidden: function( form, name, val ) {
      var row_elem = form.elements[ name + '_n_rows' ];
      var nrows    = parseInt( row_elem.value, 10 );

      hidden = document.createElement( 'input' );
      hidden.setAttribute( 'type', 'hidden' );
      hidden.setAttribute( 'id', name + nrows );
      hidden.setAttribute( 'name', name );
      hidden.setAttribute( 'value', val );
      $( 'body' ).appendChild( hidden );
      row_elem.value = nrows + 1;
      return;
   },

   deleteHidden: function( form, name, val ) {
      var row_elem = form.elements[ name + '_n_rows' ];
      var nrows    = parseInt( row_elem.value, 10 );
      var hidden;

      for (var i = 0; i < nrows; i++) {
         if ((hidden = $( name + i )) && (hidden.value == val)) {
            hidden.remove(); row_elem.value = nrows - 1;
            return true;
         }
      }

      return false;
   },

   removeItem: function(name) {
      var form     = document.forms[ this.form ];
      var cur_elem = form.elements[ name + '_current' ];

      for (var i = cur_elem.length - 1; i >= 0; i--) {
         if (cur_elem.options[ i ].selected == true) {
            this.deleteHidden( form, name, cur_elem.options[ i ].value );
            cur_elem.options[ i ] = null;
         }
      }

      return false;
   }
} );

var GroupMember = new Class( {
   initialize: function( options ) {
      this.form = options.form;
   },

   addItem: function( name ) {
      var form     = document.forms[ this.form ];
      var all_elem = form.elements[ name + '_all' ];
      var cur_elem = form.elements[ name + '_current' ];

      for (var i = all_elem.length - 1; i >= 0; i--) {
         if (all_elem.options[ i ].selected == true) {
            var val = all_elem.options[ i ].value;
            cur_elem.options[ cur_elem.length ] = all_elem.options[ i ];

            if(!this.deleteHidden( form, name, 'deleted', val )) {
               this.createHidden( form, name, 'added', val );
            }

            // This suddenly started happening, weird but works after v0.1.657
            //            all_elem.options[ i ] = null;
         }
      }

      return false;
   },

   createHidden: function( form, name, type, val ) {
      var row_elem = form.elements[ name + '_n_' + type ];
      var nrows    = parseInt( row_elem.value, 10 );

      hidden = document.createElement( 'input' );
      hidden.setAttribute( 'type', 'hidden' );
      hidden.setAttribute( 'id', name + '_' + type + nrows );
      hidden.setAttribute( 'name', name + '_' + type );
      hidden.setAttribute( 'value', val );
      $( 'body' ).appendChild( hidden );
      row_elem.value = nrows + 1;
      return;
   },

   deleteHidden: function( form, name, type, val ) {
      var row_elem = form.elements[ name + '_n_' + type ];
      var nrows    = parseInt( row_elem.value, 10 );
      var hidden;

      for (var i = 0; i < nrows; i++) {
         if ((hidden = $( name + '_' + type + i )) && (hidden.value == val)) {
            hidden.remove(); row_elem.value = nrows - 1;
            return true;
         }
      }

      return false;
   },

   removeItem: function( name ) {
      var form     = document.forms[ this.form ];
      var all_elem = form.elements[ name + '_all' ];
      var cur_elem = form.elements[ name + '_current' ];

      for (var i = cur_elem.length - 1; i >= 0; i--) {
         if (cur_elem.options[ i ].selected == true) {
            var val = cur_elem.options[ i ].value;
            all_elem.options[ all_elem.length ] = cur_elem.options[ i ];

            if (!this.deleteHidden( form, name, 'added', val )) {
               this.createHidden( form, name, 'deleted', val );
            }

            // This suddenly started happening, weird but works after v0.1.657
            //            cur_elem.options[ i ] = null;
         }
      }

      return false;
   }
} );

var LinkFader = new Class( {
   options: {
      cn   : 'fade',             // Class name matching links to fade
      inBy : 6,                  // Fade in colour inc/dec by
      outBy: 6,                  // Fade out colour inc/dec by
      speed: 20,                 // Millisecs between colour changes
      fc   : 'ff0000'            // Fade to colour
   },

   initialize: function( options ) {
      var i, ignoreIt, link;

      this.setOptions( options );
      this.links  = options.links || document.links;
      this.view   = options.view  || document.defaultView;
      this.colour = null;        // Store links original colour
      this.linkNo = 0;           // Index of currently fading link
      this.timer  = null;        // Interval object

      for (i = 0; i < this.links.length; i++) {
         link     = this.links[ i ];
         ignoreIt = link.className.indexOf( this.options.cn ) < 0;

         if (!ignoreIt) {
            if (!link.id) link.id = 'link' + i;

            if (!link.onmouseover && !link.onmouseout) {
               link.onmouseover = this.startFade.bind( this, link.id );
               link.onmouseout  = this.clearFade.bind( this, link.id );
            }
         }
      }
   },

   clearFade: function( id ) {
      if (this.timer) { clearInterval( this.timer ); this.timer = null }

      this.timer = setInterval( this.fade.bind( this ), this.options.speed, 0);
   },

   currentColour: function( index ) {
      var cc, i, style, temp = '';

      style = this.view.getComputedStyle( this.links[index], '' );
      cc    = style.getPropertyValue( 'color' );

      if (cc.length == 4 && cc.substring( 0, 1 ) == '#') {
         for (i = 0; i < 3; i++) {
            temp += cc.substring( i + 1, i + 2 ) + cc.substring( i + 1, i + 2);
         }

         cc = temp;
      }
      else if (cc.indexOf('rgb') != -1) { cc = cc.rgbToHex().substring(1, 7) }
      else if (cc.length == 7)          { cc = cc.substring( 1, 7 ) }
      else                              { cc = this.options.fc }

      return cc;
   },

   fade: function( d ) {
      var cc = new Array(), tc = new Array();

      if (d == 1) tc = this.options.fc.hexToRgb( true );
      else tc = this.colour ? this.colour.hexToRgb( true ) : [ 0, 0, 0 ];

      cc = this.currentColour( this.linkNo ).hexToRgb( true );

      if (tc[ 0 ] == cc[ 0 ] && tc[ 1 ] == cc[ 1 ] && tc[ 2 ] == cc[ 2 ]) {
         clearInterval( this.timer ); this.timer = null;
         return;
      }

      this.links[ this.linkNo ].style.color = this.nextColour( tc, cc, d );
   },

   nextColour: function( tc, cc, d ) {
      var change, colour, diff, i, nc;

      for (i = 0; i < 3; i++) {
         if (d == 1) { change = this.options.inBy }
         else { change = this.options.outBy }

         if (!colour) colour = 'rgb(';
         else colour += ',';

         nc = cc[ i ];

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

   startFade: function( id ) {
      if (this.timer) {
         clearInterval( this.timer ); this.timer = null;

         if (this.colour) {
            this.links[ this.linkNo ].style.color = this.colour.hexToRgb();
         }
      }

      for (var i = 0; i < this.links.length; i++) {
         if (id == this.links[ i ].id) {
            this.linkNo = i;
            this.colour = this.currentColour( i );
            this.timer  = setInterval( this.fade.bind( this ),
                                       this.options.speed, 1);
            return;
         }
      }
   }
} );

LinkFader.implement( new Options );

var LiveGridMetaData = new Class( {
   initialize: function( options ) {
      this.bufferSize   = options.bufferSize   || 7;
      this.onscroll     = options.onscroll     || null;
      this.onscrollidle = options.onscrollidle || null;
      this.pageSize     = options.pageSize     || 10;
      this.totalRows    = options.totalRows    || 0;
   },

   getBufferSize: function()    { return this.bufferSize },

   getPageSize:   function()    { return this.pageSize },

   getTotalRows:  function()    { return this.totalRows },

   setTotalRows:  function( n ) { this.totalRows = n }
} );

var LiveGridScroller = new Class( {
   initialize: function( liveGrid ) {
      this.isIE = window.ie;
      this.liveGrid = liveGrid;
      this.metaData = liveGrid.metaData;
      this.scrollTimeout = null;
      this.lastScrollPos = 0;
      this.createScrollBar();
   },

   isUnPlugged: function() { return this.scrollerDiv.onscroll == null },

   plugin: function() {
      this.scrollerDiv.onscroll = this.handleScroll.bindAsEventListener(this);
   },

   unplug: function() { this.scrollerDiv.onscroll = null },

   createScrollBar: function() {
      var table              = this.liveGrid.table;
      var visibleHeight      = table.offsetHeight;
      this.lineHeight        = visibleHeight / this.metaData.getPageSize();
      this.scrollerDiv       = document.createElement( 'div' );
      var scrollerStyle      = this.scrollerDiv.style;
      scrollerStyle.position = 'relative';
      scrollerStyle.left     = this.isIE ? '-6px' : '-4px';
      scrollerStyle.width    = '19px';
      scrollerStyle.height   = visibleHeight + 'px';
      scrollerStyle.overflow = 'auto';

      if (this.isIE) {
         table.onmousewheel =
            function( evt ) {
               if (event.wheelDelta>=0) {//wheel-up
                  this.scrollerDiv.scrollTop -= this.lineHeight;
               }
               else { this.scrollerDiv.scrollTop += this.lineHeight }

               this.handleScroll( true );
            }.bind( this );
      } else {
        table.addEventListener( 'DOMMouseScroll',
            function( evt ) {
                if (evt.detail < 0) { //wheel-up
                   this.scrollerDiv.scrollTop -= this.lineHeight;
                }
                else { this.scrollerDiv.scrollTop += this.lineHeight }

                this.handleScroll( true );
            }.bind( this ), true );
      }

      // create the inner div...
      this.heightDiv = document.createElement( 'div' );
      this.heightDiv.style.width  = '1px';
      this.heightDiv.style.height = parseInt(visibleHeight *
            this.metaData.getTotalRows()/this.metaData.getPageSize()) + 'px' ;

      this.scrollerDiv.appendChild(this.heightDiv);
      this.scrollerDiv.onscroll = this.handleScroll.bindAsEventListener(this);
      table.parentNode.parentNode.insertBefore( this.scrollerDiv,
                                                table.parentNode.nextSibling );
   },

   updateSize: function() {
      var table = this.liveGrid.table;
      var visibleHeight = table.offsetHeight;
      this.heightDiv.style.height = parseInt(visibleHeight *
            this.metaData.getTotalRows()/this.metaData.getPageSize()) + 'px';
   },

   adjustScrollTop: function() {
      this.unplug();
      var rem = this.scrollerDiv.scrollTop % this.lineHeight;

      if (rem != 0) {
         if (this.lastScrollPos < this.scrollerDiv.scrollTop) {
            this.scrollerDiv.scrollTop = this.scrollerDiv.scrollTop
               + this.lineHeight - rem;
         }
         else {
            this.scrollerDiv.scrollTop = this.scrollerDiv.scrollTop - rem;
         }
      }

      this.lastScrollPos = this.scrollerDiv.scrollTop;
      this.plugin();
   },

   moveScroll: function( rowOffset ) {
      var pixelOffset = (rowOffset / this.metaData.getTotalRows())
                           * this.heightDiv.offsetHeight;
      this.scrollerDiv.scrollTop = pixelOffset;
   },

   handleScroll: function( skiptimeout ) {
      if ( this.scrollTimeout ) clearTimeout( this.scrollTimeout );

      var contentOffset = parseInt( this.scrollerDiv.scrollTop *
                 this.metaData.getTotalRows() / this.heightDiv.offsetHeight );

      if ( this.metaData.onscroll )
         this.metaData.onscroll( contentOffset, this.metaData );

      if (skiptimeout == true) { this.scrollIdle() }
      else {
        this.scrollTimeout = setTimeout( this.scrollIdle.bind( this ), 100 );
      }
   },

   scrollIdle: function() {
      if ( this.scrollTimeout ) clearTimeout( this.scrollTimeout );

      // this.adjustScrollTop();
      var contentOffset = parseInt( this.scrollerDiv.scrollTop *
                 this.metaData.getTotalRows() / this.heightDiv.offsetHeight );
      this.liveGrid.requestContentRefresh( contentOffset );

      if ( this.metaData.onscrollidle ) this.metaData.onscrollidle();
   }
} );

var LiveGridBuffer = new Class( {
   initialize: function( metaData ) {
      this.start    = 0;
      this.size     = 0;
      this.metaData = metaData;
      this.rows     = new Array();
   },

   update: function(text, xml) {
      this.start = parseInt( xml.documentElement.getAttribute( 'offset' ) );
      this.size  = parseInt( xml.documentElement.getAttribute( 'count' ) );
      var rows   = xml.documentElement.getElementsByTagName( 'items' );

      for (var i = 0; i < this.size; i++) {
         this.rows[this.start + i]
            = rows[ i ].childNodes[ 0 ].nodeValue.unescapeHTML();
      }
   },

   isClose: function( start ) {
      return this.rows[start]
             || this.rows[start + this.metaData.getPageSize()];
   },

   isFullyInRange: function( start ) {
      return this.rows[start]
             && this.rows[start + this.metaData.getPageSize()];
   },

   needsPrevPage: function( start ) {
      return !this.rows[start - this.metaData.getPageSize()];
   },

   needsNextPage: function( start ) {
      return !this.rows[start + 2 * this.metaData.getPageSize()];
   },

   needsMorePages: function( start ) {
      return this.needsPrevPage( start ) || this.needsNextPage( start );
   },

   getRows: function( start ) {
      return this.rows.slice( start, start + this.metaData.getPageSize() );
   }
} );

var LiveGridRequest = new Class( {
   initialize: function( requestOffset, options ) {
      this.requestOffset = requestOffset;
   }
} );

var LiveGrid = new Class( {
   initialize: function( tableId, url, options ) {
      if ( options == null ) options = {};

      this.url      = url;
      this.options  = options;
      this.tableId  = tableId;
      this.table    = $( tableId );
      this.metaData = new LiveGridMetaData( options );
      this.buffer   = new LiveGridBuffer( this.metaData );

      this.lastDisplayedStartPos = -1;
      this.timeoutHander         = null;
      this.additionalParms       = options.requestParameters || '';
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

   setRequestParams: function( params ) {
      this.additionalParms = params;
   },

   setTotalRows: function( newTotalRows ) {
      this.metaData.setTotalRows( newTotalRows );
      this.scroller.updateSize();
   },

   handleTimedOut: function() {
      //server did not respond in n secs assume that there could have been
      //an error or something, and allow requests to be processed again...
      this.processingRequest = null;
      this.processQueuedRequest();
   },

   fetchBuffer: function( offset, sequence_buffers ) {
      var page, page_size;

      if (this.processingRequest) {
         this.unprocessedRequest = new LiveGridRequest( offset );
         return;
      }

      this.processingRequest = new LiveGridRequest( offset );

      page_size = this.metaData.getBufferSize() * this.metaData.getPageSize();
      page      = Math.floor( offset / page_size );

      if (sequence_buffers) {
         page  += offset - page * page_size > page_size / 2 ? 1 : -1;
      }

      if (page < 0) page = 0;

      var callParms = 'content-type=text/xml&id=' + this.tableId
                    + '&page=' + page + '&page_size=' + page_size;

      if (this.additionalParms.length) {
         callParms = callParms + '&' + this.additionalParms;
      }

      if (!this.ajaxRequest) {
         var options = { data: callParms, method: 'get' };
         Object.extend( options, this.options );
         options.onComplete = this.ajaxUpdate.bind( this );
         this.ajaxRequest = new Ajax( this.url, options )
         this.ajaxRequest.request();
      }
      else {
         Object.extend( this.ajaxRequest.options, { data: callParms } );
         this.ajaxRequest.request();
      }

      this.timeoutHandler = setTimeout(this.handleTimedOut.bind(this), 10000);
   },

   requestContentRefresh: function( offset ) {
      if ( this.buffer.isFullyInRange( offset ) ) {
         this.updateContent( offset );

         if (this.buffer.needsMorePages( offset )) {
            this.fetchBuffer( offset, true );
         }
      }
      else if (this.buffer.isClose( offset )) {
         this.fetchBuffer( offset, true );
      }
      else { this.fetchBuffer( offset, false ) }
   },

   ajaxUpdate: function( text, xml ) {
      clearTimeout( this.timeoutHandler );

      try {
         var totalrows =  xml.documentElement.getAttribute( 'totalcount' );
         if (totalrows) this.setTotalRows( totalrows );
      }
      catch (err) {}

      this.buffer.update( text, xml );

      if (this.unprocessedRequest == null) {
         this.updateContent( this.processingRequest.requestOffset );
      }

      this.processingRequest = null;

      if (!this.scroller) {
         this.scroller = new LiveGridScroller( this );

         if (this.options.onFirstContent) this.options.onFirstContent( this );
      }

      if (this.options.onComplete) this.options.onComplete( this );

      this.processQueuedRequest();
   },

   processQueuedRequest: function() {
      if (this.unprocessedRequest != null) {
         this.requestContentRefresh( this.unprocessedRequest.requestOffset );
         this.unprocessedRequest = null
      }
   },

   updateContent: function( offset ) {
      this.replaceCellContents( this.buffer, offset );
   },

   replaceCellContents: function( buffer, start ) {
      if (start == this.lastDisplayedStartPos) return;

      this.table.setHTML( buffer.getRows( start ).join( '' ) );
      this.lastDisplayedStartPos = start
   }
} );

var LoadMore = new Class( {
   initialize: function( options ) {
      this.url = options.url;
   },

   request: function( action, id, val, onComplete ) {
      if (onComplete) this.onComplete = onComplete;

      new Ajax( this.url + action,
         { method    : 'get',
           data      : 'content-type=text/xml&id=' + id + '&val=' + val,
           onComplete: this.updateContent.bind( this ) } ).request();
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

      $( id ).setHTML( html.unescapeHTML() );

      if (this.onComplete) this.onComplete.call();
   }
} );

var ServerUtils = new Class( {
   initialize: function( options ) {
      this.url = options.url;
   },

   checkField: function( id, val ) {
      new Ajax( this.url + 'check_field',
         { method    : 'get',
           data      : 'content-type=text/xml&id=' + id + '&val=' + val,
           onComplete: this.updateContent } ).request();
   },

   postData: function( url, data ) {
      new Ajax( url, { method: 'post', data: data } ).request();
   },

   updateContent: function( text, xml ) {
      var id        = xml.documentElement.getAttribute( 'id' );
      var result    = xml.documentElement.getAttribute( 'result' );
      var className = xml.documentElement.getAttribute( 'class_name' );
      var elem      = $( id );

      elem.setHTML( result );

      if (result) elem.className = className;
      else elem.className = 'hidden';
   }
});

ServerUtils.implement( new Options );

var SubmitUtils = new Class({
   initialize: function( options ) {
      this.form    = options.form;
      this.cookies = new Cookies( { path:   options.path,
                                    prefix: options.prefix } );
   },

   chooser: function( name, button, url, winPrefs ) {
      var form  = document.forms[ this.form ];
      var value = form.elements[ name ].value;

      if (value && value.indexOf( '%' ) < 0) {
         if (button) {
            form.elements[ '_method' ].value = button; form.submit();
         }

         return false;
      }

      top.chooser = window.open( url + '?form=' + this.form + '&value=' +value,
                                 'chooser', winPrefs );
      top.chooser.opener = top;
      return false;
   },

   clearField: function( name ) {
      var form = document.forms[ this.form ];
      form.elements[ name ].value = '';
      return false;
   },

   confirmSubmit: function( key, text ) {
      if (text.length < 1 || window.confirm( text )) {
         this.submitForm( key );
         return true;
      }

      return false;
   },

   refresh: function( name, value ) {
      this.cookies.set( name, value ); document.forms[ this.form ].submit();
   },

   returnValue: function( form, name, value ) {
      var field = opener.document.forms[ form ].elements[ name ];

      if (field) {
         field.value = value;

         if (field.focus) field.focus();
      }

      window.close();
      return false;
   },

   setField: function( name, value ) {
      var form = document.forms[ this.form ];
      form.elements[ name ].value = value;
   },

   submitForm: function( key ) {
      var form = document.forms[ this.form ];
      form.elements[ '_method' ].value = key;
      form.submit();
   },

   submitOnReturn: function( evt, key ) {
      var code = evt.which;

      if (code == 13) {
         if (document.forms) this.submitForm( key );
         else window.alert( 'Document contains no forms' );
      }

      return false;
   }
} );

var TableUtils = new Class( {
   initialize: function( options ) {
      this.form      = options.form;
      this.sortables = new Hash();
      this.url       = options.url;
   },

   addTableRow: function( name, edit ) {
      var aelem, cell, cNo = 0, elem, fld, nelem, nrows, row;
      var form = document.forms[ this.form ];

      if (nelem = form.elements[ name + '_nrows' ]) {
         nrows = nelem.value ? parseInt( nelem.value, 10 ) : 0;

         if (elem = $( name + '_add' )) {
            row = document.createElement( 'tr' );
            row.setAttribute( 'class', 'dataValue' );
            row.setAttribute( 'id', name + '_row' + nrows );

            while (aelem = $( name + '_add' + cNo )) {
               cell = document.createElement( 'td' );

               if (edit) {
                  fld = document.createElement( 'input' );
                  fld.setAttribute( 'value', aelem.value );
                  fld.setAttribute( 'type', 'input' );
                  fld.setAttribute( 'class', 'ifield' );
                  fld.setAttribute( 'name', aelem.name + nrows );
                  if (aelem.size) { fld.setAttribute( 'size', aelem.size ) }
                  if (aelem.maxlength) {
                     fld.setAttribute( 'maxlength', aelem.maxlength );
                  }
                  cell.setAttribute( 'class', 'dataField' );
               }
               else {
                  fld = document.createTextNode( aelem.value );
                  cell.setAttribute( 'class', 'dataValue' );
               }

               cell.appendChild( fld );
               row.appendChild( cell );
               aelem.value = ''; cNo++;
            }

            if (edit) {
               fld = document.createElement( 'input' );
               fld.setAttribute( 'name', name + '_select' + nrows );
               fld.setAttribute( 'type', 'checkbox' );
               cell = document.createElement( 'td' );
               cell.setAttribute( 'align', 'center' );
               cell.setAttribute( 'class', (cNo%2 == 0 ? 'even' : 'odd') );
               cell.appendChild( fld );
               row.appendChild( cell );
            }

            elem.parentNode.insertBefore( row, elem );
            nelem.value = nrows + 1;
         }
      }

      return false;
   },

   createGrid: function( text, xml ) {
      var keyid  = this.gridKey + this.gridId;
      var count  = parseInt( xml.documentElement.getAttribute( 'totalcount' ));
      var html   = '';
      var opts   = {
         bufferSize    : 7,
         pageSize      : 10,
         prefetchBuffer: true,
         onscroll      : this.updateHeader.bind( this ),
         onFirstContent: this.updateHeader.bind( this, 0 ),
         totalRows     : count
      };
      var rows   = xml.documentElement.getElementsByTagName( 'items' );
      var urlkey = this.url + this.gridKey + '_grid_rows';

      $each( rows, function( row ) { html += row.childNodes[ 0 ].nodeValue } );
      $( keyid + 'Disp' ).setHTML( html.unescapeHTML() );
      this.gridObj = new LiveGrid( keyid + '_grid', urlkey, opts );
   },

   sortRows: function( table_name, column_name, column_type ) {
      var table   = $( table_name );
      var columns = table.getElements( 'th' );
      var ids     = columns.map( function( column ) { return column.id } );
      var name    = table_name + '_' + column_name;

      if (! ids.contains( name )) return;

      var index   = ids.indexOf( name );
      var order   = this._get_sort_order( table_name, ids[ 0 ], name );

      table.getElements( 'tr[id*=_row]' ).map( function( row ) {
         var field = this._get_sort_field( row.cells[ index ], column_type );

         return new Array( field, row.clone() );
      }.bind( this ) ).sort( function( a, b ) {
         return a[ 0 ] < b[ 0 ] ? order[ 0 ]
             : (a[ 0 ] > b[ 0 ] ? order[ 1 ] : 0);
      } ).map( function( item, index ) {
         var id = table_name + '_row' + index, row = item[ 1 ];

         row.id = id; $( id ).replaceWith( row );
      } );

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

   _get_sort_order: function( table_name, default_column, name ) {
      var sortable = this.sortables.get( table_name )
                  || { sort_column: default_column, reverse: 0 };
      var reverse  = sortable.reverse;

      if (name == sortable.sort_column) reverse = 1 - reverse;
      else reverse = 0;

      sortable.reverse = reverse; sortable.sort_column = name;
      this.sortables.set( table_name, sortable );
      return reverse ? [ 1, -1 ] : [ -1, 1 ];
   },

   removeTableRow: function( name ) {
      var count, elem, hidden, i, nelem, nrows;
      var form = document.forms[ this.form ];

      if (nelem = form.elements[ name + '_nrows' ]) {
         nrows = parseInt( nelem.value, 10 ); count = 0;

         for (i = 0; i < nrows; i++) {
            if (elem = form.elements[ name + '_select' + i ]) {
               if (elem.checked) {
                  if (elem = $( name + '_row' + i )) {
                     elem.parentNode.removeChild( elem );
                     count++;
                  }
               }
            }
         }

         nelem.value = nrows - count;
      }

      return false;
   },

   liveGrid: function( key, id, klasses, pageSz, toggle ) {
      if (key && id && klasses) {
         var elem = $( key + id + 'Disp' );

         if (elem) {
            var klass = klasses.split( '~' );

            if (toggle && elem.style.display != 'none') {
               elem.style.display = 'none';
               elem = $( key + id + 'Icon' );

               if (elem) elem.className = klass[0];

               this.gridKey  = null;
               this.gridId   = null;
               this.gridObj = null;
               this.pageSz   = 10;
            }
            else {
               if (this.gridKey && this.gridId) {
                  var keyid = this.gridKey + this.gridId;
                  var prev  = $( keyid + 'Disp' );

                  if (prev) prev.style.display = 'none';

                  prev = $( keyid + 'Icon' );

                  if (prev) prev.className = klass[0];

                  this.gridKey  = null;
                  this.gridId   = null;
                  this.gridObj = null;
                  this.pageSz   = 10;
               }

               elem.style.display = '';
               elem = $( key + id + 'Icon' );

               if (elem) elem.className = klass[1];

               this.gridKey = key;
               this.gridId  = id;
               this.pageSz  = (pageSz ? pageSz : 10);
               new Ajax( this.url + key +  '_grid_table',
                  { method    : 'get',
                    data      : 'content-type=text/xml&id='
                                + id + '&val=' + pageSz,
                    onComplete: this.createGrid.bind( this ) } ).request();
            }
         }
      }
   },

   updateHeader: function( offset ) {
      var id, sortInfo, text, urlkey, metaData = this.gridObj.metaData;

      id    = this.gridKey + this.gridId + '_header';
      text  = 'Listing ' + (offset + 1) + ' - ';
      text += (offset + metaData.getPageSize());
      text += ' of ' + metaData.getTotalRows();
      $( id ).setHTML( text );

      if (this.gridObj.sortCol) {
         sortInfo  = '&data_grid_sort_col=' + this.gridObj.sortCol;
         sortInfo += '&data_grid_sort_dir=' + this.gridObj.sortDir;
      }
      else sortInfo = '';

      urlkey = this.url + this.gridKey + '_gridPage';
      text   = urlkey + '?data_grid_index=' + offset + sortInfo;
      $( id ).href = text;
   }
} );

TableUtils.implement( new Options );

/* Script: Tips.js
      Tooltips, BubbleTips, whatever they are, they will appear on mouseover

   License:
      MIT-style license.

   Credits:
      The idea behind Tips.js is based on Bubble Tooltips
      (<http://web-graphics.com/mtarchive/001717.php>) by Alessandro
      Fulcitiniti <http://web-graphics.com>
   Class: Tips
      Display a tip on any element with a title and/or href.

   Note:
      Tips requires an XHTML doctype.

   Arguments:
      elements - collection of elements to apply the tooltips to on mouseover.
      options - an object. See options Below.

   Options:
      maxTitleChars - the maximum number of characters to display in the
                      title of the tip. defaults to 30.
      showDelay - the delay the onShow method is called. (defaults to 100 ms)
      hideDelay - the delay the onHide method is called. (defaults to 100 ms)
      className - the prefix for your tooltip classNames. defaults to 'tool'.
         the whole tooltip will have as classname: tool-tip
         the title will have as classname: tool-title
         the text will have as classname: tool-text
      offsets - the distance of your tooltip from the mouse. an Object
                with x/y properties.
      fixed - if set to true, the toolTip will not follow the mouse.

   Events:
      onShow - optionally you can alter the default onShow behaviour with
               this option (like displaying a fade in effect);
      onHide - optionally you can alter the default onHide behaviour with
               this option (like displaying a fade out effect);

   Example:
      (start code)
      <img src="/images/i.png" title="The body of the tooltip is stored
                                      in the title" class="toolTipImg"/>
      <script>
         var myTips = new Tips($$('.toolTipImg'), {
            maxTitleChars: 50 //I like my captions a little long
         });
      </script>
      (end)

   Note:
      The title of the element will always be used as the tooltip
      body. If you put ~ in your title, the text before the ~ will become
      the tooltip title.
*/

var Tips = new Class( {
   options: {
      className: 'tool',
      fixed    : false,
      hellip   : '\u2026',
      hideDelay: 100,
      maxTitleChars: 40,
      offsets  : { 'x': 20, 'y': 20 },
      onHide   : function( tip ) { tip.setStyle( 'visibility', 'hidden'  ) },
      onShow   : function( tip ) { tip.setStyle( 'visibility', 'visible' ) },
      separator: '~',
      showDelay: 100,
      spacer   : '\u00a0\u00a0\u00a0',
      timeout  : 30000
   },

   initialize: function( options ) {
      var cell, row, table;

      this.setOptions( options );
      this.toolTip = new Element( 'div', {
         'class' : this.options.className + '-tip',
         'styles': { 'position'  : 'absolute',
                     'top'       : '0',
                     'left'      : '0',
                     'visibility': 'hidden' } } ).inject( document.body );
      table = new Element( 'table',
         { 'cellpadding': '0', 'cellspacing': '0' } ).inject( this.toolTip );
      row   = new Element( 'tr' ).inject( table );
      this.titleCell = new Element( 'td',
         { 'class': this.options.className + '-tip-topLeft'} ).inject( row );
      this.title = new Element( 'span' ).inject( this.titleCell );

      cell  = new Element( 'td',
         { 'class': this.options.className + '-tip-topRight'} ).inject( row );
      new Element( 'span' ).appendText( this.options.spacer ).inject( cell );

      row   = new Element( 'tr' ).inject( table );
      this.textCell  = new Element( 'td', { 'class': this.options.className
                                   + '-tip-bottomLeft'} ).inject( row );
      this.text = new Element( 'span' ).inject( this.textCell );

      cell  = new Element( 'td', { 'class': this.options.className
                                   + '-tip-bottomRight' } ).inject( row );
      new Element( 'span' ).appendText( this.options.spacer ).inject( cell );

      if (options.elements) $$( options.elements ).each( this.build, this );

      if (this.options.initialize) this.options.initialize.call( this );
   },

   build: function( el, index ) {
      if (el.$tmp.myTitle || el.$tmp.myText) return;

      el.$tmp.myTitle = (el.href && el.getTag() == 'a')
                      ? el.href.replace( 'http://', '' )
                      : (el.rel || false);

      if (el.title){
         var dual = el.title.split( this.options.separator );

         if (dual.length > 1){
            el.$tmp.myTitle = dual[ 0 ].trim();
            el.$tmp.myText  = dual[ 1 ].trim();
         }
         else {
            if (!el.$tmp.myTitle) el.$tmp.myTitle = this.options.hellip;

            el.$tmp.myText = el.title;
         }

         el.removeAttribute( 'title' );
      }
      else { el.$tmp.myText = false }

      if (el.$tmp.myTitle && el.$tmp.myTitle.length >
          this.options.maxTitleChars) {
         el.$tmp.myTitle
            = el.$tmp.myTitle.substr( 0, this.options.maxTitleChars - 1 )
            + this.options.hellip;
      }

      el.addEvent( 'mouseenter', function( event ) {
         this.start( el );

         if (!this.options.fixed) this.locate( event );
         else this.position( el );
      }.bind( this ) );

      if (!this.options.fixed)
         el.addEvent( 'mousemove', this.locate.bindWithEvent( this ) );

      el.addEvent( 'mouseleave', this.end.bind( this ) );
      el.addEvent( 'trash', this.hide.bind( this ) );
   },

   end: function( event ) {
      $clear( this.timer );
      this.timer = this.hide.delay( this.options.hideDelay, this );
   },

   hide: function() {
      this.fireEvent( 'onHide', [ this.toolTip ] ); this.timer = false;
   },

   locate: function( event ) {
      var win = { 'x': window.getWidth(), 'y': window.getHeight() };
      var scroll
         = { 'x': window.getScrollLeft(), 'y': window.getScrollTop() };
      var tip
         = { 'x': this.toolTip.offsetWidth, 'y': this.toolTip.offsetHeight };
      var prop = { 'x': 'left', 'y': 'top' };

      for (var z in prop) {
         var pos = event.page[z] + this.options.offsets[z];
         if ((pos + tip[z] - scroll[z]) > win[z])
            pos = event.page[z] - this.options.offsets[z] - tip[z];
         this.toolTip.setStyle( prop[z], pos );
      };
   },

   position: function( element ) {
      var pos = element.getPosition();

      this.toolTip.setStyles( {
         'left': pos.x + this.options.offsets.x,
         'top' : pos.y + this.options.offsets.y
      } );
   },

   show: function() {
      if (this.timer) { $clear( this.timer ); this.hide }

      if (this.options.timeout)
         this.timer = this.hide.delay( this.options.timeout, this );

      this.fireEvent( 'onShow', [ this.toolTip ] );
   },

   start: function(el) {
      var len, width, w = 100;

      if (el.$tmp.myText) {
         width = window.getWidth();
         len   = el.$tmp.myTitle.length > el.$tmp.myText.length
               ? el.$tmp.myTitle.length : el.$tmp.myText.length;
         w     = 10 * len;

         if (w < 100)       w = 100;
         if (w > width / 4) w = width / 4;
      }

      this.titleCell.setStyle( 'width', parseInt( w ) + 'px' );

      if ($defined( this.title.lastChild ))
         this.title.removeChild( this.title.lastChild );

      this.title.appendText( el.$tmp.myTitle || this.options.spacer );
      this.textCell.setStyle( 'width', parseInt( w ) + 'px' );

      if ($defined( this.text.lastChild ))
         this.text.removeChild( this.text.lastChild );

      this.text.appendText( el.$tmp.myText || this.options.spacer );
      $clear( this.timer );
      this.timer = this.show.delay( this.options.showDelay, this );
   }
} );

Tips.implement( new Events, new Options );

var Trees = new Class( {
      options: {
         classPrefix   : 'tree',
         cookiePrefix  : 'tree',
         usePersistance: true
      },

      initialize: function( options ) {
         this.setOptions( options );
         this.collection = new Array();

         if (this.options.usePersistance) {
            var prefix = behaviour.sessionPrefix + '_'
                       + this.options.cookiePrefix;
            this.cookies = new Cookies( { path  : behaviour.sessionPath,
                                          prefix: prefix } );
         }

         if (options.elements) $$( options.elements ).each( this.build, this );
      },

      addToggle: function( dt, dd ) {
         var klass = this.options.classPrefix + '_node_ctrl';

         $$( '#' + dt.id + ' span.' + klass ).each( function( el ) {
               el.onclick = function() {
                  return this.toggle( dt, dd );
               }.bind( this );
            }, this );

         return;
      },

      build: function( el, index ) {
         if (! el || ! el.childNodes || el.childNodes.length == 0) return;

         var dt, node;

         for (var i = 0, il = el.childNodes.length; i < il; i++) {
            if (! (node = $( el.childNodes[ i ] ))) continue;

            if (node.nodeName == 'DT') { dt = node; continue; }

            if (node.nodeName != 'DD') continue; var dd = node;

            for (var j = 0, jl = dd.childNodes.length; j < jl; j++) {
               if ((node = $( dd.childNodes[ j ] )) && node.nodeName == 'DL')
                  this.build( node, index );
            }

            this.recoverState( el, dt, dd );
            this.addToggle( dt, dd );
         }

         return;
      },

      close: function( dt, dd ) {
         var prefix = this.options.classPrefix;

         if (dt.hasClass( prefix + '_node_open' )) {
            dt.removeClass( prefix + '_node_open'   );
            dt.addClass   ( prefix + '_node_closed' );
            dd.removeClass( prefix + '_node_open'   );
            dd.addClass   ( prefix + '_node_closed' );
         }
         else if (dt.hasClass( prefix + '_node_last_open' )) {
            dt.removeClass( prefix + '_node_last_open'   );
            dt.addClass   ( prefix + '_node_last_closed' );
            dd.removeClass( prefix + '_node_last_open'   );
            dd.addClass   ( prefix + '_node_last_closed' );
         }

         if (this.options.usePersistance) this.cookies.set( dt.id, '0' );

         return;
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
            dt.removeClass( prefix + '_node_closed' );
            dt.addClass   ( prefix + '_node_open'   );
            dd.removeClass( prefix + '_node_closed' );
            dd.addClass   ( prefix + '_node_open'   );
         }
         else if (dt.hasClass( prefix + '_node_last_closed' )) {
            dt.removeClass( prefix + '_node_last_closed' );
            dt.addClass   ( prefix + '_node_last_open'   );
            dd.removeClass( prefix + '_node_last_closed' );
            dd.addClass   ( prefix + '_node_last_open'   );
         }

         if (this.options.usePersistance) this.cookies.set( dt.id, '1' );

         return;
      },

      recoverState: function( tree, dt, dd ) {
         if (this.options.usePersistance) {
            this.cookies.get( dt.id ) == '1'
               ? this.open( dt, dd ) : this.close( dt, dd );
         }
         else if (! this.collection[ tree.id ]) this.open( dt, dd );
         else this.close( dt, dd );

         this.collection[ tree.id ] = true;
         return;
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

Trees.implement( new Options );

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

   openWindow: function( href, key, prefs ) {
      window.open( href, key, prefs );
      return;
   },

   placeOnTop: function() {
      if (self != top) {
         if (document.images) top.location.replace( window.location.href );
         else top.location.href = window.location.href;
      }
   },

   wayOut: function( href ) {
      Cookie.remove( this.cname, this.copts );

      if (document.images) top.location.replace( href );
      else top.location.href = href;
   }
});

/*
Author     : luistar15, <leo020588 [at] gmail.com>
License    : MIT License
Class      : wysiwyg (rev.06-07-08)
Parameters :
	textarea: textarea dom element | default: first textarea
	klass   : string | css class | default: 'wysiwyg'
	src     : string | iframe src | default: 'about:blank'
	buttons : array | list editor buttons | default: ['strong','em','u','superscript','subscript',null,'left','center','right','indent','outdent',null,'h1','h2','h3','p','ul','ol',null,'img','link','unlink',null,'clean','toggle']
		null -> spacer
Methods    :
	toggleView( editor ): toggle view iframe <-> textarea and update content
	toTextarea( editor, view ): update content from iframe to textarea
		view : bolean | if is true, change view | default:false
	toEditor(editor, view ): update content from textarea to iframe
		view : bolean | if is true, change view | default:false
	exec( editor, cmd, value ): execute command on iframe document
	clean( html ): return valid xhtml string
*/

var WYSIWYG = new Class( {
   options: {
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
      defaultBarNum : 4,
      iframeMargin  : 40,
      iframePadding : 6,
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
           'indent', 'lists', 'links', 'elements', 'media',
           null, 'tables' ]
      ]
   },

   initialize: function( options ) {
      this.setOptions( options );
      this.collection = new Array();
      this.barNum     = options.barNum || this.options.defaultBarNum;

      if (options.elements) $$( options.elements ).each( this.build, this );
   },

   addButton: function( editor, b ) {
      var but = this.options.buttons[ b ];

      if (! but) return false;

      var x   = 0 - 30 * (but[ 0 ] % 10);
      var y   = 0 - 30 * Math.floor( but[ 0 ] / 10 );

      if (window.ie) {
         var elem = new Element( 'a', {
            class: b, href: '//' + b, title: but[ 1 ] } );

         if (b != 'toggle')
            elem.setStyle( 'background-position', x + 'px ' + y + 'px' );

         elem.addEvent( 'click', function( e ) {
            var ev = new Event(e); ev.stop();

            if (b == 'toggle') this.toggleView( editor );
            else this.exec( editor, b );
         }.bind( this ) ).inject( editor.toolbar );
      }
      else {
         var elem = new Element( 'span', { class: b, title: but[ 1 ] } );
         var func = b == 'toggle'
                  ? this.toggleView.bind( this, editor )
                  : this.exec.bind( this, [ editor, b ] );

         if (b != 'toggle')
            elem.setStyle( 'background-position', x + 'px ' + y + 'px' );

        elem.addEvent( 'click', func ).inject( editor.toolbar );
      }

      return true;
   },

   build: function( el, index ) {
      var editor = {}, options = this.options;

      editor.element = el;
      editor.height  = -1;
      editor.barNum  = this.barNum;
      editor.open    = ! options.defaultState;
      editor.toolbar = new Element( 'span' , { class: 'toolbar' } );
      editor.iframe  = new Element( 'iframe', {
         frameborder: 0, src: 'about:blank'
      } ).addEvent( 'load', function() {
         editor.doc = editor.iframe.contentWindow.document;
         this.initialiseBody( editor );
         editor.doc.designMode = 'on';
         this.toggleView( editor );
      }.bind( this ) );

      new Element( 'span', {
         class: options.defaultClass
      } ).injectBefore( el ).adopt( editor.toolbar, editor.iframe, el );

      this.initialiseToolbar( editor );

      window.addEvent( 'unload', function() {
         if (editor.open) this.toTextarea( editor );
      }.bind( this ) );

      this.collection[ index ] = editor;
   },

   clean: function( html ) {
      return html.unescapeHTML()
         .replace(/\s{2,}/g,' ')
         .replace(/^\s+|\s+$/g,'')
         .replace(/<[^> ]*/g,function(s){return s.toLowerCase()})
         .replace(/<[^>]*>/g,function(s){s=s.replace(/ [^=]+=/g,function(a){return a.toLowerCase()});return s})
         .replace(/<[^>]*>/g,function(s){s=s.replace(/( [^=]+=)([^\"][^ >]*)/g,"$1\"$2\"");return s})
         .replace(/<[^>]*>/g,function(s){s=s.replace(/ ([^=]+)="[^\"]*"/g,function(a,b){if(b=='alt'||b=='href'||b=='id'||b=='name'||b=='src'||b=='style'||b=='title'){return a}return''});return s})
         .replace(/<b(\s+|>)/g,"<strong$1")
         .replace(/<\/b(\s+|>)/g,"</strong$1")
         .replace(/<i(\s+|>)/g,"<em$1")
         .replace(/<\/i(\s+|>)/g,"</em$1")
         .replace(/<span style="font-weight: normal;">(.+?)<\/span>/gm,'$1')
         .replace(/<span style="font-weight: bold;">(.+?)<\/span>/gm,'<strong>$1</strong>')
         .replace(/<span style="font-style: italic;">(.+?)<\/span>/gm,'<em>$1</em>')
         .replace(/<span style="(font-weight: bold; ?|font-style: italic; ?){2}">(.+?)<\/span>/gm,'<strong><em>$2</em></strong>')
         .replace(/<img src="([^\">]*)">/g,'<img alt="Image" src="$1" />')
         .replace(/(<img [^>]+[^\/])>/g,"$1 />")
         .replace(/<u>(.+?)<\/u>/gm,'<span style="text-decoration: underline;">$1</span>')
         .replace(/<font[^>]*?>(.+?)<\/font>/gm,'$1')
         .replace(/<font>|<\/font>/gm,'')
         .replace(/<br(\s+\/)?>\s*<\/(h1|h2|h3|h4|h5|h6|li|p)/g,'</$1')
         .replace(/<(table|tbody|tr|td|th)[^>]*>/g,'<$1>')
         .replace(/<\?xml[^>]*>/g,'')
         .replace(/<[^ >]+:[^>]*>/g,'')
         .replace(/<\/[^ >]+:[^>]*>/g,'')
         .replace(/<br(\s+\/)?>$/g, '')
         .replace(/^\s*&nbsp\;\s*/g, '')
         .replace(/\s*&nbsp\;\s*$/g, '')
   },
   //         .replace(/(<[^\/]>|<[^\/][^>]*[^\/]>)\s*<\/[^>]*>/g,'')

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
         return doc.execCommand( 'inserthtml', false, '&nbsp;' );
      case 'nexttoolbar':
         return this.nextToolBar( editor );
      default:
         var cmds = but[ 2 ].split( '+' );

         for (var i = 0, l = cmds.length; i < l; i++) {
            doc.execCommand( cmds[ i ], false, val );
         }
      }

      if (b == 'clear') this.initialiseBody( editor );

      return;
   },

   fullscreen: function( editor ) {
      var height, width, iframe = editor.iframe;
      var toolbar = editor.toolbar, options = this.options;

      if (editor.height == -1) {
         var container = $( options.container );

         editor.width  = iframe.getSize().size.x;
         editor.height = iframe.getSize().size.y;
         width         = container.getSize().size.x - options.iframeMargin;
         height        = container.getSize().size.y - options.iframeMargin
            - toolbar.getSize().size.y;
      }
      else { width = editor.width; height = editor.height; editor.height = -1; }

      toolbar.setStyle( 'width', (width  - options.iframePadding) + 'px' );
      iframe.setStyle(  'width',  width  + 'px' );
      iframe.setStyle(  'height', height + 'px' );
      return;
   },

   initialiseBody: function( editor, html ) {
      html = html && html.length > 0
           ? html.replace( /&nbsp;/g, '\u00a0' ) : this.options.defaultBody;
      $( editor.doc.body ).setHTML( html );
   },

   initialiseToolbar: function( editor ) {
      var options  = this.options;
      var panels   = options.toolbars[ editor.barNum ];
      var barWidth = 0;
      var rowWidth = 0;

      editor.toolbar.empty();

      panels.each( function( p, index ) {
         if (! p) {
            new Element( 'br' ).inject( editor.toolbar ); rowWidth = 0; return;
         }

         var found = false;

         options.panels[ p ].each( function( b ) {
            var added = this.addButton( editor, b );

            if (added) rowWidth += options.buttonWidth;

            found = found || added;
         }, this );

         if (found && $defined( panels[ index + 1 ] )) {
            new Element( 'span', { class: 'spacer' } ).inject( editor.toolbar );

            rowWidth += options.spacerWidth;
         }

         barWidth = Math.max( barWidth, rowWidth );
      }, this );

      barWidth = Math.max( options.minWidth, barWidth );
      editor.toolbar.setStyle( 'width', barWidth );
      editor.iframe.setStyle( 'width', barWidth + options.iframePadding );
      return;
   },

   nextToolBar: function( editor ) {
      editor.barNum += 1;

      if (editor.barNum > this.options.toolbars.length - 1) editor.barNum = 0;

      this.initialiseToolbar( editor );
      return;
   },

   toEditor: function( editor, view ) {
      this.initialiseBody( editor, editor.element.value.trim() || '' );

      if (view) {
         editor.element.addClass( 'hidden' );
         editor.iframe.removeClass( 'hidden' );
         editor.toolbar.removeClass( 'disabled' );
         editor.iframe.contentWindow.focus();
      }

      return;
   },

   toggleView: function( editor ) {
      if (editor.doc.body) {
         editor.open = ! editor.open;

         if (editor.open) this.toEditor( editor, true );
         else this.toTextarea( editor, true );
      }

      return;
   },

   toTextarea: function( editor, view ) {
      editor.element.value = this.clean( editor.doc.body.innerHTML );

      if (view) {
         editor.element.removeClass( 'hidden' );
         editor.iframe.addClass( 'hidden' );
         editor.toolbar.addClass( 'disabled' );
         editor.element.focus();
      }

      return;
   }
} );

WYSIWYG.implement( new Options );

function Expand_Collapse() {}

/* Local Variables:
 * mode: java
 * tab-width: 3
 * End:
 */
