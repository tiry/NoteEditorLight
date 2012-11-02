<html>
<head>

<link rel="stylesheet" href="${skinPath}/css/noteEditor.css" type="text/css" media="screen" charset="utf-8"/>

<script type="text/javascript" src="${skinPath}/script/jquery/jquery.js"></script>
<script type="text/javascript" src="/nuxeo/nxthemes-lib/jquery.hotkeys.js"></script>
<script type="text/javascript" src="${skinPath}/script/noteManager.js"></script>
<script type="text/javascript" src="${skinPath}/script/noteEditor.js"></script>

<script>
jQuery(document).ready(function() {
  var editor = new NoteEditor("${This.path}", true);
  editor.init();
});

</script>
</head>
<body>

<div id="topContainer">

 <div class="buttonBar">
   <span id="refreshBtn">Refresh</span>
   <span id="saveBtn">Save</span>
   <span id="previewBtn">Preview</span>
   <span id="offlineBtn"></span>
   <span id="offlineStatus" style="float:right"></span>
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
     <span class="format" id="letterFormatBtn">Letter format</span>
     <span class="format" id="landscapeFormatBtn">Landscape format</span>
   </div>
   <iframe id="notePreviewFrame" frameborder="0" />
  </div>
 </div>

</div>
</body>
</html>