<html>
<head>

<link rel="stylesheet" href="${skinPath}/css/noteEditor.css" type="text/css" media="screen" charset="utf-8"/>

<script type="text/javascript" src="${skinPath}/script/jquery/jquery.js"></script>
<script type="text/javascript" src="/nuxeo/nxthemes-lib/jquery.hotkeys.js"></script>

<script>

function RemoteRepository(baseUrl) {

  this.baseUrl = baseUrl;

  this.storeNote = function(id,noteData,cb) {
    console.log("save Note " + id);
    jQuery.post( this.baseUrl + "/saveNote/" + id, {'note': noteData}, function(data) {
     cb(data);
     });
  };

  this.readNote = function(id,cb) {
    jQuery.get(this.baseUrl + "/getNote/" + id, function(data) {
      cb(data);
      });
  };

  this.listNotes = function(cb) {
    jQuery.get(this.baseUrl + "/listNotes", function(data) {
       cb(data);
    });
  };

  this.getPreviewUrl = function(id,cb) {
    jQuery.get(this.baseUrl + "/getPreviewUrl/" + id, cb);
  };

}

function LocalRepository() {

  this.storeNote = function(id,noteData,cb) {
    localStorage.setItem(id,noteData);
    if (cb!=null) {
     cb(noteData);
    }
  };

  this.readNote = function(id,cb) {
    var noteData = localStorage.getItem(id);
    if (cb!=null) {
      cb(noteData);
    }
  };

  this.listNotes = function(cb) {
    var jsonStr = localStorage.getItem("notesList");
    if (jsonStr!=null) {
      cb(JSON.parse(jsonStr));
    }
  };

  this.saveList = function(data) {
    localStorage.setItem("notesList", JSON.stringify(data));
  };

  this.getPreviewUrl = function(id,cb) {
  };
}

function RepositoryWrapper(baseUrl, offline, onchange) {

  this.remote = new RemoteRepository(baseUrl);
  this.local = new LocalRepository();
  this.offline = offline;
  this.onchange = onchange;

  if(this.onchange) {
    this.onchange(this.offline);
  }

  this.storeNote = function(id,noteData,cb) {
    this.local.storeNote(id, noteData,cb);
    if (!this.offline) {
      this.remote.storeNote(id,noteData,cb);
    } else {
    }
  };

  this.readNote = function(id,cb) {
    if (!this.offline) {
      var local = this.local;
      this.remote.readNote(id, function(data) {
        local.storeNote(id, data, null);
        cb(data);
      });
    } else {
      this.local.readNote(id, cb);
    }
  };

  this.setOffline = function(newOffline) {
    if(newOffline == this.offline) {
      return;
    }
    if (newOffline) {
      this.putOffline();
    } else {
      this.putOnline();
    }
    if (this.onchange!=null) {
      this.onchange(this.offline);
    }
  };

  this.putOnline = function() {
    this.offline=false;
  };

  this.putOffline = function() {
    this.offline=true;
  };

  this.listNotes = function(cb) {
    if (!this.offline) {
      var local = this.local;
      this.remote.listNotes(function(data) {
        local.saveList(data);
        cb(data);
        });
    } else {
      this.local.listNotes(cb);
    }
  };

  this.getPreviewUrl = function(id,cb) {
    if (!this.offline) {
      this.remote.getPreviewUrl(id,cb);
    }
  };
}


function getStore() {
  return store;
}

function saveNote(id) {
  var noteData = jQuery("#textEdit").html();
  getStore().storeNote(id, noteData, function(data) {
     //getNotePreviewUrl(id);
     var iframe = jQuery("#notePreviewFrame");
     iframe.attr("src", iframe.attr("src"));
     });
}

function listNotes(cb) {
  getStore().listNotes(function(data) {
       cb(data);
  });
}

function getNoteBody(id, cb) {

  getStore().readNote(id,function(data) {
    cb(data);
    // bind button
    jQuery("#saveBtn").unbind("click");
    jQuery("#saveBtn").click( function() { saveNote(id);return false;});
    // bind short key
    jQuery(document).bind('keydown', 'Ctrl+S', function() { saveNote(id);return false;});
    });
 }

function getNotePreviewUrl(id) {
  getStore().getPreviewUrl(id,function(url) {
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
  jQuery(document).unbind('keydown');
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
  listNotes(cb);
}

var store;

function onNetworkChange(offline) {
  var offlineBtn = jQuery("#offlineBtn");
  offlineBtn.unbind('click');
  if (offline) {
    offlineBtn.html("You are currently offline / Click to go online");
    offlineBtn.click(function() {getStore().setOffline(false)});
  } else {
    offlineBtn.html("You are currently online / Click to go offline");
    offlineBtn.click(function() {getStore().setOffline(true)})	;
  }
}

jQuery(document).ready(function() {
  //var store = new RemoteRepository("${This.path}");
  store = new RepositoryWrapper("${This.path}", true, onNetworkChange);
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
   <span id="offlineBtn"></span>
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