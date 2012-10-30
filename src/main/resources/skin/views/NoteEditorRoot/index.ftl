<html>
<head>

<link rel="stylesheet" href="${skinPath}/css/noteEditor.css" type="text/css" media="screen" charset="utf-8"/>

<script type="text/javascript" src="${skinPath}/script/jquery/jquery.js"></script>
<script type="text/javascript" src="/nuxeo/nxthemes-lib/jquery.hotkeys.js"></script>

<script>

function saveNote(id) {
  var noteData = jQuery("#textEdit").html();
  jQuery.post("${This.path}/saveNote/" + id, {'note': noteData}, function(data) {
     //getNotePreviewUrl(id);
     var iframe = jQuery("#notePreviewFrame");
     iframe.attr("src", iframe.attr("src"));
     });
}

function getNotesData(cb) {
  jQuery.get("${This.path}/listNotes", function(data) {
       cb(data);
  });
}

function getNoteBody(id, cb) {
  jQuery.get("${This.path}/getNote/" + id, function(data) {
    cb(data);
    // bind button
    jQuery("#saveBtn").unbind("click");
    jQuery("#saveBtn").click( function() { saveNote(id);return false;});
    // bind short key
    jQuery(document).bind('keydown', 'Ctrl+S', function() { saveNote(id);return false;});
    });
}

function getNotePreviewUrl(id) {
  jQuery.get("${This.path}/getPreviewUrl/" + id, function(url) {
     var refreshPreview = function() {
      var iframe = jQuery("#notePreviewFrame");
      iframe.attr("src", url);
    }
    jQuery("#previewBtn").click(refreshPreview);
    jQuery(document).bind('keydown', 'Ctrl+p', function() { refreshPreview();return false;});
    refreshPreview();
    });
}

function autoSize() {
 var w = jQuery(document).width();
 w = w - jQuery("#noteListing").width();
 w = w - jQuery("#noteEdit").width();
 w = w - 80;
 jQuery("#notePreview").width(w);

 jQuery("#notePreviewFrame").width(jQuery("#notePreview").width()-20);
 jQuery("#notePreviewFrame").height(jQuery(document).height()-100);
}

function fitSize(format) {
  autoSize();
  var w = jQuery("#notePreviewFrame").width();
  if (format=='letter') {
    jQuery("#notePreviewFrame").height(1.4*w);
  }
  else if (format=='landscape') {
    jQuery("#notePreviewFrame").height(w*0.66);
  }
}

function displayNodeForEdit(id) {
  var container = jQuery("#noteEdit #textEdit");
  container.html("... loading ...");
  var cb = function(noteBody) {
    container.html(noteBody);
    getNotePreviewUrl(id);
  }
  getNoteBody(id, cb);
}

function refreshNoteList() {
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
        return function() { displayNodeForEdit(id)}; }(docId);
      noteDiv.click(clickCB);
    }
   }
  getNotesData(cb);
}

jQuery(document).ready(function() {
  refreshNoteList();
  autoSize();
});

</script>
</head>
<body>

<div id="topContainer">

 <div class="buttonBar">
   <span id="refreshBtn">Refresh</span>
   <span id="saveBtn">Save</span>
   <span id="previewBtn">Preview</span>
 </div>
 <div id="editBar">

  <div id="noteListing">

  </div>

  <div id="noteEdit">
   <pre id="textEdit" contentEditable="true">
   </pre>
  </div>

  <div id="notePreview">
   <div class="buttonBar">
     <span class="format" onclick="fitSize('letter')">Letter format</span>
     <span class="format" onclick="fitSize('landscape')">Landscape</span>
   </div>

   <iframe id="notePreviewFrame" frameborder="0" />
  </div>
 </div>

</div>
</body>
</html>