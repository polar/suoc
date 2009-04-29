/**
 *  Sample 'CustomDraggable' object which extends the Rico.Draggable to
 *  override the behaviors associated with a draggable object...
 *
 **/
var CustomDraggable = Class.create();

CustomDraggable.prototype = Object.extend(new Rico.Draggable(), {

   log: function(str) {
      new Insertion.Bottom( $('logger'), "<span class='logMsg'>" + str + "</span><br/>" );
      $('logger').scrollTop = $('logger').lastChild.offsetTop;

   },

   select: function() {
      this.selected = true;
      var el = this.htmlElement;

      // show the item selected.....
      el.style.color           = "#ffffff";
      el.style.backgroundColor = "#08246b";
      el.style.border          = "1px solid blue";
   },

   deselect: function() {
      this.selected = false;
      var el = this.htmlElement;
      el.style.color           = "#2b2b2b";
      el.style.backgroundColor = "transparent";
      el.style.border = "1px solid #ffffee";
   },

   startDrag: function() {
      var el = this.htmlElement;
      this.log("startDrag: [" + this.name +"]");
   },

   cancelDrag: function() {
      var el = this.htmlElement;
      this.log("cancelDrag: [" + this.name +"]");
   },

   endDrag: function() {
      var el = this.htmlElement;
      this.log("endDrag: [" + this.name +"]");
      if ( CustomDraggable.removeOnDrop )
         this.htmlElement.style.display = 'none';
   },

   toString: function() {
      return this.name;
   }

} );
