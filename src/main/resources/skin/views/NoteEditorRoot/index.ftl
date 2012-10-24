<html>
<head>

<link rel="stylesheet" href="${skinPath}/css/noteEditor.css" type="text/css" media="screen" charset="utf-8"/>
<script type="text/javascript" src="${skinPath}/script/jquery/jquery.js"></script>

<script>
function getNotesData(cb) {
  var noteList = [];
  noteList.push({'dc:title':'Note 1', "dc:description" : "My Super Note 1", "id" : "1"});
  noteList.push({'dc:title':'Note 2', "dc:description" : "My Super Note 2", "id" : "2"});
  noteList.push({'dc:title':'Note 3', "dc:description" : "My Super Note 3", "id" : "3"});
  cb(noteList);
}

function getNoteBody(id, cb) {
  cb("Note " + id + " \nHGFGGFHGF JHGJHGJHG  JHGJHGJHGg  hgj hgj gjhg jhg jhg jhg jhg ");
}

function autoSize() {
 var w = jQuery(document).width();
 w = w - jQuery("#noteListing").width();
 w = w - jQuery("#notePreview").width();
 w = w - 60;
 jQuery("#noteEdit").width(w);

 jQuery("#notePreviewFrame").width(jQuery("#notePreview").width()-20);
}

function displayNodeForEdit(id) {
  var container = jQuery("#noteEdit #textEdit");
  container.html("... loading ...");
  var cb = function(noteBody) {
    container.html(noteBody);
    var refreshPreview = function() {
      var iframe = jQuery("#notePreviewFrame");
      iframe.attr("src", id);
    }
    jQuery("#previewBtn").click(refreshPreview);
  }
  getNoteBody(id, cb);
}

function refreshNoteList() {
  var container = jQuery("#noteListing");
  container.html("... loading ...");
  var cb = function(noteList) {
    container.html("");

    for (var i = 0 ; i < noteList.length; i++) {
      var noteDiv = jQuery("<div></div>");
      var docId = noteList[i].id;
      noteDiv.attr("id",docId);
      noteDiv.addClass("SmallNote");
      var noteTitle = jQuery("<h3>" + noteList[i]['dc:title'] + "</h3>");
      var noteDesc = jQuery("<em>" + noteList[i]['dc:description'] + "</em>");

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

 <div id="buttonBar">
   <span id="refreshBtn">Refresh</span>
   <span id="saveBtn">Save</span>
   <span id="previewBtn">Preview</span>
 </div>
 <div id="editBar">

  <div id="noteListing">
    <div> Note 1 </div>
    <div> Note 2 </div>
    <div> Note 3 </div>
  </div>

  <div id="noteEdit">
   <pre id="textEdit" contentEditable="true">
# User Manager questions

## Password validation

**Can the system require a minimum password length?**

**Can the system require complex passwords that contain certain types of characters, combinations of alpha-numeric-special characters, prevent password same as user name, etc.?**

You can define the JSF validator for the password widget.

For this you can extend or encapsulate the default JSF validator method :

    UserManagementActions.validatePassword

You can also rely on the UserManager.getUserPasswordPattern() method that can be configured from the extension point.


**When a user changes passwords, can the system force the user to define a new password different from the preceding N passwords?**

By default Nuxeo does not store previous password for each user.

In fact, Nuxeo may even not have any knoledge of the password : this is typically the case for LDAP bindings.

However, if you use the SQL implentation of directory for the Users, you will be able to access to the password.
If you want to store previous password, you will have to contribute a wrapper to the SQL Directory to save Passwords.
(simply *"extend the user.xsd schema"*)

Once you have access to this information you can use a JSF validator.

By default, there is a password validator, you may want to take it as an example.
     </pre>
  </div>

  <div id="notePreview">
   <iframe id="notePreviewFrame" frameborder="0" />
  </div>
 </div>

</div>
</body>
</html>