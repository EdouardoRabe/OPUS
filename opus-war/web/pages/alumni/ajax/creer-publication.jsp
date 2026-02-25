<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="alumni.Publication" %>
<%@ page import="alumni.Media" %>
<%@ page import="alumni.Identification" %>
<%@ page import="alumni.Notification" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.FileUploadBase" %>
<%
    // POST multipart: Creer publication + upload image dans table media
    // Utilise Commons FileUpload (meme lib que UploadDownloadFileServlet)
    // Utilise ClassMAPTable.construirePK + insertToTableWithHisto (100% APJ)

    String ctx = request.getContextPath();
    String redirectUrl = ctx + "/pages/module.jsp?but=accueil.jsp";

    try {
        UserEJB u = (UserEJB) session.getAttribute("u");
        if (u == null) {
            response.sendRedirect(ctx + "/index.jsp");
            return;
        }
        MapUtilisateur map = u.getUser();
        String userId = String.valueOf(map.getRefuser());

        // --- Parse multipart avec Commons FileUpload ---
        String description = null;
        String idtypepublication = null;
        String identifications = null;
        String visSpec = null, visParc = null, visPromoAnnee = null, visLier = null;
        List mediaItems = new java.util.ArrayList(); // List<FileItem>

        if (ServletFileUpload.isMultipartContent(request)) {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setSizeMax(50 * 1024 * 1024); // 50 Mo max (videos)
            upload.setFileSizeMax(50 * 1024 * 1024); // 50 Mo max par fichier
            List items = null;
            try {
                items = upload.parseRequest(request);
            } catch (FileUploadBase.SizeLimitExceededException sle) {
                long actualMB = sle.getActualSize() / (1024 * 1024);
                long maxMB = sle.getPermittedSize() / (1024 * 1024);
                session.setAttribute("pubErreur",
                    "Le fichier est trop volumineux (" + actualMB + " Mo). La taille maximale autorisee est de " + maxMB + " Mo.");
                response.sendRedirect(redirectUrl);
                return;
            } catch (FileUploadBase.FileSizeLimitExceededException fsle) {
                long maxMB = fsle.getPermittedSize() / (1024 * 1024);
                session.setAttribute("pubErreur",
                    "Un des fichiers depasse la taille maximale autorisee de " + maxMB + " Mo.");
                response.sendRedirect(redirectUrl);
                return;
            }
            for (int i = 0; i < items.size(); i++) {
                FileItem item = (FileItem) items.get(i);
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");
                    if ("description".equals(fieldName)) description = fieldValue;
                    else if ("idtypepublication".equals(fieldName)) idtypepublication = fieldValue;
                    else if ("identifications".equals(fieldName)) identifications = fieldValue;
                    else if ("vis_spec".equals(fieldName)) visSpec = fieldValue;
                    else if ("vis_parc".equals(fieldName)) visParc = fieldValue;
                    else if ("vis_promo_annee".equals(fieldName)) visPromoAnnee = fieldValue;
                    else if ("vis_lier".equals(fieldName)) visLier = fieldValue;
                } else {
                    if (item.getSize() > 0 && item.getName() != null && !item.getName().trim().isEmpty()) {
                        mediaItems.add(item);
                    }
                }
            }
        } else {
            // Fallback formulaire classique (sans fichier)
            description = request.getParameter("description");
            idtypepublication = request.getParameter("idtypepublication");
            visSpec      = request.getParameter("vis_spec");
            visParc      = request.getParameter("vis_parc");
            visPromoAnnee= request.getParameter("vis_promo_annee");
            visLier      = request.getParameter("vis_lier");
        }

        boolean hasMedia = (mediaItems != null && mediaItems.size() > 0);
        if ((description == null || description.trim().isEmpty()) && !hasMedia) {
            session.setAttribute("pubErreur", "Veuillez ajouter un texte ou un fichier media.");
            response.sendRedirect(redirectUrl);
            return;
        }
        if (description == null) description = "";
        if (idtypepublication == null || idtypepublication.trim().isEmpty()) {
            idtypepublication = "TPB000001";
        }

        // --- APJ: Construire l'entite Publication ---
        Publication pub = new Publication();
        pub.setDescritpion(description.trim());
        pub.setDaty(java.sql.Date.valueOf(java.time.LocalDate.now()));
        String heure = java.time.LocalTime.now().toString();
        if (heure.length() > 5) heure = heure.substring(0, 5);
        pub.setHeure(heure);
        pub.setEtat(1);
        pub.setIdtypepublication(idtypepublication.trim());
        pub.setIdutilisateur(map.getRefuser());

        // --- APJ: Creer avec connection manuelle ---
        Connection conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);
        try {
            pub.construirePK(conn);
            pub.insertToTableWithHisto(userId, conn);

            // Sauvegarder chaque media uploade (images et videos)
            for (int mi = 0; mi < mediaItems.size(); mi++) {
                FileItem mediaFile = (FileItem) mediaItems.get(mi);
                // Repertoire de stockage (meme pattern que UploadDownloadFileServlet)
                String basePath = System.getProperty("jboss.server.base.dir")
                    + File.separator + "deployments" + File.separator + "dossier.war"
                    + File.separator + "async" + File.separator + "publications";
                File dir = new File(basePath);
                if (!dir.exists()) dir.mkdirs();

                // Nom unique: timestamp + nom original (nettoye)
                String origName = mediaFile.getName();
                if (origName.contains("\\")) origName = origName.substring(origName.lastIndexOf("\\") + 1);
                if (origName.contains("/")) origName = origName.substring(origName.lastIndexOf("/") + 1);
                String safeName = origName.replaceAll("[^a-zA-Z0-9._-]", "_");
                String fileName = System.currentTimeMillis() + "_" + mi + "_" + safeName;
                File dest = new File(basePath + File.separator + fileName);
                mediaFile.write(dest);

                // Determiner le type de media (Image ou Video)
                String contentType = mediaFile.getContentType();
                String mediaTypeId = "MDT000001"; // Image par defaut
                if (contentType != null && contentType.startsWith("video/")) {
                    mediaTypeId = "MDT000002"; // Video
                }

                // Creer entite Media (APJ)
                Media media = new Media();
                media.setMediaurl("/async/publications/" + fileName);
                media.setIdmediatype(mediaTypeId);
                media.setIdpublication(pub.getIdpublication());
                media.construirePK(conn);
                media.insertToTableWithHisto(userId, conn);
            }

            // --- Identification: taguer des personnes dans la publication ---
            if (identifications != null && !identifications.trim().isEmpty()) {
                String nomSource = Notification.getNomUtilisateur(conn, map.getRefuser());
                String lienPub = "module.jsp?but=accueil.jsp&scrollTo=pub-" + pub.getIdpublication();
                String[] tagIds = identifications.split(",");
                for (int t = 0; t < tagIds.length; t++) {
                    String tid = tagIds[t].trim();
                    if (tid.isEmpty()) continue;
                    try {
                        int targetUser = Integer.parseInt(tid);
                        // Creer l'entite Identification
                        Identification ident = new Identification();
                        ident.setIdutilisateur(targetUser);
                        ident.setIdpublication(pub.getIdpublication());
                        ident.construirePK(conn);
                        ident.insertToTableWithHisto(userId, conn);

                        // Notification
                        if (targetUser != map.getRefuser()) {
                            Notification.creerEtEnvoyer(conn, userId, targetUser,
                                nomSource + " vous a identifie(e) dans une publication",
                                Notification.TYPE_IDENTIFICATION, lienPub);
                        }
                    } catch (NumberFormatException nfe) { /* ignorer */ }
                }
            }

            // --- Hashtags : extraction des #tags de la description ---
            Pattern _hp = Pattern.compile("#([A-Za-z0-9]+)");
            Matcher _hm = _hp.matcher(pub.getDescritpion() != null ? pub.getDescritpion() : "");
            Set _htDone = new HashSet();
            // Charger specialites et promotions pour correspondance
            PreparedStatement _hpst = conn.prepareStatement("SELECT idspecialite, libelle FROM specialite");
            ResultSet _hrst = _hpst.executeQuery();
            String[] _sIds = new String[200]; String[] _sNorms = new String[200]; int _sn = 0;
            while (_hrst.next() && _sn < 200) {
                _sIds[_sn] = _hrst.getString("idspecialite");
                _sNorms[_sn] = _hrst.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]","");
                _sn++;
            }
            _hrst.close(); _hpst.close();
            _hpst = conn.prepareStatement("SELECT idpromotion, libelle FROM promotion");
            _hrst = _hpst.executeQuery();
            String[] _pIds = new String[500]; String[] _pNorms = new String[500]; int _pn = 0;
            while (_hrst.next() && _pn < 500) {
                _pIds[_pn] = _hrst.getString("idpromotion");
                _pNorms[_pn] = _hrst.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]","");
                _pn++;
            }
            _hrst.close(); _hpst.close();
            // Parcours
            _hpst = conn.prepareStatement("SELECT idparcours, libelle FROM parcours");
            _hrst = _hpst.executeQuery();
            String[] _rcIds = new String[200]; String[] _rcNorms = new String[200]; int _rcn = 0;
            while (_hrst.next() && _rcn < 200) {
                _rcIds[_rcn] = _hrst.getString("idparcours");
                _rcNorms[_rcn] = _hrst.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]","");
                _rcn++;
            }
            _hrst.close(); _hpst.close();
            while (_hm.find()) {
                String _tok = _hm.group(1).toUpperCase().replaceAll("[^A-Z0-9]","");
                if (_tok.isEmpty() || _htDone.contains(_tok)) continue;
                _htDone.add(_tok);
                String _tag = "#" + _tok;
                boolean _found = false;
                for (int _xi = 0; _xi < _sn && !_found; _xi++) {
                    if (_sNorms[_xi].equals(_tok) || _sNorms[_xi].startsWith(_tok) || _tok.startsWith(_sNorms[_xi])) {
                        conn.createStatement().execute("INSERT INTO publicationhashtag(idpublication,hashtag,typetag,idref) VALUES('" + pub.getIdpublication() + "','" + _tag + "','SPECIALITE','" + _sIds[_xi] + "') ON CONFLICT DO NOTHING");
                        _found = true;
                    }
                }
                if (!_found) {
                    for (int _xi = 0; _xi < _pn; _xi++) {
                        if (_pNorms[_xi].equals(_tok)) {
                            conn.createStatement().execute("INSERT INTO publicationhashtag(idpublication,hashtag,typetag,idref) VALUES('" + pub.getIdpublication() + "','" + _tag + "','PROMOTION','" + _pIds[_xi] + "') ON CONFLICT DO NOTHING");
                            _found = true;
                            break;
                        }
                    }
                }
                if (!_found) {
                    for (int _xi = 0; _xi < _rcn; _xi++) {
                        if (_rcNorms[_xi].equals(_tok) || _rcNorms[_xi].startsWith(_tok) || _tok.startsWith(_rcNorms[_xi])) {
                            conn.createStatement().execute("INSERT INTO publicationhashtag(idpublication,hashtag,typetag,idref) VALUES('" + pub.getIdpublication() + "','" + _tag + "','PARCOURS','" + _rcIds[_xi] + "') ON CONFLICT DO NOTHING");
                            _found = true;
                            break;
                        }
                    }
                }
            }

            // --- Visibilite : enregistrer les restrictions ---

            // --- Notifications hashtag : notifier tous les utilisateurs concernes ---
            {
                String _nomSource = Notification.getNomUtilisateur(conn, map.getRefuser());
                String _lienPub = "module.jsp?but=accueil.jsp&scrollTo=pub-" + pub.getIdpublication();
                // Collecter les utilisateurs a notifier (Set pour eviter les doublons)
                Set _notifUsers = new HashSet(); // Set<Integer>

                // Requeter les hashtags inseres pour cette publication
                PreparedStatement _nps = conn.prepareStatement(
                    "SELECT typetag, idref FROM publicationhashtag WHERE idpublication = ?");
                _nps.setString(1, pub.getIdpublication());
                ResultSet _nrs = _nps.executeQuery();
                while (_nrs.next()) {
                    String _typetag = _nrs.getString("typetag");
                    String _idref   = _nrs.getString("idref");
                    if ("SPECIALITE".equals(_typetag)) {
                        // Tous les utilisateurs ayant cette specialite
                        PreparedStatement _ups = conn.prepareStatement(
                            "SELECT DISTINCT p.idutilisateur FROM specialiteprofil sp "
                            + "JOIN profil p ON sp.idprofil = p.idprofil "
                            + "WHERE sp.idspecialite = ? AND sp.etat = 1");
                        _ups.setString(1, _idref);
                        ResultSet _urs = _ups.executeQuery();
                        while (_urs.next()) _notifUsers.add(new Integer(_urs.getInt("idutilisateur")));
                        _urs.close(); _ups.close();
                    } else if ("PROMOTION".equals(_typetag)) {
                        // Tous les utilisateurs de cette promotion
                        PreparedStatement _ups = conn.prepareStatement(
                            "SELECT DISTINCT idutilisateur FROM profil WHERE idpromotion = ?");
                        _ups.setString(1, _idref);
                        ResultSet _urs = _ups.executeQuery();
                        while (_urs.next()) _notifUsers.add(new Integer(_urs.getInt("idutilisateur")));
                        _urs.close(); _ups.close();
                    } else if ("PARCOURS".equals(_typetag)) {
                        // Tous les utilisateurs de ce parcours
                        PreparedStatement _ups = conn.prepareStatement(
                            "SELECT DISTINCT idutilisateur FROM profil WHERE idparcours = ?");
                        _ups.setString(1, _idref);
                        ResultSet _urs = _ups.executeQuery();
                        while (_urs.next()) _notifUsers.add(new Integer(_urs.getInt("idutilisateur")));
                        _urs.close(); _ups.close();
                    }
                }
                _nrs.close(); _nps.close();

                // Exclure l'auteur de la publication
                _notifUsers.remove(new Integer(map.getRefuser()));

                // Construire les hashtags pour le message
                PreparedStatement _hps2 = conn.prepareStatement(
                    "SELECT hashtag FROM publicationhashtag WHERE idpublication = ?");
                _hps2.setString(1, pub.getIdpublication());
                ResultSet _hrs2 = _hps2.executeQuery();
                StringBuilder _tagList = new StringBuilder();
                while (_hrs2.next()) {
                    if (_tagList.length() > 0) _tagList.append(" ");
                    _tagList.append(_hrs2.getString("hashtag"));
                }
                _hrs2.close(); _hps2.close();
                String _tagsStr = _tagList.toString();

                // Envoyer les notifications
                java.util.Iterator _it = _notifUsers.iterator();
                while (_it.hasNext()) {
                    int _targetUser = ((Integer) _it.next()).intValue();
                    String _objet = _nomSource + " a publie une offre qui vous concerne " + _tagsStr;
                    Notification.creerEtEnvoyer(conn, userId, _targetUser,
                        _objet, Notification.TYPE_HASHTAG, _lienPub);
                }
            }

            // --- Visibilite (suite) ---
            if (visSpec != null && !visSpec.trim().isEmpty()) {
                String[] _vs = visSpec.split(",");
                for (int _vi = 0; _vi < _vs.length; _vi++) {
                    String _v = _vs[_vi].trim().replaceAll("[^A-Za-z0-9]","");
                    if (!_v.isEmpty()) {
                        conn.createStatement().execute("INSERT INTO publicationvisibilite(idpublication,typecible,idref) VALUES('" + pub.getIdpublication() + "','SPECIALITE','" + _v + "') ON CONFLICT DO NOTHING");
                    }
                }
            }
            if (visParc != null && !visParc.trim().isEmpty()) {
                String[] _vp = visParc.split(",");
                for (int _vi = 0; _vi < _vp.length; _vi++) {
                    String _v = _vp[_vi].trim().replaceAll("[^A-Za-z0-9]","");
                    if (!_v.isEmpty()) {
                        conn.createStatement().execute("INSERT INTO publicationvisibilite(idpublication,typecible,idref) VALUES('" + pub.getIdpublication() + "','PARCOURS','" + _v + "') ON CONFLICT DO NOTHING");
                    }
                }
            }
            if (visPromoAnnee != null && !visPromoAnnee.trim().isEmpty()) {
                String _vpa = visPromoAnnee.trim();
                if (_vpa.matches("\\d{4}[+-]")) {
                    int _anneeRef = Integer.parseInt(_vpa.substring(0, 4));
                    String _dir   = String.valueOf(_vpa.charAt(4));
                    conn.createStatement().execute("INSERT INTO publicationvisibilite(idpublication,typecible,idref,anneeref,anneedirection) VALUES('" + pub.getIdpublication() + "','PROMOTION',NULL," + _anneeRef + ",'" + _dir + "') ON CONFLICT DO NOTHING");
                }
            }
            if ("AND".equalsIgnoreCase(visLier)) {
                conn.createStatement().execute("UPDATE publication SET logique_visibilite='AND' WHERE idpublication='" + pub.getIdpublication() + "'");
            }

            conn.commit();
        } catch (Exception ex) {
            conn.rollback();
            throw ex;
        } finally {
            conn.close();
        }

        session.setAttribute("pubSucces", "Publication creee avec succes !");
        response.sendRedirect(redirectUrl);

    } catch (org.apache.commons.fileupload.FileUploadException fue) {
        // Erreur liee au telechargement du fichier (taille, format, etc.)
        String fueMsg = fue.getMessage();
        if (fueMsg != null && fueMsg.contains("size")) {
            session.setAttribute("pubErreur", "Le fichier est trop volumineux. La taille maximale autorisee est de 50 Mo.");
        } else {
            session.setAttribute("pubErreur", "Erreur lors du telechargement du fichier. Veuillez reessayer.");
        }
        response.sendRedirect(request.getContextPath() + "/pages/module.jsp?but=accueil.jsp");
    } catch (Exception e) {
        e.printStackTrace();
        String errMsg = e.getMessage();
        if (errMsg != null && errMsg.length() > 200) errMsg = errMsg.substring(0, 200);
        session.setAttribute("pubErreur", "Erreur lors de la creation de la publication. Veuillez reessayer.");
        response.sendRedirect(request.getContextPath() + "/pages/module.jsp?but=accueil.jsp");
    }
%>
