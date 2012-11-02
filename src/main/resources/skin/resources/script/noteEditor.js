//******************************
// UI Controller for Note Editor

function NoteEditor(url, offline) {

  this.url = url;
  this.offline = offline;
  editor = this;

  this.saveNote = function (id) {
    var noteData = jQuery("#textEdit").html();
    this.store.storeNote(id, noteData, function(data) {
       var iframe = jQuery("#notePreviewFrame");
       iframe.attr("src", iframe.attr("src"));
       });
  };

  this.listNotes = function (cb) {
    this.store.listNotes(function(data) {
         cb(data);
    });
  };

  this.getNoteBody = function (id, cb) {
    this.store.readNote(id,function(data) {
      cb(data);
      // bind button
      jQuery("#saveBtn").unbind("click");
      jQuery("#saveBtn").click( function() { editor.saveNote(id);return false;});
      // bind short key
      jQuery(document).bind('keydown', 'Ctrl+S', function() { editor.saveNote(id);return false;});
      });
  };

  this.getNotePreviewUrl = function (id) {
    this.store.getPreviewUrl(id,function(url) {
       var refreshPreview = function() {
        var iframe = jQuery("#notePreviewFrame");
        iframe.attr("src", url);
      }
      jQuery("#previewBtn").click(refreshPreview);
      jQuery(document).bind('keydown', 'Ctrl+p', function() {refreshPreview();return false;});
      refreshPreview();
      });
  };

  this.displayNodeForEdit = function (id) {
    var container = jQuery("#noteEdit #textEdit");
    container.html("... loading ...");
    jQuery(document).unbind('keydown');
    var cb = function(noteBody) {
      container.html(noteBody);
      editor.getNotePreviewUrl(id);
    }
    editor.getNoteBody(id, cb);
  };

  this.onNetworkChange = function (offline) {
    var offlineBtn = jQuery("#offlineBtn");
    offlineBtn.unbind('click');
    if (offline) {
      offlineBtn.html("You are currently offline / Click to go online");
      offlineBtn.click(function() {editor.store.setOffline(false)});
    } else {
      offlineBtn.html("You are currently online / Click to go offline");
      offlineBtn.click(function() {editor.store.setOffline(true)})	;
    }
  };


  this.refreshNoteList = function () {
    var container = jQuery("#noteListing");
    container.html("... loading ...");
    var cb = function(noteList) {
      container.html("");
      for (var i = 0 ; i < noteList.length; i++) {
        var noteDiv = jQuery("<div class='noteItem'></div>");
        var docId = noteList[i].id;
        noteDiv.attr("id",docId);
        noteDiv.addClass("SmallNote");
        var noteTitle = jQuery("<div class='noteTitle'>" + noteList[i]['dc:title'] + "</div>");
        var noteDesc = jQuery("<div class='noteDescription'>" + noteList[i]['dc:description'] + "</div>");
        noteDiv.append(noteTitle);
        noteDiv.append(noteDesc);
        container.append(noteDiv);
        // create closure !
        var clickCB = function(id) {
          return function() { editor.displayNodeForEdit(id)}; }(docId);
        noteDiv.click(clickCB);
      }
     }
    editor.listNotes(cb);
  };

  this.init = function() {
    this.store = new RepositoryWrapper(this.url, this.offline, this.onNetworkChange);
    this.currentNoteId=null;
    this.refreshNoteList();
    this.autoSize();
    jQuery("#letterFormatBtn").click(function() {editor.fitSize('letter')});
    jQuery("#landscapeFormatBtn").click(function() {editor.fitSize('landscape')});
  };

  // ******************************
  // pure UI methods

  this.autoSize = function () {
   var w = jQuery(document).width();
   w = w - jQuery("#noteListing").width();
   w = w - jQuery("#noteEdit").width();
   w = w - 80;
   jQuery("#notePreview").width(w);
   jQuery("#notePreviewFrame").width(jQuery("#notePreview").width()-20);
   jQuery("#notePreviewFrame").height(jQuery(document).height()-100);
  };

  this.fitSize = function (format) {
    this.autoSize();
    var w = jQuery("#notePreviewFrame").width();
    if (format=='letter') {
      jQuery("#notePreviewFrame").height(1.4*w);
    }
    else if (format=='landscape') {
      jQuery("#notePreviewFrame").height(w*0.66);
    }
  }
}
