/* $Id$ */

var checkObj = {
	CheckField : function( id, val ) {
      new Ajax( url + 'ajax',
         { method    : 'get',
           data      : 'path=' + path + '&method=ajax_check_field'
                       + '&id=' + id + '&val=' + val,
           onComplete: this.UpdateClass } ).request();
	},

   UpdateClass: function( text, xml ) {
      var id = xml.documentElement.getAttribute( 'id' );

		$( id ).className = xml.documentElement.getAttribute( 'result' );
   }
};

var cookieObj = {
   domain : '',
   expire : 90,
   name   : 'behaviour',
   path   : '/',
   secure : false,

   DeleteCookie: function( name ) {
      var cname, i, j, opts, pair, val;

      cname = sessionPrefix + '_' + cookieObj.name;
      val   = Cookie.get( cname );

      if (val && name) name = escape(name);
      else return false;

      if ((i = val.indexOf( name + '~' )) < 0) return false;

      j = val.substring(i).indexOf( '+' );

      if (i == 0) val = (j < 0) ? '' : val.substring( j + 1 );

      if (i > 0) {
         val = (j < 0) ? val.substring( 0, i - 1 ) :
            val.substring( 0, i - 1 ) + val.substring( i + j );
      }

      opts = { duration: cookieObj.expire, path: cookieObj.path,
               domain: cookieObj.domain, secure: cookieObj.secure };
      return Cookie.set( cname, val, opts );
   },

   GetCookie: function( name ) {
      var cname, cookies, i, pair, val;

      cname = sessionPrefix + '_' + cookieObj.name;
      val   = Cookie.get( cname );

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

   SetCookie: function( name, cookie ) {
      var cname, i, j, opts, pair, val;

      cname = sessionPrefix + '_' + cookieObj.name;
      val   = Cookie.get( cname );

      if (name) name = escape( name );
      else return;

      if (cookie) cookie = escape( cookie );

      if (val) {
         if ((i = val.indexOf( name + '~' )) >= 0) {
            j = val.substring( i ).indexOf( '+' );

            if (i == 0) {
               val = (j < 0) ? name + '~' + cookie :
                  name + '~' + cookie + val.substring( j );
            }
            else {
               val = (j < 0) ? val.substring( 0, i ) + name + '~' + cookie :
                  val.substring( 0, i ) + name + '~' + cookie
                  + val.substring( i + j );
            }
         }
         else { val += '+' + name + '~' + cookie }
      }
      else { val = name + '~' + cookie }

      opts = { duration: cookieObj.expire, path: cookieObj.path,
               domain: cookieObj.domain, secure: cookieObj.secure };
      return Cookie.set( cname, val, opts );
   }
};

var freeListObj = {
   AddItem: function(name) {
      var nelem = document.forms[0].elements['new'+name];
      var celem = document.forms[0].elements['cur'+name];
      var body, elem, rNo;

      if (nelem && celem) {
         celem.options[celem.length] = new Option(nelem.value);

         if (body = $( 'body' )) {
            if (elem = document.forms[0].elements['nRows'+name]) {
               rNo  = elem.value;
               elem.value = parseInt(rNo, 10)+1;
               elem = document.createElement('input');
               elem.setAttribute('value', nelem.value);
               elem.setAttribute('type', 'hidden');
               elem.setAttribute('id', name+rNo);
               elem.setAttribute('name', name);
               body.appendChild(elem);
            }
         }

         nelem.value = '';
      }

      return false;
   },

   RemoveItem: function(name) {
      var elem, hidden, i, j, nRows;

      if (elem = document.forms[0].elements['nRows'+name]) {
         nRows = parseInt(elem.value, 10);

         if (elem = document.forms[0].elements['cur'+name]) {
            for (i = elem.length-1; i >= 0; i--) {
               if (elem.options[i].selected == true) {
                  for (j = 0; j < nRows; j++) {
                     if (hidden = document.getElementById(name+j)) {
                        if (hidden.value == elem.options[i].value) {
                           hidden.name = 'del'+name; j = nRows;
                        }
                     }
                  }

                  elem.options[i] = null;
               }
            }
         }
      }

      return false;
   }
};

var gridObj = {
	gridKey  : null,
	gridId   : null,
	gridLive : null,
	pageSz   : 10,

	Table : function( key, id, imgs, pageSz, toggle ) {
		if (key && id && imgs) {
			var elem = $( key + id + 'Disp' );

			if (elem) {
				var img = imgs.split( '~' );

				if (toggle && elem.style.display != 'none') {
					elem.style.display = 'none';
					elem = $( key + id + 'Img' );

					if (elem) elem.src = img[0];

					gridObj.gridKey  = null;
               gridObj.gridId   = null;
					gridObj.gridLive = null;
               gridObj.pageSz   = 10;
				}
            else {
					if (gridObj.gridKey && gridObj.gridId) {
						var prev = $( gridObj.gridKey + gridObj.gridId + 'Disp' );

						if (prev) prev.style.display = 'none';

						prev = $(gridObj.gridKey + gridObj.gridId + 'Img' );

						if (prev) prev.src = img[0];

						gridObj.gridKey  = null;
                  gridObj.gridId   = null;
						gridObj.gridLive = null;
                  gridObj.pageSz   = 10;
					}

					elem.style.display = '';
					elem = $( key + id + 'Img' );

					if (elem) elem.src = img[1];

					gridObj.gridKey = key;
					gridObj.gridId  = id;
					gridObj.pageSz  = (pageSz ? pageSz : 10);
               new Ajax( url + 'ajax',
                  { method    : 'get',
                    data      : 'path=' + path + '&method=' + key
                                 + '_grid_table&id=' + id + '&val=' + pageSz,
                    onComplete: this.CreateGrid } ).request();
				}
			}
		}
	},

   CreateGrid : function(text, xml) {
      var keyid = gridObj.gridKey + gridObj.gridId;
      var count = parseInt( xml.documentElement.getAttribute( 'totalrows' ) );
      text = text.replace(/<ajax-response[^>]*>/, '');
      text = text.replace(/<\/ajax-response>/, '');
      text = text.replace(/<row[^>]*>/, '').replace(/<\/row>/, '');
      $( keyid + 'Disp' ).innerHTML = text.unescapeHTML();
		var opts = {
         bufferSize       : 7,
         pageSize         : 10,
			prefetchBuffer   : true,
         onscroll         : gridObj.UpdateHeader,
         onFirstContent   : function() { gridObj.UpdateHeader(0) },
			requestParameters: 'path=' + path + '&method='
                            + gridObj.gridKey + '_grid_rows',
         totalRows        : count
      };
		gridObj.gridLive = new LiveGrid( keyid + '_grid', url + 'ajax', opts );
	},

	UpdateHeader : function(offset) {
		var sortInfo, text, metaData = gridObj.gridLive.metaData;

		text  = 'Listing ' + (offset+1) + ' - ';
      text += (offset + metaData.getPageSize());
		text += ' of ' + metaData.getTotalRows();
      $( gridObj.gridKey + gridObj.gridId + '_header' ).innerHTML = text;

		if (gridObj.gridLive.sortCol) {
			sortInfo  = '&data_grid_sort_col=' + gridObj.gridLive.sortCol;
			sortInfo += '&data_grid_sort_dir=' + gridObj.gridLive.sortDir;
		}
      else sortInfo = '';

		text  = url + 'ajax?path=' + path + '&method=' + gridObj.gridKey;
		text += '_gridPage&data_grid_index=' + offset + sortInfo;
      $( gridObj.gridKey + gridObj.gridId + '_header' ).href = text;

      $$( '.tips' ).each( stateObj.tips.build, stateObj.tips );
	}
};

var loadMoreObj = {
   Request: function( method, id, val ) {
      new Ajax( url + 'ajax',
         { method    : 'get',
           data      : 'path=' + path + '&method='
                       + method + '&id=' + id + '&val=' + val,
           onComplete: this.Response } ).request();
   },

   Response: function(text, xml) {
      var id = xml.documentElement.getAttribute( 'id' );
      text = text.replace( /<ajax-response[^>]*>/, '' );
      text = text.replace( /<\/ajax-response>/, '' );
      text = text.replace( /<row[^>]*>/, '' ).replace( /<\/row>/, '' );
      $( id ).innerHTML = text.unescapeHTML();
      return;
   }
};

var stateObj = {
   accordion : null,
   linkFade  : null,
   scroller  : false,
   tips      : null,

   SetState: function( first_fld ) {
      var cookie, cookies, elem, height, p0, p1, pair, sbs;

      /* Initialize the fading links event handlers */
      stateObj.linkFade = new LinkFader( {} );

      /* Use cookies to restore the visual state of the page */
      sbs = false; cookie = cookieObj.GetCookie();

      if (cookie) {
         cookies = cookie.split( '+' );

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
         height = windowObj.GetAccordionHeight( elem );

         stateObj.accordion
            = new Accordion( 'div.sideBarHeader', 'div.sideBarPanel', {
               fixedHeight : height,
               opacity     : false,
               onActive    : function(toggler, element){
                  toggler.setStyle('background-color', '#663');
                  toggler.setStyle('color', '#FFC');
               },
               onBackground: function(toggler, element){
                  toggler.setStyle('background-color', '#CC9');
                  toggler.setStyle('color', '#000');
               }
            }, $( 'accordionDiv' ));

         if (sbs == false) elem.setStyle( 'display', 'none' );
      }

      stateObj.tips = new Tips( $$( '.tips' ), { showDelay: 666 } );

      if (stateObj.scroller) {
         stateObj.scroller
            = new Scroller( 'content', { area: 150, velocity: 1 });

         $( 'content' ).addEvent( 'mousedown', function() {
            this.setStyle( 'cursor',
                           'url(/static/images/closedhand.cur), move' );
            stateObj.scroller.start();
         } );

         $( 'content' ).addEvent( 'mouseup', function() {
            this.setStyle( 'cursor',
                           'url(/static/images/openhand.cur), move' );
            stateObj.scroller.stop();
         } );
      }

      windowObj.Resize();

      if (first_fld) $( first_fld ).focus();
   },

   Toggle: function( e ) {
      var elem = $( e.id + 'Disp' );

      if (elem.getStyle( 'display' ) != 'none') {
         elem.setStyle( 'display', 'none'); cookieObj.DeleteCookie( e.id );
      }
      else {
         elem.setStyle( 'display', '' ); cookieObj.SetCookie( e.id, true );
      }

      windowObj.Resize();
   },

   ToggleState: function( id ) {
      var elem = $( id + 'Box' );

      cookieObj.SetCookie( id, (elem.checked ? 'true' : 'false') );
   },

   ToggleSwap: function( e, s1, s2 ) {
      var elem;

      if (elem = $( e.id + 'Disp' )) {
         if (elem.getStyle( 'display' ) !=  'none') {
            elem.setStyle( 'display', 'none');
            cookieObj.DeleteCookie( e.id );

            if (elem = $( e.id )) elem.innerHTML = s2;
         }
         else {
            elem.setStyle( 'display', '' );
            cookieObj.SetCookie( e.id, s2 );

            if (elem = $( e.id )) elem.innerHTML = s1;
         }
      }

      windowObj.Resize();
   },

   ToggleSwapImg: function( e, s1, s2 ) {
      var elem;

      if (elem = $( e.id + 'Disp' )) {
         if (elem.getStyle( 'display' ) != 'none') {
            elem.setStyle( 'display', 'none');
            cookieObj.DeleteCookie( e.id );

            if (elem = $( e.id + 'Img' )) elem.src = s1;
         }
         else {
            elem.setStyle( 'display', '');
            cookieObj.SetCookie( e.id, s2 );

            if (elem = $( e.id + 'Img' )) elem.src = s2;
         }
      }

      windowObj.Resize();
   },

   ToggleSwapText: function( id, cookie, s1, s2 ) {
      var elem = $( id );

      if (cookieObj.GetCookie( cookie ) == 'true') {
         cookieObj.SetCookie( cookie, 'false' );

         if (elem) elem.innerHTML = s2;

         if (elem = $( cookie + 'Disp' )) elem.setStyle( 'display', 'none' );
      }
      else {
         cookieObj.SetCookie( cookie, 'true' );

         if (elem) elem.innerHTML = s1;

         if (elem = $( cookie + 'Disp' )) elem.setStyle( 'display', '' );
      }

      windowObj.Resize();
   }
}

var submitObj = {
   Chooser: function(value, formObj, button, url, formName, title, className,
                     field, whereFld, whereVal, winPrefs) {
      if (value && value.indexOf( '%' ) < 0) {
         if (formObj && button) {
            formObj._verb.value = button; formObj.submit();
         }

         return false;
      }

      url += '?button='+button+'&class='+className+'&field='+field;
      url += '&form='+formName+'&pressed=chooser&title='+title+'&value='+value;
      url += '&whereFld='+whereFld+'&whereVal='+whereVal;
      top.chooser = window.open( url, 'chooser', winPrefs );
      top.chooser.opener = top;
      return false;
   },

   ConfirmSubmit: function( key, text ) {
      if (text.length < 1 || window.confirm( text )) {
         document.forms[0].pressed.value = key;
         document.forms[0].submit();
         return true;
      }

      return false;
   },

   Refresh: function( name, cookie ) {
      cookieObj.SetCookie( name, cookie ); document.forms[0].submit();
   },

   ReturnValue: function( win, form, key, field, value ) {
      if (field) {
         field.value = value;

         if (field.focus) field.focus();
      }

      if (form && key) { form.pressed.value = key; form.submit() }

      win.close();
      return false;
   },

   SubmitForm: function( key ) {
      document.forms[0].pressed.value = key; document.forms[0].submit();
   },

   SubmitOnReturn: function( evt, key ) {
      var code = 0;

      code = evt.which;

      if (code == 13) {
         if (document.forms) {
            document.forms[0].pressed.value = key;
            document.forms[0].submit();
         }
         else { window.alert( 'Document contains no forms' ) }
      }

      return false;
   }
}

var tableObj = {
   AddTableRow: function( name, edit ) {
      var aelem, cell, cNo = 0, elem, fld, nelem, nRows, row;

      if (nelem = document.forms[0].elements['nRows'+name]) {
         nRows = parseInt(nelem.value, 10);

         if (elem = $( 'add' + name )) {
            row = document.createElement('tr');
            row.setAttribute('id', 'row'+name+nRows);

            while (aelem = $( 'add' + name + cNo )) {
               if (edit) {
                  fld = document.createElement('input');
                  fld.setAttribute('value', aelem.value);
                  fld.setAttribute('type', 'input');
                  fld.setAttribute('name', aelem.name+nRows);
                  if (aelem.size) { fld.setAttribute('size', aelem.size) }
                  if (aelem.maxlength) {
                     fld.setAttribute('maxlength', aelem.maxlength);
                  }
               }
               else {
                  fld = document.createTextNode(aelem.value);
               }

               cell = document.createElement('td');
               cell.appendChild(fld);
               row.appendChild(cell);
               aelem.value = ''; cNo++;
            }

            if (edit) {
               fld = document.createElement('input');
               fld.setAttribute('name', 'select'+name+nRows);
               fld.setAttribute('type', 'checkbox');
               cell = document.createElement('td');
               cell.setAttribute('align', 'center');
               cell.setAttribute('class', (cNo%2 == 0 ? 'even' : 'odd'));
               cell.appendChild(fld);
               row.appendChild(cell);
            }

            elem.parentNode.insertBefore(row, elem);
            nelem.value = nRows+1;
         }
      }

      return false;
   },

   RemoveTableRow: function( name ) {
      var elem, hidden, i, j, nRows;

      if (elem = document.forms[0].elements['nRows'+name]) {
         nRows = parseInt(elem.value, 10);

         for (i = 0; i < nRows; i++) {
            if (elem = document.forms[0].elements['select'+name+i]) {
               if (elem.checked) {
                  if (elem = document.getElementById('row'+name+i)) {
                     elem.parentNode.removeChild(elem);
                  }
               }
            }
         }
      }

      return false;
   }
};

var windowObj = {
   Expand_Collapse: function() {},

   GetAccordionHeight: function( elem ) {
      var togglers_len = $$( 'div.sideBarHeader' ).length;
      var height       = elem.getSize().size.y - ( 25 * togglers_len ) - 15;
      height           = Math.max( 1, height );
      return height;
   },

   PlaceOnTop: function() {
      if (self != top) {
         if (document.images) top.location.replace( window.location.href );
         else top.location.href = window.location.href;
      }
   },

   Resize: function() {
      var append, content, elem, elemHeight, elemWidth, h = window.getHeight();
      var height, w = window.getWidth();

      height = 5;
      cookieObj.SetCookie( 'width', w );
      cookieObj.SetCookie( 'height', h );
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

         stateObj.accordion.resize( windowObj.GetAccordionHeight( elem ),
                                    null );

         if (elem.getStyle( 'display' ) != 'none') {
            elemWidth = elem.getStyle( 'width' ).toInt();
            content.setStyle( 'marginLeft', elemWidth + 'px' );
            stateObj.accordion.reload();
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

   WayOut: function( href ) {
      Cookie.remove( sessionPrefix + '_session',
         { path: sessionPath, domain: '' } );

      if (document.images) top.location.replace( href );
      else top.location.href = href;
   },

   WindowOpen: function( href, target, prefs ) {
      window.open( href, target, prefs );
   }
}

if (target && target == 'top') windowObj.PlaceOnTop();

onresize = windowObj.Resize;
