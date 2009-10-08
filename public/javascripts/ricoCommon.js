/*
 *  Copyright 2005 Sabre Airline Solutions
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 *  file except in compliance with the License. You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software distributed under the
 *  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 *  either express or implied. See the License for the specific language governing permissions
 *  and limitations under the License.
 */

if (typeof Rico=='undefined') throw("Cannot find the Rico object");
if (typeof Prototype=='undefined') throw("Rico requires the Prototype JavaScript framework");
Rico.prototypeVersion = parseFloat(Prototype.Version.split(".")[0] + "." + Prototype.Version.split(".")[1]);
if (Rico.prototypeVersion < 1.3) throw("Rico requires Prototype JavaScript framework version 1.3 or greater");

/** @namespace */
var RicoUtil = {

/**
 * Finds all immediate children of e with tagName
 * @param e DOM node or node id
 * @param tagName tag name to search for (case-insensative)
 * @returns array of matching elements
 */
getDirectChildrenByTag: function(e, tagName) {
  tagName=tagName.toLowerCase();
  return $(e).childElements().inject([],function(result,child) {
    if (child.tagName && child.tagName.toLowerCase()==tagName) result.push(child);
    return result;});
},

/**
 * Returns a new XML document object
 */
createXmlDocument : function() {
  if (document.implementation && document.implementation.createDocument) {
    var doc = document.implementation.createDocument("", "", null);
    // some older versions of Moz did not support the readyState property
    // and the onreadystate event so we patch it! 
    if (doc.readyState == null) {
      doc.readyState = 1;
      doc.addEventListener("load", function () {
        doc.readyState = 4;
        if (typeof doc.onreadystatechange == "function") {
          doc.onreadystatechange();
        }
      }, false);
    }

     return doc;
  }

  if (window.ActiveXObject)
      return Try.these(
        function() { return new ActiveXObject('MSXML2.DomDocument');   },
        function() { return new ActiveXObject('Microsoft.DomDocument');},
        function() { return new ActiveXObject('MSXML.DomDocument');    },
        function() { return new ActiveXObject('MSXML3.DomDocument');   }
      ) || false;

  return null;
},

/**
 * Return text within an html element
 * @param el DOM node
 * @param xImg true to exclude img tag info
 * @param xForm true to exclude input, select, and textarea tags
 * @param xClass exclude elements with a class name of xClass
 */
getInnerText: function(el,xImg,xForm,xClass) {
  switch (typeof el) {
    case 'string': return el;
    case 'undefined': return el;
    case 'number': return el.toString();
  }
  var cs = el.childNodes;
  var l = cs.length;
  var str = "";
  for (var i = 0; i < l; i++) {
   switch (cs[i].nodeType) {
     case 1: //ELEMENT_NODE
       if (Element.getStyle(cs[i],'display')=='none') continue;
       if (xClass && Element.hasClassName(cs[i],xClass)) continue;
       switch (cs[i].tagName.toLowerCase()) {
         case 'img':   if (!xImg) str += cs[i].alt || cs[i].title || cs[i].src; break;
         case 'input': if (cs[i].type=='hidden') continue;
         case 'select':
         case 'textarea': if (!xForm) str += $F(cs[i]) || ''; break;
         default:      str += this.getInnerText(cs[i],xImg,xForm,xClass); break;
       }
       break;
     case 3: //TEXT_NODE
       str += cs[i].nodeValue;
       break;
   }
  }
  return str;
},

/**
 * Return value of a node in an XML response.
 * For Konqueror 3.5, isEncoded must be true.
 */
getContentAsString: function( parentNode, isEncoded ) {
  if (isEncoded) return this._getEncodedContent(parentNode);
  if (typeof parentNode.xml != 'undefined') return this._getContentAsStringIE(parentNode);
  return this._getContentAsStringMozilla(parentNode);
},

_getEncodedContent: function(parentNode) {
  if (parentNode.innerHTML) return parentNode.innerHTML;
  switch (parentNode.childNodes.length) {
    case 0:  return "";
    case 1:  return parentNode.firstChild.nodeValue;
    default: return parentNode.childNodes[1].nodeValue;
  }
},

_getContentAsStringIE: function(parentNode) {
  var contentStr = "";
  for ( var i = 0 ; i < parentNode.childNodes.length ; i++ ) {
     var n = parentNode.childNodes[i];
     contentStr += (n.nodeType == 4) ? n.nodeValue : n.xml;
  }
  return contentStr;
},

_getContentAsStringMozilla: function(parentNode) {
   var xmlSerializer = new XMLSerializer();
   var contentStr = "";
   for ( var i = 0 ; i < parentNode.childNodes.length ; i++ ) {
        var n = parentNode.childNodes[i];
        if (n.nodeType == 4) { // CDATA node
            contentStr += n.nodeValue;
        }
        else {
          contentStr += xmlSerializer.serializeToString(n);
      }
   }
   return contentStr;
},

/**
 * @deprecated Will be removed in Rico 3
 */
docElement: function() {
  return (document.compatMode && document.compatMode.indexOf("CSS")!=-1) ? document.documentElement : document.getElementsByTagName("body")[0];
},

/**
 * @returns available height, excluding scrollbar & margin
 * @deprecated Use Prototype's document.viewport.getHeight instead
 */
windowHeight: function() {
  if (document.viewport) {
    // use prototype 1.6 function
    return document.viewport.getHeight();
  } else {
    return window.innerHeight? window.innerHeight : this.docElement().clientHeight;
  }
},

/**
 * @returns available width, excluding scrollbar & margin
 * @deprecated Use Prototype's document.viewport.getWidth instead
 */
windowWidth: function() {
  if (document.viewport) {
    // use prototype 1.6 function
    return document.viewport.getWidth();
  } else {
    return this.docElement().clientWidth;
  }
},

/**
 * @deprecated Use Prototype's document.viewport.getScrollOffsets instead
 */
docScrollLeft: function() {
  if ( window.pageXOffset ) {
    return window.pageXOffset;
  } else if ( document.documentElement && document.documentElement.scrollLeft ) {
    return document.documentElement.scrollLeft;
  } else if ( document.body ) {
    return document.body.scrollLeft;
  } else {
    return 0;
  }
},

/**
 * @deprecated Use Prototype's document.viewport.getScrollOffsets instead
 */
docScrollTop: function() {
  if ( window.pageYOffset ) {
    return window.pageYOffset;
  } else if ( document.documentElement && document.documentElement.scrollTop ) {
    return document.documentElement.scrollTop;
  } else if ( document.body ) {
    return document.body.scrollTop;
  } else {
    return 0;
  }
},

/**
 * @param n a number (or a string to be converted using parseInt)
 * @returns the integer value of n, or 0 if n is not a number
 */
nan2zero: function(n) {
  if (typeof(n)=='string') n=parseInt(n,10);
  return isNaN(n) || typeof(n)=='undefined' ? 0 : n;
},

/**
 * @param e event object
 * @returns the key code stored in the event
 */
eventKey: function(e) {
  if( typeof( e.keyCode ) == 'number'  ) {
    return e.keyCode; //DOM
  } else if( typeof( e.which ) == 'number' ) {
    return e.which;   //NS 4 compatible
  } else if( typeof( e.charCode ) == 'number'  ) {
    return e.charCode; //also NS 6+, Mozilla 0.9+
  }
  return -1;  //total failure, we have no way of obtaining the key code
},

/**
 * Return the previous sibling that has the specified tagName
 */
 getPreviosSiblingByTagName: function(el,tagName) {
 	var sib=el.previousSibling;
 	while (sib) {
 		if ((sib.tagName==tagName) && (sib.style.display!='none')) return sib;
 		sib=sib.previousSibling;
 	}
 	return null;
 },

/**
 * Return the parent of el that has the specified tagName.
 * @param el DOM node
 * @param tagName tag to search for
 * @param className optional
 */
getParentByTagName: function(el,tagName,className) {
  var par=el;
  tagName=tagName.toLowerCase();
  while (par) {
    if (par.tagName && par.tagName.toLowerCase()==tagName) {
      if (!className || par.className.indexOf(className)>=0) return par;
    }
  	par=par.parentNode;
  }
  return null;
},

/**
 * Wrap the children of a DOM element in a new element
 * @param el the element whose children are to be wrapped
 * @param cls class name of the wrapper (optional)
 * @param id id of the wrapper (optional)
 * @param wrapperTag type of wrapper element to be created (optional, defaults to DIV)
 * @returns new wrapper element
 */
wrapChildren: function(el,cls,id,wrapperTag) {
  var wrapper = document.createElement(wrapperTag || 'div');
  if (id) wrapper.id=id;
  if (cls) wrapper.className=cls;
  while (el.firstChild) {
    wrapper.appendChild(el.firstChild);
  }
  el.appendChild(wrapper);
  return wrapper;
},

/**
 * Format a positive number (integer or float)
 * @param posnum number to format
 * @param decPlaces the number of digits to display after the decimal point
 * @param thouSep the character to use as the thousands separator
 * @param decPoint the character to use as the decimal point
 * @returns formatted string
 */
formatPosNumber: function(posnum,decPlaces,thouSep,decPoint) {
  var a=posnum.toFixed(decPlaces).split(/\./);
  if (thouSep) {
    var rgx = /(\d+)(\d{3})/;
    while (rgx.test(a[0])) {
      a[0]=a[0].replace(rgx, '$1'+thouSep+'$2');
    }
  }
  return a.join(decPoint);
},

/**
 * Post condition - if childNodes[n] is refChild, than childNodes[n+1] is newChild.
 * @deprecated Use Prototype's Element#insert instead
 */
DOMNode_insertAfter: function(newChild,refChild) {
  var parentx=refChild.parentNode;
  if (parentx.lastChild==refChild) {
    return parentx.appendChild(newChild);
  } else {
    return parentx.insertBefore(newChild,refChild.nextSibling);
  }
},

/**
 * Positions ctl over icon
 * @param ctl (div with position:absolute)
 * @param icon element (img, button, etc) that ctl should be displayed next to
 */
positionCtlOverIcon: function(ctl,icon) {
  var offsets=Position.page(icon);
  var scrTop=this.docScrollTop();
  var winHt=this.windowHeight();
  if (ctl.style.display=='none') ctl.style.display='block';
  var correction=Prototype.Browser.IE ? 1 : 2;  // based on a 1px border
  var lpad=this.nan2zero(Element.getStyle(icon,'padding-left'));
  ctl.style.left = (offsets[0]+lpad+correction)+'px';
  var newTop=offsets[1] + correction + scrTop;
  var ctlht=ctl.offsetHeight;
  var iconht=icon.offsetHeight;
  var margin=10;  // account for shadow
  if (newTop+iconht+ctlht+margin < winHt+scrTop) {
    newTop+=iconht;  // display below icon
  } else {
    newTop=Math.max(newTop-ctlht,scrTop);  // display above icon
  }
  ctl.style.top = newTop+'px';
},

/**
 * Creates a form element 
 * @param parent new element will be appended to this node
 * @param elemTag element to be created (input, button, select, textarea, ...)
 * @param elemType for input tag this specifies the type (checkbox, radio, text, ...)
 * @param id id for new element
 * @param name name for new element, if not specified then name will be the same as the id
 * @returns new element
 */
createFormField: function(parent,elemTag,elemType,id,name) {
  var field;
  if (typeof name!='string') name=id;
  if (Prototype.Browser.IE) {
    // IE cannot set NAME attribute on dynamically created elements
    var s=elemTag+' id="'+id+'"';
    if (elemType) {
      s+=' type="'+elemType+'"';
    }
    if (elemTag.match(/^(form|input|select|textarea|object|button|img)$/)) {
      s+=' name="'+name+'"';
    }
    field=document.createElement('<'+s+' />');
  } else {
    field=document.createElement(elemTag);
    if (elemType) {
      field.type=elemType;
    }
    field.id=id;
    if (typeof field.name=='string') {
      field.name=name;
    }
  }
  parent.appendChild(field);
  return field;
},

/**
 * Adds a new option to the end of a select list
 * @returns new option element
 */
addSelectOption: function(elem,value,text) {
  var opt=document.createElement('option');
  if (typeof value=='string') opt.value=value;
  opt.text=text;
  if (Prototype.Browser.IE) {
    elem.add(opt);
  } else {
    elem.add(opt,null);
  }
  return opt;
},

/**
 * @returns the value of the specified cookie (or null if it doesn't exist)
 */
getCookie: function(itemName) {
  var arg = itemName+'=';
  var alen = arg.length;
  var clen = document.cookie.length;
  var i = 0;
  while (i < clen) {
    var j = i + alen;
    if (document.cookie.substring(i, j) == arg) {
      var endstr = document.cookie.indexOf (';', j);
      if (endstr == -1) {
        endstr=document.cookie.length;
      }
      return unescape(document.cookie.substring(j, endstr));
    }
    i = document.cookie.indexOf(' ', i) + 1;
    if (i == 0) break;
  }
  return null;
},

/**
 * Write information to a cookie.
 * For cookies to be retained for the current session only, set daysToKeep=null.
 * To erase a cookie, pass a negative daysToKeep value.
 * @see <a href="http://www.quirksmode.org/js/cookies.html">Quirksmode article</a> for more information about cookies.
 */
setCookie: function(itemName,itemValue,daysToKeep,cookiePath,cookieDomain) {
	var c = itemName+"="+escape(itemValue);
	if (typeof(daysToKeep)=='number') {
		var date = new Date();
		date.setTime(date.getTime()+(daysToKeep*24*60*60*1000));
		c+="; expires="+date.toGMTString();
	}
	if (typeof(cookiePath)=='string') {
    c+="; path="+cookiePath;
  }
	if (typeof(cookieDomain)=='string') {
    c+="; domain="+cookieDomain;
  }
  document.cookie = c;
}

};


if (!RicoTranslate) {

/** @namespace Translation helper object. Values are set by loading one of the ricoLocale_xx.js files. */
var RicoTranslate = {
  phrases : {},
  phrasesById : {},
  /** thousands separator for number formatting */
  thouSep : ",",
  /** decimal point for number formatting */
  decPoint: ".",
  /** target language (2 character code) */
  langCode: "en",
  re      : /^(\W*)\b(.*)\b(\W*)$/,
  /** date format */
  dateFmt : "mm/dd/yyyy",
  /** time format */
  timeFmt : "hh:nn:ss a/pm",
  /** month name array (Jan is at index 0) */
  monthNames: ['January','February','March','April','May','June',
               'July','August','September','October','November','December'],
  /** day of week array (Sunday is at index 0) */
  dayNames: ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'],

  /** 
   * @param monthIdx 0-11
   * @returns 3 character abbreviation
   */
  monthAbbr: function(monthIdx) {
    return this.monthNames[monthIdx].substr(0,3);
  },

  /** 
   * @param dayIdx 0-6 (Sunday=0)
   * @returns 3 character day of week abbreviation
   */
  dayAbbr: function(dayIdx) {
    return this.dayNames[dayIdx].substr(0,3);
  },

/**
 * @deprecated Use addPhraseId instead
 */
  addPhrase: function(fromPhrase, toPhrase) {
    this.phrases[fromPhrase]=toPhrase;
  },

/**
 * @deprecated Use getPhraseById instead
 * @param fromPhrase may contain multiple words/phrases separated by tabs
 * and each portion will be looked up separately.
 * Punctuation & spaces at the beginning or
 * ending of a phrase are ignored.
 */
  getPhrase: function(fromPhrase) {
    var words=fromPhrase.split(/\t/);
    var transWord,translated = '';
    for (var i=0; i<words.length; i++) {
      if (this.re.exec(words[i])) {
        transWord=this.phrases[RegExp.$2];
        translated += (typeof transWord=='string') ? RegExp.$1+transWord+RegExp.$3 : words[i];
      } else {
        translated += words[i];
      }
    }
    return translated;
  },
  
  addPhraseId: function(phraseId, phrase) {
    this.phrasesById[phraseId]=phrase;
  },

  getPhraseById: function(phraseId) {
    var phrase=this.phrasesById[phraseId];
    if (!phrase) {
      alert('Error: missing phrase for '+phraseId);
      return '';
    }
    if (arguments.length <= 1) return phrase;
    var a=arguments;
    return phrase.replace(/(\$\d)/g,
      function($1) {
        var idx=parseInt($1.charAt(1),10);
        return (idx < a.length) ? a[idx] : '';
      }
    );
  }
};

}


if (!Date.prototype.formatDate) {
/**
 * Converts a date to a string according to specs in fmt
 * @returns formatted string
 * @param fmt string specifying the output format, may be one of the following:<dl>
 * <dt>locale or localeDateTime</dt>
 *   <dd>use javascript's built-in toLocaleString() function</dd>
 * <dt>localeDate</dt>
 *   <dd>use javascript's built-in toLocaleDateString() function</dd>
 * <dt>translate or translateDateTime</dt>
 *   <dd>use the date and time format specified in the RicoTranslate object</dd>
 * <dt>translateDate</dt>
 *   <dd>use the date format specified in the RicoTranslate object</dd>
 * <dt>Otherwise</dt>
 *   <dd>Any combination of: yyyy, yy, mmmm, mmm, mm, m, hh, h, HH, H, nn, ss, a/p</dd>
 *</dl>
 */
  Date.prototype.formatDate = function(fmt) {
    var d=this;
    var datefmt=(typeof fmt=='string') ? fmt : 'translateDate';
    switch (datefmt) {
      case 'locale':
      case 'localeDateTime':
        return d.toLocaleString();
      case 'localeDate':
        return d.toLocaleDateString();
      case 'translate':
      case 'translateDateTime':
        datefmt=RicoTranslate.dateFmt+' '+RicoTranslate.timeFmt;
        break;
      case 'translateDate':
        datefmt=RicoTranslate.dateFmt;
        break;
    }
    return datefmt.replace(/(yyyy|yy|mmmm|mmm|mm|dddd|ddd|dd|hh|nn|ss|a\/p)/gi,
      function($1) {
        var h;
        switch ($1) {
        case 'yyyy': return d.getFullYear();
        case 'yy':   return d.getFullYear().toString().substr(2);
        case 'mmmm': return RicoTranslate.monthNames[d.getMonth()];
        case 'mmm':  return RicoTranslate.monthAbbr(d.getMonth());
        case 'mm':   return (d.getMonth() + 1).toPaddedString(2);
        case 'm':    return (d.getMonth() + 1);
        case 'dddd': return RicoTranslate.dayNames[d.getDay()];
        case 'ddd':  return RicoTranslate.dayAbbr(d.getDay());
        case 'dd':   return d.getDate().toPaddedString(2);
        case 'd':    return d.getDate();
        case 'hh':   return ((h = d.getHours() % 12) ? h : 12).toPaddedString(2);
        case 'h':    return ((h = d.getHours() % 12) ? h : 12);
        case 'HH':   return d.getHours().toPaddedString(2);
        case 'H':    return d.getHours();
        case 'nn':   return d.getMinutes().toPaddedString(2);
        case 'ss':   return d.getSeconds().toPaddedString(2);
        case 'a/p':  return d.getHours() < 12 ? 'a' : 'p';
        }
      }
    );
  };
}

if (!Date.prototype.setISO8601) {
/**
 * Converts a string in ISO 8601 format to a date object.
 * @returns true if string is a valid date or date-time.
 * @param string value to be converted
 * @param offset can be used to bias the conversion and must be in minutes if provided
 * @see Based on <a href='http://delete.me.uk/2005/03/iso8601.html'>delete.me.uk article</a>
 */
  Date.prototype.setISO8601 = function (string,offset) {
    if (!string) return false;
    var d = string.match(/(\d\d\d\d)(?:-?(\d\d)(?:-?(\d\d)(?:[T ](\d\d)(?::?(\d\d)(?::?(\d\d)(?:\.(\d+))?)?)?(Z|(?:([-+])(\d\d)(?::?(\d\d))?)?)?)?)?)?/);
    if (!d) return false;
    if (!offset) offset=0;
    var date = new Date(d[1], 0, 1);

    if (d[2]) { date.setMonth(d[2] - 1); }
    if (d[3]) { date.setDate(d[3]); }
    if (d[4]) { date.setHours(d[4]); }
    if (d[5]) { date.setMinutes(d[5]); }
    if (d[6]) { date.setSeconds(d[6]); }
    if (d[7]) { date.setMilliseconds(Number("0." + d[7]) * 1000); }
    if (d[8]) {
        if (d[10] && d[11]) {
          offset = (Number(d[10]) * 60) + Number(d[11]);
        }
        offset *= ((d[9] == '-') ? 1 : -1);
        offset -= date.getTimezoneOffset();
    }
    var time = (Number(date) + (offset * 60 * 1000));
    this.setTime(Number(time));
    return true;
  };
}

if (!Date.prototype.toISO8601String) {
/**
 * Convert date to an ISO 8601 formatted string.
 * @param format an integer in the range 1-6 (default is 6):<dl>
 * <dt>1 (year)</dt>
 *   <dd>YYYY (eg 1997)</dd>
 * <dt>2 (year and month)</dt>
 *   <dd>YYYY-MM (eg 1997-07)</dd>
 * <dt>3 (complete date)</dt>
 *   <dd>YYYY-MM-DD (eg 1997-07-16)</dd>
 * <dt>4 (complete date plus hours and minutes)</dt>
 *   <dd>YYYY-MM-DDThh:mmTZD (eg 1997-07-16T19:20+01:00)</dd>
 * <dt>5 (complete date plus hours, minutes and seconds)</dt>
 *   <dd>YYYY-MM-DDThh:mm:ssTZD (eg 1997-07-16T19:20:30+01:00)</dd>
 * <dt>6 (complete date plus hours, minutes, seconds and a decimal
 *   fraction of a second)</dt>
 *   <dd>YYYY-MM-DDThh:mm:ss.sTZD (eg 1997-07-16T19:20:30.45+01:00)</dd>
 *</dl>
 * @see Based on: <a href='http://www.codeproject.com/jscript/dateformat.asp'>codeproject.com article</a>
 */
  Date.prototype.toISO8601String = function (format, offset) {
    if (!format) format=6;
    var date;
    if (!offset) {
        offset = 'Z';
        date = this;
    } else {
        var d = offset.match(/([-+])([0-9]{2}):([0-9]{2})/);
        var offsetnum = (Number(d[2]) * 60) + Number(d[3]);
        offsetnum *= ((d[1] == '-') ? -1 : 1);
        date = new Date(Number(Number(this) + (offsetnum * 60000)));
    }

    var zeropad = function (num) { return ((num < 10) ? '0' : '') + num; };

    var str = date.getUTCFullYear();
    if (format > 1) { str += "-" + zeropad(date.getUTCMonth() + 1); }
    if (format > 2) { str += "-" + zeropad(date.getUTCDate()); }
    if (format > 3) {
        str += "T" + zeropad(date.getUTCHours()) +
               ":" + zeropad(date.getUTCMinutes());
    }
    if (format > 5) {
      var secs = Number(date.getUTCSeconds() + "." +
                 ((date.getUTCMilliseconds() < 100) ? '0' : '') +
                 zeropad(date.getUTCMilliseconds()));
      str += ":" + zeropad(secs);
    } else if (format > 4) {
      str += ":" + zeropad(date.getUTCSeconds());
    }

    if (format > 3) { str += offset; }
    return str;
  };
}

if (!String.prototype.toISO8601Date) {
/**
 * Convert string in ISO 8601 format to a date
 * @returns new date object
 */
  String.prototype.toISO8601Date = function() {
    var d = new Date();
    return d.setISO8601(this) ? d : null;
  };
}

if (!String.prototype.formatDate) {
/**
 * Format string containing a date 
 * @see Date#formatDate
 */
  String.prototype.formatDate = function(fmt) {
    var s=this.replace(/-/g,'/');
    var d = new Date(s);
    return isNaN(d) ? this : d.formatDate(fmt);
  };
}

if (!Number.prototype.formatNumber) {
/**
 * Format a number according to the specs in fmt object.
 * @returns string, wrapped in a span element with a class of: negNumber, zeroNumber, posNumber
 * These classes can be set in CSS to display negative numbers in red, for example.
 *
 * @param fmt may contain any of the following:<dl>
 *   <dt>multiplier </dt><dd> the original number is multiplied by this amount before formatting</dd>
 *   <dt>decPlaces  </dt><dd> number of digits to the right of the decimal point</dd>
 *   <dt>decPoint   </dt><dd> character to be used as the decimal point</dd>
 *   <dt>thouSep    </dt><dd> character to use as the thousands separator</dd>
 *   <dt>prefix     </dt><dd> string added to the beginning of the result (e.g. a currency symbol)</dd>
 *   <dt>suffix     </dt><dd> string added to the end of the result (e.g. % symbol)</dd>
 *   <dt>negSign    </dt><dd> specifies format for negative numbers: L=leading minus, T=trailing minus, P=parens</dd>
 *</dl>
 */
  Number.prototype.formatNumber = function(fmt) {
    if (isNaN(this)) return 'NaN';
    var n=this;
    if (typeof fmt.multiplier=='number') n*=fmt.multiplier;
    var decPlaces=typeof fmt.decPlaces=='number' ? fmt.decPlaces : 0;
    var thouSep=typeof fmt.thouSep=='string' ? fmt.thouSep : RicoTranslate.thouSep;
    var decPoint=typeof fmt.decPoint=='string' ? fmt.decPoint : RicoTranslate.decPoint;
    var prefix=fmt.prefix || "";
    var suffix=fmt.suffix || "";
    var negSign=typeof fmt.negSign=='string' ? fmt.negSign : "L";
    negSign=negSign.toUpperCase();
    var s,cls;
    if (n<0.0) {
      s=RicoUtil.formatPosNumber(-n,decPlaces,thouSep,decPoint);
      if (negSign=="P") s="("+s+")";
      s=prefix+s;
      if (negSign=="L") s="-"+s;
      if (negSign=="T") s+="-";
      cls='negNumber';
    } else {
      cls=n==0.0 ? 'zeroNumber' : 'posNumber';
      s=prefix+RicoUtil.formatPosNumber(n,decPlaces,thouSep,decPoint);
    }
    return "<span class='"+cls+"'>"+s+suffix+"</span>";
  };
}

if (!String.prototype.formatNumber) {
/**
 * Take a string that can be converted via parseFloat
 * and format it according to the specs in fmt object.
 * Number in string may use a period or comma as the decimal point,
 * but should not contain any thousands separator.
 */
  String.prototype.formatNumber = function(fmt) {
    var n=parseFloat(this.replace(/,/,'.'));
    return isNaN(n) ? this : n.formatNumber(fmt);
  };
}

Rico.Shim = Class.create();
/** @lends Rico.Shim# */
if (Prototype.Browser.IE) {
  Rico.Shim.prototype = {
/**
 * @class Fixes select control bleed-thru on floating divs in IE. Used by Rico.Popup.
 * @see Based on <a href='http://www.dotnetjunkies.com/WebLog/jking/archive/2003/07/21/488.aspx'>technique published by Joe King</a>
 * @constructs
 */
    initialize: function(DivRef) {
      this.ifr = document.createElement('iframe');
      this.ifr.style.position="absolute";
      this.ifr.style.display = "none";
      this.ifr.style.top     = '0px';
      this.ifr.style.left    = '0px';
      this.ifr.src="javascript:false;";
      DivRef.parentNode.appendChild(this.ifr);
      this.DivRef=DivRef;
    },

    hide: function() {
      this.ifr.style.display = "none";
    },

    move: function() {
      this.ifr.style.top  = this.DivRef.style.top;
      this.ifr.style.left = this.DivRef.style.left;
    },

    show: function() {
      this.ifr.style.width   = this.DivRef.offsetWidth;
      this.ifr.style.height  = this.DivRef.offsetHeight;
      this.move();
      this.ifr.style.zIndex  = this.DivRef.currentStyle.zIndex - 1;
      this.ifr.style.display = "block";
    }
  };
} else {
  Rico.Shim.prototype = {
/** @ignore */
    initialize: function() {},
/** @ignore */
    hide: function() {},
/** @ignore */
    move: function() {},
/** @ignore */
    show: function() {}
  };
}


Rico.Shadow = Class.create(
/** @lends Rico.Shadow# */
{
/**
 * @class Creates a shadow for positioned elements. Used by Rico.Popup.
 * Uses blur filter in IE, and alpha-transparent png images for all other browsers.
 * @see Based on <a href='http://www.positioniseverything.net/articles/dropshadows.html'>positioniseverything article</a>
 * @constructs
 */
  initialize: function(DivRef) {
    this.div = document.createElement('div');
    this.div.style.position="absolute";
    this.div.style.top='0px';
    this.div.style.left='0px';
    if (typeof this.div.style.filter=='undefined') {
      new Image().src = Rico.imgDir+"shadow.png";
      new Image().src = Rico.imgDir+"shadow_ur.png";
      new Image().src = Rico.imgDir+"shadow_ll.png";
      this.createShadow();
      this.offset=5;
    } else {
      this.div.style.backgroundColor='#888';
      this.div.style.filter='progid:DXImageTransform.Microsoft.Blur(makeShadow=1, shadowOpacity=0.3, pixelRadius=3)';
      this.offset=0; // MS blur filter already does offset
    }
    this.div.style.display = "none";
    DivRef.parentNode.appendChild(this.div);
    this.DivRef=DivRef;
  },

  createShadow: function() {
    var tab = document.createElement('table');
    tab.style.height='100%';
    tab.style.width='100%';
    tab.cellSpacing=0;
    tab.dir='ltr';

    var tr1=tab.insertRow(-1);
    tr1.style.height='8px';
    var td11=tr1.insertCell(-1);
    td11.style.width='8px';
    var td12=tr1.insertCell(-1);
    td12.style.background="transparent url("+Rico.imgDir+"shadow_ur.png"+") no-repeat right bottom";

    var tr2=tab.insertRow(-1);
    var td21=tr2.insertCell(-1);
    td21.style.background="transparent url("+Rico.imgDir+"shadow_ll.png"+") no-repeat right bottom";
    var td22=tr2.insertCell(-1);
    td22.style.background="transparent url("+Rico.imgDir+"shadow.png"+") no-repeat right bottom";

    this.div.appendChild(tab);
  },

  hide: function() {
    this.div.style.display = "none";
  },

  move: function() {
    this.div.style.top  = (parseInt(this.DivRef.style.top || '0',10)+this.offset)+'px';
    this.div.style.left = (parseInt(this.DivRef.style.left || '0',10)+this.offset)+'px';
  },

  show: function() {
    this.div.style.width = this.DivRef.offsetWidth + 'px';
    this.div.style.height= this.DivRef.offsetHeight + 'px';
    this.move();
    this.div.style.zIndex= parseInt(Element.getStyle(this.DivRef,'z-index'),10) - 1;
    this.div.style.display = "block";
  }
});


Rico.Popup = Class.create(
/** @lends Rico.Popup# */
{
/**
 * @class Class to manage pop-up div windows.
 * @constructs
 * @param options object may contain any of the following:<dl>
 *   <dt>hideOnEscape</dt><dd> hide popup when escape key is pressed? default=true</dd>
 *   <dt>hideOnClick </dt><dd> hide popup when mouse button is clicked? default=true</dd>
 *   <dt>ignoreClicks</dt><dd> if true, mouse clicks within the popup are not allowed to bubble up to parent elements</dd>
 *   <dt>position    </dt><dd> defaults to absolute</dd>
 *   <dt>shadow      </dt><dd> display shadow with popup? default=true</dd>
 *   <dt>margin      </dt><dd> number of pixels to allow for shadow, default=6</dd>
 *   <dt>zIndex      </dt><dd> which layer? default=1</dd>
 *   <dt>overflow    </dt><dd> how to handle content that overflows div? default=auto</dd>
 *   <dt>canDragFunc </dt><dd> boolean value (or function that returns a boolean) indicating if it is ok to drag/reposition popup, default=false</dd>
 *</dl>
 * @param DivRef if supplied, then setDiv() is called at the end of initialization
 */
  initialize: function(options,DivRef,closeFunc) {
    this.options = {
      hideOnEscape  : true,
      hideOnClick   : true,
      ignoreClicks  : false,
      position      : 'absolute',
      shadow        : true,
      margin        : 6,
      zIndex        : 1,
      overflow      : 'auto',
      canDragFunc   : false
    };
    Object.extend(this.options, options || {});
    if (DivRef) this.setDiv(DivRef,closeFunc);
  },

/**
 * Apply popup behavior to a div that already exists in the DOM
 * @param DivRef div element in the DOM
 * @param closeFunc optional callback function when popup is closed
 */
  setDiv: function(DivRef,closeFunc) {
    this.divPopup=$(DivRef);
    var position=this.options.position == 'auto' ? Element.getStyle(this.divPopup,'position').toLowerCase() : this.options.position;
    if (!this.divPopup || position != 'absolute') return;
    this.closeFunc=closeFunc || this.closePopup.bindAsEventListener(this);
    this.shim=new Rico.Shim(this.divPopup);
    if (this.options.shadow)
      this.shadow=new Rico.Shadow(this.divPopup);
    if (this.options.hideOnClick)
      Event.observe(document,"click", this.closeFunc);
    if (this.options.hideOnEscape)
      Event.observe(document,"keyup", this._checkKey.bindAsEventListener(this));
    if (this.options.canDragFunc)
      Event.observe(this.titleDiv || this.divPopup, "mousedown", this.startDrag.bind(this));
    if (this.options.ignoreClicks || this.options.canDragFunc) this.ignoreClicks();
  },

/**
 * create popup div and insert content
 */
  createPopup: function(parentElem, content, ht, wi, className, closeFunc) {
    var div = document.createElement('div');
    div.style.position=this.options.position;
    div.style.zIndex=this.options.zIndex;
    div.style.overflow=this.options.overflow;
    div.style.top='0px';
    div.style.left='0px';
    div.style.height=ht;
    div.style.width=wi;
    div.className=className || 'ricoPopup';
    if (content) div.innerHTML=content;
    parentElem.appendChild(div);
    this.setDiv(div,closeFunc);
    this.contentDiv=div;
    if (this.options.canDragFunc===true)
      this.options.canDragFunc=this.safeDragTest.bind(this); 
  },

/**
 * @private Fixes problems with IE when clicking on the scrollbar
 * Not required when calling createWindow because dragging is only applied to the title bar
 */
  safeDragTest: function(elem,event) {
    return (elem.componentFromPoint && elem.componentFromPoint(event.clientX,event.clientY)!='') ?  false : elem==this.divPopup;
  },

/**
 * Create popup div with a title bar.
 * height (ht) and width (wi) parameters are required and apply to the content (title adds extra height)
 */
  createWindow: function(title, content, ht, wi, className) {
    var div = document.createElement('div');
    this.titleDiv = document.createElement('div');
    this.contentDiv = document.createElement('div');
    this.titleDiv.className='ricoTitle';
    this.titleDiv.innerHTML=title;
    this.titleDiv.style.position='relative';
    var img = document.createElement('img');
    img.src=Rico.imgDir+"close.gif";
    img.title=RicoTranslate.getPhraseById('close');
    img.style.cursor='pointer';
    img.style.position='absolute';
    img.style.right='0px';
    this.titleDiv.appendChild(img);
    this.contentDiv.className='ricoContent';
    this.contentDiv.innerHTML=content;
    this.contentDiv.style.height=ht;
    this.contentDiv.style.width=wi;
    this.contentDiv.style.overflow=this.options.overflow;
    div.style.position=this.options.position;
    div.style.zIndex=this.options.zIndex;
    div.style.top='0px';
    div.style.left='0px';
    div.style.display='none';
    div.className=className || 'ricoWindow';
    div.appendChild(this.titleDiv);
    div.appendChild(this.contentDiv);
    document.body.appendChild(div);
    this.setDiv(div);
    Event.observe(img,"click", this.closePopup.bindAsEventListener(this));
  },

/** @private */
  ignoreClicks: function() {
    Event.observe(this.divPopup,"click", this._ignoreClick.bindAsEventListener(this));
  },

  _ignoreClick: function(e) {
    if (e.stopPropagation)
      e.stopPropagation();
    else
      e.cancelBubble = true;
    return true;
  },

  // event handler to process keyup events (hide menu on escape key)
  _checkKey: function(e) {
    if (RicoUtil.eventKey(e)==27) this.closeFunc();
    return true;
  },

/**
 * Move popup to specified position
 */
  move: function(left,top) {
    if (typeof left=='number') this.divPopup.style.left=left+'px';
    if (typeof top=='number') this.divPopup.style.top=top+'px';
    if (this.shim) this.shim.move();
    if (this.shadow) this.shadow.move();
  },

/** @private */
  startDrag : function(event){
    var elem=Event.element(event);
    var canDrag=typeof(this.options.canDragFunc)=='function' ? this.options.canDragFunc(elem,event) : this.options.canDragFunc;
    if (!canDrag) return;
    this.divPopup.style.cursor='move';
    this.lastMouseX = event.clientX;
    this.lastMouseY = event.clientY;
    this.dragHandler = this.drag.bindAsEventListener(this);
    this.dropHandler = this.endDrag.bindAsEventListener(this);
    Event.observe(document, "mousemove", this.dragHandler);
    Event.observe(document, "mouseup", this.dropHandler);
    Event.stop(event);
  },

/** @private */
  drag : function(event){
    var newLeft = parseInt(this.divPopup.style.left,10) + event.clientX - this.lastMouseX;
    var newTop = parseInt(this.divPopup.style.top,10) + event.clientY - this.lastMouseY;
    this.move(newLeft, newTop);
    this.lastMouseX = event.clientX;
    this.lastMouseY = event.clientY;
    Event.stop(event);
  },

/** @private */
  endDrag : function(){
    this.divPopup.style.cursor='';
    Event.stopObserving(document, "mousemove", this.dragHandler);
    Event.stopObserving(document, "mouseup", this.dropHandler);
    this.dragHandler=null;
    this.dropHandler=null;
  },

/**
 * Display popup at specified position
 */
  openPopup: function(left,top) {
    this.divPopup.style.display="block";
    if (typeof left=='number') this.divPopup.style.left=left+'px';
    if (typeof top=='number') this.divPopup.style.top=top+'px';
    if (this.shim) this.shim.show();
    if (this.shadow) this.shadow.show();
  },

/**
 * Hide popup
 */
  closePopup: function() {
    if (this.dragHandler) this.endDrag();
    if (this.shim) this.shim.hide();
    if (this.shadow) this.shadow.hide();
    this.divPopup.style.display="none";
  }

});

Rico.includeLoaded('ricoCommon.js');
