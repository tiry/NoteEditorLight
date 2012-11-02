// ********************************************
// Implementation targetting the remote server
//

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

// ********************************************
// Implementation use the LocalStorage
//

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

// ********************************************
// Implementation wrapping remote and local
// choose best suited implemenation depending on network access
//

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
