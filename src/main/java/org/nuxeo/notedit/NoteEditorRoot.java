/*
 * (C) Copyright ${year} Nuxeo SA (http://nuxeo.com/) and contributors.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the GNU Lesser General Public License
 * (LGPL) version 2.1 which accompanies this distribution, and is available at
 * http://www.gnu.org/licenses/lgpl.html
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * Contributors:
 *     <a href="mailto:tdelprat@nuxeo.com">Tiry</a>
 */

package org.nuxeo.notedit;

import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;

import org.apache.commons.lang.StringEscapeUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.nuxeo.ecm.core.api.CoreSession;
import org.nuxeo.ecm.core.api.DocumentModel;
import org.nuxeo.ecm.core.api.DocumentModelList;
import org.nuxeo.ecm.core.api.IdRef;
import org.nuxeo.ecm.webengine.model.WebObject;
import org.nuxeo.ecm.webengine.model.impl.ModuleRoot;
import org.nuxeo.template.api.adapters.TemplateBasedDocument;
import org.nuxeo.template.api.adapters.TemplateSourceDocument;

/**
 * The root entry for the WebEngine module.
 * 
 * @author <a href="mailto:tdelprat@nuxeo.com">Tiry</a>
 */
@Path("/notes")
@Produces("text/html;charset=UTF-8")
@WebObject(type = "NoteEditorRoot")
public class NoteEditorRoot extends ModuleRoot {

    @GET
    @Produces("text/html;charset=UTF-8")
    public Object doGet() {
        return getView("index");
    }

    @GET
    @Path("listNotes")
    @Produces("text/json;charset=UTF-8")
    public String listNotes() throws Exception {

        CoreSession session = getContext().getCoreSession();
        String query = "select * from Note where dc:contributors in ('"
                + getContext().getPrincipal().getName()
                + "')  and ecm:isProxy = 0 and ecm:isCheckedInVersion=0 order by dc:modified desc";

        DocumentModelList notes = session.query(query);

        JSONArray notesDescriptors = new JSONArray();

        for (DocumentModel note : notes) {
            JSONObject noteDesc = new JSONObject();
            noteDesc.put("dc:title", (String) note.getPropertyValue("dc:title"));
            noteDesc.put("dc:description",
                    (String) note.getPropertyValue("dc:description"));
            noteDesc.put("id", note.getId());
            notesDescriptors.put(noteDesc);
        }

        return notesDescriptors.toString();
    }

    @GET
    @Path("getNote/{id}")
    @Produces("text/plain;charset=UTF-8")
    public String getNote(@PathParam("id")
    String id) throws Exception {
        CoreSession session = getContext().getCoreSession();
        DocumentModel note = session.getDocument(new IdRef(id));
        String html = (String) note.getPropertyValue("note:note");
        html = StringEscapeUtils.escapeHtml(html);
        return html;
    }

    @GET
    @Path("getPreviewUrl/{id}")
    @Produces("text/plain;charset=UTF-8")
    public String getNotePreviewUrl(@PathParam("id")
    String id) throws Exception {
        CoreSession session = getContext().getCoreSession();
        DocumentModel note = session.getDocument(new IdRef(id));

        TemplateBasedDocument templateBased = note.getAdapter(TemplateBasedDocument.class);
        if (templateBased != null) {
            for (TemplateSourceDocument source : templateBased.getSourceTemplates()) {
                if (source.getTargetRenditionName().equals("webView")) {
                    return "/nuxeo/nxtemplate/" + note.getRepositoryName()
                            + "/" + note.getId() + "/" + source.getName();
                }
            }
        }
        return "/nuxeo/restAPI/preview/" + note.getRepositoryName() + "/"
                + note.getId() + "/default/?blobPostProcessing=true";
    }

    @POST
    @Path("saveNote/{id}")
    @Produces("text/plain;charset=UTF-8")
    public String saveNote(@PathParam("id")
    String id) throws Exception {
        String noteData = getContext().getForm().getString("note");

        noteData = StringEscapeUtils.unescapeHtml(noteData);

        CoreSession session = getContext().getCoreSession();
        DocumentModel note = session.getDocument(new IdRef(id));

        note.setPropertyValue("note:note", noteData);
        note = session.saveDocument(note);

        return (String) note.getPropertyValue("note:note");
    }

}
