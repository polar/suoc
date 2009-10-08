/*
 *  (c) 2005-2009 Richard Cowin (http://openrico.org)
 *  (c) 2005-2009 Matt Brown (http://dowdybrown.com)
 *
 *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
 *  file except in compliance with the License. You may obtain a copy of the License at
 *
 *         http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software distributed under the
 *  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 *  either express or implied. See the License for the specific language governing permissions
 *  and limitations under the License.
 */

if(typeof Rico=='undefined') throw("GridCommon requires the Rico JavaScript framework");
if(typeof RicoUtil=='undefined') throw("GridCommon requires the RicoUtil Library");


/**
 * @class Define methods that are common to both SimpleGrid and LiveGrid
 */
Rico.GridCommon = function() {};

Rico.GridCommon.prototype = {

  baseInit: function() {
    this.options = {
      resizeBackground : 'resize.gif',
      saveColumnInfo   : {width:true, filter:false, sort:false},  // save info in cookies?
      cookiePrefix     : 'RicoGrid.',
      allowColResize   : true,      // allow user to resize columns
      windowResize     : true,      // Resize grid on window.resize event? Set to false when embedded in an accordian.
      click            : null,
      dblclick         : null,
      contextmenu      : null,
      useUnformattedColWidth : true,
      menuEvent        : 'dblclick',  // event that triggers menus - click, dblclick, contextmenu, or none (no menus)
      defaultWidth     : 100,         // in the absence of any other width info, columns will be this many pixels wide
      scrollBarWidth   : 19,          // this is the value used in positioning calculations, it does not actually change the width of the scrollbar
      minScrollWidth   : 100,         // min scroll area width when width of frozen columns exceeds window width
      exportWindow     : "height=400,width=500,scrollbars=1,menubar=1,resizable=1",
      exportStyleList  : ['background-color','color','text-align','font-weight','font-size','font-family'],
      exportImgTags    : false,       // applies to grid header and to SimpleGrid cells (not LiveGrid cells)
      exportFormFields : true,
      FilterLocation   : null,        // heading row number to place filters. -1=add a new heading row.
      FilterAllToken   : '___ALL___', // select box value to use to indicate ALL
      columnSpecs      : []
    };
    this.colWidths = [];
    this.hdrCells=[];
    this.headerColCnt=0;
    this.headerRowIdx=0;       // row in header which gets resizers (no colspan's in this row)
    this.tabs=new Array(2);
    this.thead=new Array(2);
    this.tbody=new Array(2);
  },

  attachMenuEvents: function() {
    var i;
    if (!this.options.menuEvent || this.options.menuEvent=='none') return;
    this.hideScroll=navigator.userAgent.match(/Macintosh\b.*\b(Firefox|Camino)\b/i) || (Prototype.Browser.Opera && parseFloat(window.opera.version())<9.5);
    this.options[this.options.menuEvent]=this.handleMenuClick.bindAsEventListener(this);
    if (this.highlightDiv) {
      switch (this.options.highlightElem) {
        case 'cursorRow':
          this.attachMenu(this.highlightDiv[0]);
          break;
        case 'cursorCell':
          for (i=0; i<2; i++) {
            this.attachMenu(this.highlightDiv[i]);
          }
          break;
      }
    }
    for (i=0; i<2; i++) {
      this.attachMenu(this.tbody[i]);
    }
  },

  attachMenu: function(elem) {
    if (this.options.click)
      Event.observe(elem, 'click', this.options.click, false);
    if (this.options.dblclick) {
      if (Prototype.Browser.WebKit || Prototype.Browser.Opera)
        Event.observe(elem, 'click', this.handleDblClick.bindAsEventListener(this), false);
      else
        Event.observe(elem, 'dblclick', this.options.dblclick, false);
    }
    if (this.options.contextmenu) {
      if (Prototype.Browser.Opera || Rico.isKonqueror)
        Event.observe(elem, 'click', this.handleContextMenu.bindAsEventListener(this), false);
      else
        Event.observe(elem, 'contextmenu', this.options.contextmenu, false);
    }
  },

/**
 * implement double-click for browsers that don't support a double-click event (e.g. Safari)
 */
  handleDblClick: function(e) {
    var elem=Event.element(e);
    if (this.dblClickElem == elem) {
      this.options.dblclick(e);
    } else {
      this.dblClickElem = elem;
      this.safariTimer=setTimeout(this.clearDblClick.bind(this),300);
    }
  },

  clearDblClick: function() {
    this.dblClickElem=null;
  },

/**
 * implement right-click for browsers that don't support contextmenu event (e.g. Opera, Konqueror)
 * use control-click instead
 */
  handleContextMenu: function(e) {
    var b;
    if( typeof( e.which ) == 'number' )
      b = e.which; //Netscape compatible
    else if( typeof( e.button ) == 'number' )
      b = e.button; //DOM
    else
      return;
    if (b==1 && e.ctrlKey) {
      this.options.contextmenu(e);
    }
  },

  cancelMenu: function() {
    if (this.menu && this.menu.isVisible()) this.menu.cancelmenu();
  },

/**
 * gather info from original headings
 */
  getColumnInfo: function(hdrSrc) {
    Rico.writeDebugMsg('getColumnInfo: len='+hdrSrc.length);
    if (hdrSrc.length == 0) return 0;
    this.headerRowCnt=hdrSrc.length;
    var r,c,colcnt;
    for (r=0; r<this.headerRowCnt; r++) {
      var headerRow = hdrSrc[r];
      var headerCells=headerRow.cells;
      if (r >= this.hdrCells.length) this.hdrCells[r]=[];
      for (c=0; c<headerCells.length; c++) {
        var obj={};
        obj.cell=headerCells[c];
        obj.colSpan=headerCells[c].colSpan || 1;  // Safari & Konqueror return default colspan of 0
        if (this.options.useUnformattedColWidth) obj.initWidth=headerCells[c].offsetWidth;
        this.hdrCells[r].push(obj);
      }
      if (headerRow.id.slice(-5)=='_main') {
        colcnt=this.hdrCells[r].length;
        this.headerRowIdx=r;
      }
    }
    if (!colcnt) {
      this.headerRowIdx=this.headerRowCnt-1;
      colcnt=this.hdrCells[this.headerRowIdx].length;
    }
    Rico.writeDebugMsg("getColumnInfo: colcnt="+colcnt);
    return colcnt;
  },

  addHeadingRow: function() {
    var r=this.headerRowCnt++;
    this.hdrCells[r]=[];
    for( var h=0; h < 2; h++ ) {
      var row = this.thead[h].insertRow(-1);
      row.className='ricoLG_hdg '+this.tableId+'_hdg'+r;
      var limit= h==0 ? this.options.frozenColumns : this.headerColCnt-this.options.frozenColumns;
      for( var c=0; c < limit; c++ ) {
        var hdrCell=row.insertCell(-1);
        var colDiv=RicoUtil.wrapChildren(hdrCell,'ricoLG_col');
        RicoUtil.wrapChildren(colDiv,'ricoLG_cell');
        this.hdrCells[r].push({cell:hdrCell,colSpan:1});
      }
    }
    return r;
  },
  
/**
 * create column array
 */
  createColumnArray: function(columnType) {
    this.direction=Element.getStyle(this.outerDiv,'direction').toLowerCase();  // ltr or rtl
    this.align=this.direction=='rtl' ? ['right','left'] : ['left','right'];
    Rico.writeDebugMsg('createColumnArray: dir='+this.direction);
    this.columns = [];
    for (var c=0 ; c < this.headerColCnt; c++) {
      Rico.writeDebugMsg("createColumnArray: c="+c);
      var tabidx=c<this.options.frozenColumns ? 0 : 1;
      this.columns.push(new Rico[columnType](this, c, this.hdrCells[this.headerRowIdx][c], tabidx));
    }
    this.getCookie();
  },

/**
 * Create div structure
 */
  createDivs: function() {
    Rico.writeDebugMsg("createDivs start");
    this.outerDiv   = this.createDiv("outer");
    if (Prototype.Browser.Opera) this.outerDiv.style.overflow="hidden";
    this.scrollDiv  = this.createDiv("scroll",this.outerDiv);
    this.frozenTabs = this.createDiv("frozenTabs",this.outerDiv);
    this.innerDiv   = this.createDiv("inner",this.outerDiv);
    this.resizeDiv  = this.createDiv("resize",this.outerDiv);
    this.resizeDiv.style.display="none";
    this.exportDiv  = this.createDiv("export",this.outerDiv);
    this.exportDiv.style.display="none";
    this.messageDiv = this.createDiv("message",this.outerDiv);
    this.messageDiv.style.display="none";
    this.messageShadow=new Rico.Shadow(this.messageDiv);

    this.keywordDiv = this.createDiv("keyword",this.outerDiv);
    this.keywordDiv.style.display="none";
    this.keywordTitle=this.keywordDiv.appendChild(document.createElement("p"));
    Element.addClassName(this.keywordTitle,'keywordTitle');
    var instructions=this.keywordDiv.appendChild(document.createElement("p"));
    instructions.innerHTML=RicoTranslate.getPhraseById("keywordPrompt");
    this.keywordBox=this.keywordDiv.appendChild(document.createElement("input"));
    this.keywordBox.size=20;
    Event.observe(this.keywordBox,"keypress", this.keywordKey.bindAsEventListener(this), false);

    var img=document.createElement("img");
    img.src=Rico.imgDir+'checkmark.gif';
    Event.observe(img,"click", this.processKeyword.bindAsEventListener(this), false);
    this.keywordDiv.appendChild(img);

    img=document.createElement("img");
    img.src=Rico.imgDir+'delete.gif';
    Event.observe(img,"click", this.closeKeyword.bindAsEventListener(this), false);
    this.keywordDiv.appendChild(img);

    //this.frozenTabs.style[this.align[0]]='0px';
    //this.innerDiv.style[this.align[0]]='0px';
    Rico.writeDebugMsg("createDivs end");
  },
  
  keywordKey: function(e) {
    switch (RicoUtil.eventKey(e)) {
      case 27: this.closeKeyword(); Event.stop(e); return false;
      case 13: this.processKeyword(); Event.stop(e); return false;
    }
    return true;
  },
  
  openKeyword: function(colnum) {
    this.keywordCol=colnum;
    this.keywordBox.value='';
    this.keywordTitle.innerHTML=this.columns[colnum].displayName;
    this.centerMsg(this.keywordDiv);
    this.keywordBox.focus();
  },
  
  closeKeyword: function() {
    Element.hide(this.keywordDiv);
    this.cancelMenu();
  },
  
  processKeyword: function() {
    var keyword=this.keywordBox.value;
    this.closeKeyword();
    this.columns[this.keywordCol].setFilterKW(keyword);
  },

/**
 * Create a div and give it a standardized id and class name.
 * If the div already exists, then just assign the class name.
 */
  createDiv: function(elemName,elemParent) {
    var id=this.tableId+"_"+elemName+"Div";
    newdiv=$(id);
    if (!newdiv) {
      var newdiv = document.createElement("div");
      newdiv.id = id;
      if (elemParent) elemParent.appendChild(newdiv);
    }
    newdiv.className = "ricoLG_"+elemName+"Div";
    return newdiv;
  },

/**
 * Common code used to size & position divs in both SimpleGrid & LiveGrid
 */
  baseSizeDivs: function() {
    this.setOtherHdrCellWidths();

    if (this.options.frozenColumns) {
      Element.show(this.tabs[0]);
      Element.show(this.frozenTabs);
      // order of next 3 lines is critical in IE6
      this.hdrHt=Math.max(RicoUtil.nan2zero(this.thead[0].offsetHeight),this.thead[1].offsetHeight);
      this.dataHt=Math.max(RicoUtil.nan2zero(this.tbody[0].offsetHeight),this.tbody[1].offsetHeight);
      this.frzWi=this.borderWidth(this.tabs[0]);
    } else {
      Element.hide(this.tabs[0]);
      Element.hide(this.frozenTabs);
      this.frzWi=0;
      this.hdrHt=this.thead[1].offsetHeight;
      this.dataHt=this.tbody[1].offsetHeight;
    }

    var wiLimit,i;
    var borderWi=this.borderWidth(this.columns[0].dataCell);
    Rico.writeDebugMsg('baseSizeDivs '+this.tableId+': hdrHt='+this.hdrHt+' dataHt='+this.dataHt);
    //window.status=this.tableId+' frzWi='+this.frzWi+' borderWi='+borderWi;
    for (i=0; i<this.options.frozenColumns; i++) {
      if (this.columns[i].visible) this.frzWi+=parseInt(this.columns[i].colWidth,10)+borderWi;
    }
    this.scrTabWi=this.borderWidth(this.tabs[1]);
    for (i=this.options.frozenColumns; i<this.columns.length; i++) {
      if (this.columns[i].visible) this.scrTabWi+=parseInt(this.columns[i].colWidth,10)+borderWi;
    }
    this.scrWi=this.scrTabWi+this.options.scrollBarWidth;
    if (this.sizeTo=='parent') {
      if (Prototype.Browser.IE) Element.hide(this.outerDiv);
      wiLimit=this.outerDiv.parentNode.offsetWidth;
      if (Prototype.Browser.IE) Element.show(this.outerDiv);
    }  else {
      wiLimit=RicoUtil.windowWidth()-this.options.scrollBarWidth-8;
    }
    if (this.outerDiv.parentNode.clientWidth > 0)
      wiLimit=Math.min(this.outerDiv.parentNode.clientWidth, wiLimit);
    var overage=this.frzWi+this.scrWi-wiLimit;
    Rico.writeDebugMsg('baseSizeDivs '+this.tableId+': scrWi='+this.scrWi+' wiLimit='+wiLimit+' overage='+overage+' clientWidth='+this.outerDiv.parentNode.clientWidth);
    if (overage > 0 && this.options.frozenColumns < this.columns.length)
      this.scrWi=Math.max(this.scrWi-overage, this.options.minScrollWidth);
    this.scrollDiv.style.width=this.scrWi+'px';
    this.scrollDiv.style.top=this.hdrHt+'px';
    this.frozenTabs.style.width=this.scrollDiv.style[this.align[0]]=this.innerDiv.style[this.align[0]]=this.frzWi+'px';
    this.outerDiv.style.width=(this.frzWi+this.scrWi)+'px';
  },

/**
 * Returns the sum of the left & right border widths of an element
 */
  borderWidth: function(elem) {
    return RicoUtil.nan2zero(Element.getStyle(elem,'border-left-width')) + RicoUtil.nan2zero(Element.getStyle(elem,'border-right-width'));
  },

  setOtherHdrCellWidths: function() {
    var c,i,j,r,w,hdrcell,cell,origSpan,newSpan,divs;
    for (r=0; r<this.hdrCells.length; r++) {
      if (r==this.headerRowIdx) continue;
      Rico.writeDebugMsg('setOtherHdrCellWidths: r='+r);
      c=i=0;
      while (i<this.headerColCnt && c<this.hdrCells[r].length) {
        hdrcell=this.hdrCells[r][c];
        cell=hdrcell.cell;
        origSpan=newSpan=hdrcell.colSpan;
        for (w=j=0; j<origSpan; j++, i++) {
          if (this.columns[i].hdrCell.style.display=='none')
            newSpan--;
          else if (this.columns[i].hdrColDiv.style.display!='none')
            w+=parseInt(this.columns[i].colWidth,10);
        }
        if (!hdrcell.hdrColDiv || !hdrcell.hdrCellDiv) {
          divs=cell.getElementsByTagName('div');
          hdrcell.hdrColDiv=(divs.length<1) ? RicoUtil.wrapChildren(cell,'ricoLG_col') : divs[0];
          hdrcell.hdrCellDiv=(divs.length<2) ? RicoUtil.wrapChildren(hdrcell.hdrColDiv,'ricoLG_cell') : divs[1];
        }
        if (newSpan==0) {
          cell.style.display='none';
        } else if (w==0) {
          hdrcell.hdrColDiv.style.display='none';
          cell.colSpan=newSpan;
        } else {
          cell.style.display='';
          hdrcell.hdrColDiv.style.display='';
          cell.colSpan=newSpan;
          hdrcell.hdrColDiv.style.width=w+'px';
        }
        c++;
      }
    }
  },

  initFilterImage: function(filterRowNum){
    this.filterAnchor=$(this.tableId+'_filterLink');
    if (!this.filterAnchor) return;
    this.filterRows=$$('tr.'+this.tableId+'_hdg'+filterRowNum);
    if (this.filterRows.length!=2) return;
    for (var i=0, r=[]; i<2; i++) r[i]=Element.select(this.filterRows[i],'.ricoLG_cell');
    this.filterElements=r[0].concat(r[1]);
    this.saveHeight = this.filterElements[0].offsetHeight;
    var pt=Element.getStyle(this.filterElements[0],'padding-top');
    var pb=Element.getStyle(this.filterElements[0],'padding-bottom');
    if (pt) this.saveHeight-=parseInt(pt,10);
    if (pb) this.saveHeight-=parseInt(pb,10);
    this.rowNum = filterRowNum;
    this.setFilterImage(false);
    Event.observe(this.filterAnchor, 'click', this.toggleFilterRow.bindAsEventListener(this), false);
  },

  toggleFilterRow: function() {
    if ( this.filterRows[0].visible() )
      this.slideFilterUp();
    else
      this.slideFilterDown();
  },

  slideFilterUp: function() {
    for (var i=0; i<2; i++) this.filterRows[i].makeClipping();
    Rico.animate( new Rico.Effect.Height(this.filterElements, 0), {onFinish: function(){ for (var i=0; i<2; i++) this.filterRows[i].hide(); this.resizeWindow();}.bind(this)});
    this.setFilterImage(true);
  },

  slideFilterDown: function() {
    for (var i=0; i<2; i++) this.filterRows[i].show();
    Rico.animate(new Rico.Effect.Height( this.filterElements, this.saveHeight), {onFinish: function() { for (var i=0; i<2; i++) this.filterRows[i].undoClipping(); this.resizeWindow();}.bind(this)});
    this.setFilterImage(false);
  },

  setFilterImage: function(expandFlag) {
    var altText=RicoTranslate.getPhraseById((expandFlag ? 'show' : 'hide')+'FilterRow');
    this.filterAnchor.innerHTML = '<img src="'+Rico.imgDir+'tableFilter'+(expandFlag ? 'Expand' : 'Collapse')+'.gif" alt="'+altText+'" border="0">';
  },

/**
 * Returns a div for the cell at the specified row and column index.
 * In SimpleGrid, r can refer to any row in the grid.
 * In LiveGrid, r refers to a visible row (row 0 is the first visible row).
 */
  cell: function(r,c) {
    return (0<=c && c<this.columns.length && r>=0) ? this.columns[c].cell(r) : null;
  },

/**
 * Returns the screen height available for a grid
 */
  availHt: function() {
    var divPos=Position.page(this.outerDiv);
    return RicoUtil.windowHeight()-divPos[1]-2*this.options.scrollBarWidth-15;  // allow for scrollbar and some margin
  },

  setHorizontalScroll: function() {
    var newLeft=(-this.scrollDiv.scrollLeft)+'px';
    this.hdrTabs[1].style.left=newLeft;
  },

  pluginScroll: function() {
     if (this.scrollPluggedIn) return;
     Event.observe(this.scrollDiv,"scroll",this.scrollEventFunc, false);
     this.scrollPluggedIn=true;
  },

  unplugScroll: function() {
     Event.stopObserving(this.scrollDiv,"scroll", this.scrollEventFunc , false);
     this.scrollPluggedIn=false;
  },

  hideMsg: function() {
    if (this.messageDiv.style.display=="none") return;
    this.messageDiv.style.display="none";
    this.messageShadow.hide();
  },

  showMsg: function(msg) {
    this.messageDiv.innerHTML=msg;
    this.centerMsg(this.messageDiv);
    this.messageShadow.show();
    Rico.writeDebugMsg("showMsg: "+msg);
  },

  centerMsg: function(div) {
    Element.show(div);
    var msgWidth=div.offsetWidth;
    var msgHeight=div.offsetHeight;
    var divwi=this.outerDiv.offsetWidth;
    var divht=this.outerDiv.offsetHeight;
    div.style.top=parseInt((divht-msgHeight)/2,10)+'px';
    div.style.left=parseInt((divwi-msgWidth)/2,10)+'px';
  },

/**
 * @return array of column objects which have invisible status
 */
  listInvisible: function() {
    var hiddenColumns=[];
    for (var x=0;x<this.columns.length;x++) {
      if (this.columns[x].visible==false)
        hiddenColumns.push(this.columns[x]);
    }
    return hiddenColumns;
  },

/**
 * @return index of left-most visibile column, or -1 if there are no visible columns
 */
  firstVisible: function() {
    for (var x=0;x<this.columns.length;x++) {
      if (this.columns[x].visible) return x;
    }
    return -1;
  },

/**
 * Show all columns
 */
  showAll: function() {
    var invisible=this.listInvisible();
    for (var x=0;x<invisible.length;x++)
      invisible[x].showColumn();
  },
  
  chooseColumns: function(e) {
    Event.stop(e);
    this.menu.cancelmenu();
    var x,z,col,itemDiv,span,chooserDiv;
    if (!this.columnChooser) {
      z=Element.getStyle(this.outerDiv.offsetParent,'z-index');
      if (typeof z!='number') z=0;
      this.columnChooser=new Rico.Popup({canDragFunc:true, zIndex:z+2});
      this.columnChooser.createWindow(RicoTranslate.getPhraseById('gridChooseCols'),'','150px','200px','ricoLG_chooser');
      chooserDiv=this.columnChooser.contentDiv;
      for (x=0;x<this.columns.length;x++) {
        col=this.columns[x];
        itemDiv=chooserDiv.appendChild(document.createElement('div'));
        col.ChooserBox=RicoUtil.createFormField(itemDiv,'input','checkbox');
        span=itemDiv.appendChild(document.createElement('span'));
        span.innerHTML=col.displayName;
        Event.observe(col.ChooserBox, 'click', col.chooseColumn.bindAsEventListener(col), false);
      }
    }
    var divPos=Position.page(this.outerDiv);
    var divTop=divPos[1]+this.hdrHt+RicoUtil.docScrollTop();
    this.columnChooser.openPopup(divPos[0]+1,divTop);
    for (x=0;x<this.columns.length;x++) {
      this.columns[x].ChooserBox.checked=this.columns[x].visible;
      this.columns[x].ChooserBox.disabled = !this.columns[x].canHideShow();
    }
  },

  blankRow: function(r) {
    for (var c=0; c < this.columns.length; c++) {
      this.columns[c].clearCell(r);
    }
  },

/**
 * Copies all rows (SimpleGrid) or visible rows (LiveGrid) to a new window as a simple html table.
 */
  printVisible: function(exportType) {
    this.showMsg(RicoTranslate.getPhraseById('exportInProgress'));
    setTimeout(this._printVisible.bind(this,exportType),10);  // allow message to paint
  },

/**
 * Support function for printVisible()
 */
  exportStart: function() {
    var r,c,i,j,hdrcell,newSpan,divs,cell;
    this.exportRows=[];
    this.exportText="<table border='1' cellspacing='0'>";
    for (c=0; c<this.columns.length; c++) {
      if (this.columns[c].visible) this.exportText+="<col width='"+parseInt(this.columns[c].colWidth,10)+"'>";
    }
    this.exportText+="<thead style='display: table-header-group;'>";
    if (this.exportHeader) this.exportText+=this.exportHeader;
    for (r=0; r<this.hdrCells.length; r++) {
      if (this.hdrCells[r].length==0 || Element.getStyle(this.hdrCells[r][0].cell.parentNode,'display')=='none') continue;
      this.exportText+="<tr>";
      for (c=0,i=0; c<this.hdrCells[r].length; c++) {
        hdrcell=this.hdrCells[r][c];
        newSpan=hdrcell.colSpan;
        for (j=0; j<hdrcell.colSpan; j++, i++) {
          if (!this.columns[i].visible) newSpan--;
        }
        if (newSpan > 0) {
          divs=Element.select(hdrcell.cell,'.ricoLG_cell');
          cell=divs && divs.length>0 ? divs[0] : hdrcell.cell;
          this.exportText+="<td style='"+this.exportStyle(cell)+"'";
          if (hdrcell.colSpan > 1) this.exportText+=" colspan='"+newSpan+"'";
          this.exportText+=">"+RicoUtil.getInnerText(cell,!this.options.exportImgTags, !this.options.exportFormFields, 'NoExport')+"</td>";
        }
      }
      this.exportText+="</tr>";
    }
    this.exportText+="</thead><tbody>";
  },

/**
 * Support function for printVisible().
 * exportType is optional and defaults 'plain'; 'owc' can be used for IE users with Office Web Components.
 */
  exportFinish: function(exportType) {
    if (this.hideMsg) this.hideMsg();
    window.status=RicoTranslate.getPhraseById('exportComplete');
    if (this.exportRows.length > 0) this.exportText+='<tr>'+this.exportRows.join('</tr><tr>')+'</tr>';
    if (this.exportFooter) this.exportText+=this.exportFooter;
    this.exportText+="</tbody></table>";
    this.exportDiv.innerHTML=this.exportText;
    this.exportText=undefined;
    this.exportRows=undefined;
    if (this.cancelMenu) this.cancelMenu();
    var w=window.open(Rico.htmDir+'export-'+(exportType || 'plain')+'.html?'+this.exportDiv.id,'',this.options.exportWindow);
    if (w == null) alert(RicoTranslate.getPhraseById('disableBlocker'));
  },

/**
 * Support function for printVisible()
 */
  exportStyle: function(elem) {
    var styleList=this.options.exportStyleList;
    for (var i=0,s=''; i < styleList.length; i++) {
      try {
        var curstyle=Element.getStyle(elem,styleList[i]);
        if (curstyle) s+=styleList[i]+':'+curstyle+';';
      } catch(e) {};
    }
    return s;
  },

/**
 * Gets the value of the grid cookie and interprets the contents.
 * All information for a particular grid is stored in a single cookie.
 * This may include column widths, column hide/show status, current sort, and any column filters.
 */
  getCookie: function() {
    var c=RicoUtil.getCookie(this.options.cookiePrefix+this.tableId);
    if (!c) return;
    var cookieVals=c.split(',');
    for (var i=0; i<cookieVals.length; i++) {
      var v=cookieVals[i].split(':');
      if (v.length!=2) continue;
      var colnum=parseInt(v[0].slice(1),10);
      if (colnum < 0 || colnum >= this.columns.length) continue;
      var col=this.columns[colnum];
      switch (v[0].charAt(0)) {
        case 'w':
          col.setColWidth(v[1]);
          col.customWidth=true;
          break;
        case 'h':
          if (v[1].toLowerCase()=='true')
            col.hideshow(true,true);
          else
            col.hideshow(false,true);
          break;
        case 's':
          if (!this.options.saveColumnInfo.sort || !col.sortable) break;
          col.setSorted(v[1]);
          break;
        case 'f':
          if (!this.options.saveColumnInfo.filter || !col.filterable) break;
          var filterTemp=v[1].split('~');
          col.filterOp=filterTemp.shift();
          col.filterValues = [];
          col.filterType = Rico.TableColumn.USERFILTER;
          for (var j=0; j<filterTemp.length; j++)
            col.filterValues.push(unescape(filterTemp[j]));
          break;
      }
    }
  },

/**
 * Sets the grid cookie.
 * All information for a particular grid is stored in a single cookie.
 * This may include column widths, column hide/show status, current sort, and any column filters.
 */
  setCookie: function() {
    var cookieVals=[];
    for (var i=0; i<this.columns.length; i++) {
      var col=this.columns[i];
      if (this.options.saveColumnInfo.width) {
        if (col.customWidth) cookieVals.push('w'+i+':'+col.colWidth);
        if (col.customVisible) cookieVals.push('h'+i+':'+col.visible);
      }
      if (this.options.saveColumnInfo.sort) {
        if (col.currentSort != Rico.TableColumn.UNSORTED)
          cookieVals.push('s'+i+':'+col.currentSort);
      }
      if (this.options.saveColumnInfo.filter && col.filterType == Rico.TableColumn.USERFILTER) {
        var filterTemp=[col.filterOp];
        for (var j=0; j<col.filterValues.length; j++)
          filterTemp.push(escape(col.filterValues[j]));
        cookieVals.push('f'+i+':'+filterTemp.join('~'));
      }
    }
    RicoUtil.setCookie(this.options.cookiePrefix+this.tableId, cookieVals.join(','), this.options.cookieDays, this.options.cookiePath, this.options.cookieDomain);
  }

};

Rico.TableColumn = Class.create();

/** @constant */
Rico.TableColumn.UNFILTERED   = 0;
/** @constant */
Rico.TableColumn.SYSTEMFILTER = 1;
/** @constant */
Rico.TableColumn.USERFILTER   = 2;

/** @constant */
Rico.TableColumn.UNSORTED   = 0;
/** @constant */
Rico.TableColumn.SORT_ASC   = "ASC";
/** @constant */
Rico.TableColumn.SORT_DESC  = "DESC";

/** @property */
Rico.TableColumn.MINWIDTH   = 10;
/** @property */
Rico.TableColumn.DOLLAR  = {type:'number', prefix:'$', decPlaces:2, ClassName:'alignright'};
/** @property */
Rico.TableColumn.EURO    = {type:'number', prefix:'&euro;', decPlaces:2, ClassName:'alignright'};
/** @property */
Rico.TableColumn.PERCENT = {type:'number', suffix:'%', decPlaces:2, multiplier:100, ClassName:'alignright'};
/** @property */
Rico.TableColumn.QTY     = {type:'number', decPlaces:0, ClassName:'alignright'};
/** @property */
Rico.TableColumn.DEFAULT = {type:"raw"};


/**
 * @class Define methods that are common to columns in both SimpleGrid and LiveGrid
 */
Rico.TableColumnBase = function() {};

Rico.TableColumnBase.prototype = {

/**
 * Common code used to initialize the column in both SimpleGrid & LiveGrid
 */
  baseInit: function(liveGrid,colIdx,hdrInfo,tabIdx) {
    Rico.writeDebugMsg("TableColumnBase.init index="+colIdx+" tabIdx="+tabIdx);
    this.liveGrid  = liveGrid;
    this.index     = colIdx;
    this.hideWidth = Rico.isKonqueror || Prototype.Browser.WebKit || liveGrid.headerRowCnt>1 ? 5 : 2;  // column width used for "hidden" columns. Anything less than 5 causes problems with Konqueror. Best to keep this greater than padding used inside cell.
    this.options   = liveGrid.options;
    this.tabIdx    = tabIdx;
    this.hdrCell   = hdrInfo.cell;
    this.body = document.getElementsByTagName("body")[0];  // work around FireFox bug (document.body doesn't exist after XSLT)
    this.displayName  = this.getDisplayName(this.hdrCell);
    var divs=this.hdrCell.getElementsByTagName('div');
    this.hdrColDiv=(divs.length<1) ? RicoUtil.wrapChildren(this.hdrCell,'ricoLG_col') : divs[0];
    this.hdrCellDiv=(divs.length<2) ? RicoUtil.wrapChildren(this.hdrColDiv,'ricoLG_cell') : divs[1];
    var sectionIndex= tabIdx==0 ? colIdx : colIdx-liveGrid.options.frozenColumns;
    this.dataCell = liveGrid.tbody[tabIdx].rows[0].cells[sectionIndex];
    divs=this.dataCell.getElementsByTagName('div');
    this.dataColDiv=(divs.length<1) ? RicoUtil.wrapChildren(this.dataCell,'ricoLG_col') : divs[0];

    this.mouseDownHandler= this.handleMouseDown.bindAsEventListener(this);
    this.mouseMoveHandler= this.handleMouseMove.bindAsEventListener(this);
    this.mouseUpHandler  = this.handleMouseUp.bindAsEventListener(this);
    this.mouseOutHandler = this.handleMouseOut.bindAsEventListener(this);

    this.fieldName = 'col'+this.index;
    var spec = liveGrid.options.columnSpecs[colIdx];
    this.format=Object.extend( {}, Rico.TableColumn.DEFAULT);
    switch (typeof spec) {
      case 'object':
        if (typeof spec.format=='string') Object.extend(this.format, Rico.TableColumn[spec.format.toUpperCase()]);
        Object.extend(this.format, spec);
        break;
      case 'string':
        if (spec.slice(0,4)=='spec') spec=spec.slice(4).toUpperCase();  // for backwards compatibility
        this.format=typeof Rico.TableColumn[spec]=='object' ? Rico.TableColumn[spec] : Rico.TableColumn.DEFAULT;
        break;
    }
    Element.addClassName(this.dataColDiv, this.colClassName());
    this.visible=true;
    if (typeof this.format.visible=='boolean') this.visible=this.format.visible;
    Rico.writeDebugMsg("TableColumn.init index="+colIdx+" fieldName="+this.fieldName);
    this.sortable     = typeof this.format.canSort=='boolean' ? this.format.canSort : liveGrid.options.canSortDefault;
    this.currentSort  = Rico.TableColumn.UNSORTED;
    this.filterable   = typeof this.format.canFilter=='boolean' ? this.format.canFilter : liveGrid.options.canFilterDefault;
    this.filterType   = Rico.TableColumn.UNFILTERED;
    this.hideable     = typeof this.format.canHide=='boolean' ? this.format.canHide : liveGrid.options.canHideDefault;

    var wi=(typeof(this.format.width)=='number') ? this.format.width : hdrInfo.initWidth;
    wi=(typeof(wi)=='number') ? Math.max(wi,Rico.TableColumn.MINWIDTH) : liveGrid.options.defaultWidth;
    this.setColWidth(wi);
    if (!this.visible) this.setDisplay('none');
    if (this.options.allowColResize && !this.format.noResize) this.insertResizer();
  },
  
  colClassName: function() {
    return this.format.ClassName ? this.format.ClassName : this.liveGrid.tableId+'_col'+this.index;
  },

  insertResizer: function() {
    this.hdrCell.style.width='';
    var resizer=this.hdrCellDiv.appendChild(document.createElement('div'));
    resizer.className='ricoLG_Resize';
    resizer.style[this.liveGrid.align[1]]='0px';
    if (this.options.resizeBackground) {
      var resizePath=Rico.imgDir+this.options.resizeBackground;
      if (Prototype.Browser.IE && typeof(XDomainRequest)=='undefined') resizePath=location.protocol+resizePath;
      resizer.style.backgroundImage='url('+resizePath+')';
    }
    Event.observe(resizer,"mousedown", this.mouseDownHandler, false);
  },

/**
 * get the display name of a column
 */
  getDisplayName: function(el) {
    var anchors=el.getElementsByTagName("A");
    //Check the existance of A tags
    if (anchors.length > 0)
      return anchors[0].innerHTML;
    else
      return el.innerHTML.stripTags();
  },

  _clear: function(gridCell) {
    gridCell.innerHTML='&nbsp;';
  },

  clearCell: function(rowIndex) {
    var gridCell=this.cell(rowIndex);
    this._clear(gridCell,rowIndex);
    if (!this.liveGrid.buffer) return;
    var acceptAttr=this.liveGrid.buffer.options.acceptAttr;
    for (var k=0; k<acceptAttr.length; k++) {
      switch (acceptAttr[k]) {
        case 'style': gridCell.style.cssText=''; break;
        case 'class': gridCell.className=''; break;
        default:      gridCell['_'+acceptAttr[k]]=''; break;
      }
    }
  },

  dataTable: function() {
    return this.liveGrid.tabs[this.tabIdx];
  },

  numRows: function() {
    return this.dataColDiv.childNodes.length;
  },

  clearColumn: function() {
    var childCnt=this.numRows();
    for (var r=0; r<childCnt; r++)
      this.clearCell(r);
  },

  cell: function(r) {
    return this.dataColDiv.childNodes[r];
  },

  getFormattedValue: function(r,xImg,xForm,xClass) {
    return RicoUtil.getInnerText(this.cell(r),xImg,xForm,xClass);
  },

  setColWidth: function(wi) {
    if (typeof wi=='number') {
      wi=parseInt(wi,10);
      if (wi < Rico.TableColumn.MINWIDTH) return;
      wi=wi+'px';
    }
    Rico.writeDebugMsg('setColWidth '+this.index+': '+wi);
    this.colWidth=wi;
    this.hdrColDiv.style.width=wi;
    this.dataColDiv.style.width=wi;
  },

  pluginMouseEvents: function() {
    if (this.mousePluggedIn==true) return;
    Event.observe(this.body,"mousemove", this.mouseMoveHandler, false);
    Event.observe(this.body,"mouseup",   this.mouseUpHandler  , false);
    Event.observe(this.body,"mouseout",  this.mouseOutHandler , false);
    this.mousePluggedIn=true;
  },

  unplugMouseEvents: function() {
    Event.stopObserving(this.body,"mousemove", this.mouseMoveHandler, false);
    Event.stopObserving(this.body,"mouseup",   this.mouseUpHandler  , false);
    Event.stopObserving(this.body,"mouseout",  this.mouseOutHandler , false);
    this.mousePluggedIn=false;
  },

  handleMouseDown: function(e) {
    this.resizeStart=e.clientX;
    this.origWidth=parseInt(this.colWidth,10);
    var p=Position.positionedOffset(this.hdrCell);
    if (this.liveGrid.direction=='rtl') {
      this.edge=p[0]+this.liveGrid.options.scrollBarWidth;
      switch (this.tabIdx) {
        case 0: this.edge+=this.liveGrid.innerDiv.offsetWidth; break;
        case 1: this.edge-=this.liveGrid.scrollDiv.scrollLeft; break;
      }
    } else {
      this.edge=p[0]+this.hdrCell.offsetWidth;
      if (this.tabIdx>0) this.edge+=RicoUtil.nan2zero(this.liveGrid.tabs[0].offsetWidth)-this.liveGrid.scrollDiv.scrollLeft;
    }
    this.liveGrid.resizeDiv.style.left=this.edge+"px";
    this.liveGrid.resizeDiv.style.display="";
    this.liveGrid.outerDiv.style.cursor='e-resize';
    this.tmpHighlight=this.liveGrid.highlightEnabled;
    this.liveGrid.highlightEnabled=false;
    this.pluginMouseEvents();
    Event.stop(e);
  },

  handleMouseMove: function(e) {
    var delta=e.clientX-this.resizeStart;
    var newWidth=(this.liveGrid.direction=='rtl') ? this.origWidth-delta : this.origWidth+delta;
    if (newWidth < Rico.TableColumn.MINWIDTH) return;
    this.liveGrid.resizeDiv.style.left=(this.edge+delta)+"px";
    this.colWidth=newWidth;
    Event.stop(e);
  },

  handleMouseUp: function(e) {
    this.unplugMouseEvents();
    Rico.writeDebugMsg('handleMouseUp '+this.liveGrid.tableId);
    this.liveGrid.outerDiv.style.cursor='';
    this.liveGrid.resizeDiv.style.display="none";
    this.setColWidth(this.colWidth);
    this.customWidth=true;
    this.liveGrid.setCookie();
    this.liveGrid.highlightEnabled=this.tmpHighlight;
    this.liveGrid.sizeDivs();
    Event.stop(e);
  },

  handleMouseOut: function(e) {
    var reltg = (e.relatedTarget) ? e.relatedTarget : e.toElement;
    while (reltg != null && reltg.nodeName.toLowerCase() != 'body')
      reltg=reltg.parentNode;
    if (reltg!=null && reltg.nodeName.toLowerCase() == 'body') return true;
    this.handleMouseUp(e);
    return true;
  },

  setDisplay: function(d) {
    this.hdrCell.style.display=d;
    this.hdrColDiv.style.display=d;
    this.dataCell.style.display=d;
    this.dataColDiv.style.display=d;
  },
  
  hideshow: function(visible,noresize) {
    this.setDisplay(visible ? '' : 'none');
    this.liveGrid.cancelMenu();
    this.visible=visible;
    this.customVisible=true;
    if (noresize) return;
    this.liveGrid.setCookie();
    this.liveGrid.sizeDivs();
  },

  hideColumn: function() {
    Rico.writeDebugMsg('hideColumn '+this.liveGrid.tableId);
    this.hideshow(false,false);
  },

  showColumn: function() {
    Rico.writeDebugMsg('showColumn '+this.liveGrid.tableId);
    this.hideshow(true,false);
  },

  chooseColumn: function(e) {
    var elem=Event.element(e);
    this.hideshow(elem.checked,false);
  },

  setImage: function() {
    if ( this.currentSort == Rico.TableColumn.SORT_ASC ) {
       this.imgSort.style.display='';
       this.imgSort.src=Rico.imgDir+this.options.sortAscendImg;
    } else if ( this.currentSort == Rico.TableColumn.SORT_DESC ) {
       this.imgSort.style.display='';
       this.imgSort.src=Rico.imgDir+this.options.sortDescendImg;
    } else {
       this.imgSort.style.display='none';
    }
    if (this.filterType == Rico.TableColumn.USERFILTER) {
       this.imgFilter.style.display='';
       this.imgFilter.title=this.getFilterText();
    } else {
       this.imgFilter.style.display='none';
    }
  },

  canHideShow: function() {
    return this.hideable;
  }

};

Rico.includeLoaded('ricoGridCommon.js');
