<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="alumni.Publicationreaction" %>
<%@ page import="alumni.Reactiontype" %>
<%@ page import="alumni.ProfilLib" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%!
    private static String ejsonEsc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
    private static String emojiFor(String lib) {
        if (lib == null) return "\uD83D\uDC4D";
        String l = lib.toLowerCase();
        if (l.contains("adore") || l.contains("love"))         return "\u2764\uFE0F";
        if (l.contains("haha") || l.contains("humour"))        return "\uD83D\uDE02";
        if (l.contains("surprise") || l.contains("wow"))       return "\uD83D\uDE2E";
        if (l.contains("triste") || l.contains("sad"))         return "\uD83D\uDE22";
        if (l.contains("grrr") || l.contains("ang"))           return "\uD83D\uDE20";
        return "\uD83D\uDC4D";
    }
%>
<%
    try {
        UserEJB uDR = (UserEJB) session.getAttribute("u");
        if (uDR == null) { out.print("{\"success\":false,\"error\":\"Non connecte\"}"); return; }

        String _idpub = request.getParameter("idpublication");
        if (_idpub == null || _idpub.trim().isEmpty()) {
            out.print("{\"success\":false,\"error\":\"Parametre manquant\"}"); return;
        }
        _idpub = _idpub.replaceAll("[^A-Za-z0-9]", "");
        String ctx = request.getContextPath();
        int _myId = uDR.getUser().getRefuser();

        Connection _conn = null;
        try {
            _conn = new UtilDB().GetConn();

            // Types de reaction
            Reactiontype[] _rTypes = (Reactiontype[]) CGenUtil.rechercher(
                    new Reactiontype(), null, null, _conn, " order by idreactiontype");
            if (_rTypes == null) _rTypes = new Reactiontype[0];

            // Reactions de la publication
            Publicationreaction[] _reacts = (Publicationreaction[]) CGenUtil.rechercher(
                    new Publicationreaction(), null, null, _conn, " and idpublication='" + _idpub + "'");
            if (_reacts == null) _reacts = new Publicationreaction[0];

            // Map idutilisateur -> ProfilLib
            ProfilLib[] _profs = (ProfilLib[]) CGenUtil.rechercher(new ProfilLib(), null, null, _conn, "");
            Map _profMap = new HashMap();
            if (_profs != null) {
                for (int _i = 0; _i < _profs.length; _i++) {
                    _profMap.put(new Integer(_profs[_i].getIdutilisateur()), _profs[_i]);
                }
            }

            // Construire le JSON
            StringBuilder _sb = new StringBuilder();
            _sb.append("{\"success\":true,\"myId\":").append(_myId).append(",\"total\":").append(_reacts.length).append(",\"reactions\":[");
            boolean _ftType = true;
            for (int _rt = 0; _rt < _rTypes.length; _rt++) {
                String _rtId  = _rTypes[_rt].getIdreactiontype();
                String _rtLib = _rTypes[_rt].getLibelle();
                String _emoji = emojiFor(_rtLib);

                // Users ayant fait cette reaction
                java.util.List _users = new java.util.ArrayList();
                for (int _r = 0; _r < _reacts.length; _r++) {
                    if (_rtId.equals(_reacts[_r].getIdreactiontype())) {
                        ProfilLib _p = (ProfilLib) _profMap.get(new Integer(_reacts[_r].getIdutilisateur()));
                        if (_p != null) _users.add(_p);
                    }
                }
                if (_users.isEmpty()) continue;

                if (!_ftType) _sb.append(",");
                _ftType = false;
                _sb.append("{\"id\":\"").append(ejsonEsc(_rtId)).append("\"")
                   .append(",\"libelle\":\"").append(ejsonEsc(_rtLib)).append("\"")
                   .append(",\"emoji\":\"").append(ejsonEsc(_emoji)).append("\"")
                   .append(",\"count\":").append(_users.size())
                   .append(",\"users\":[");
                for (int _u = 0; _u < _users.size(); _u++) {
                    ProfilLib _p = (ProfilLib) _users.get(_u);
                    if (_u > 0) _sb.append(",");
                    String _nom   = ejsonEsc(_p.getNom() + " " + _p.getPrenom());
                    String _photo = (_p.getPhotoProfil() != null && !_p.getPhotoProfil().trim().isEmpty())
                            ? ejsonEsc(ctx + "/" + _p.getPhotoProfil().trim()) : "";
                    String _idprofil = _p.getIdprofil() != null ? ejsonEsc(_p.getIdprofil()) : "";
                    _sb.append("{\"idutilisateur\":").append(_p.getIdutilisateur())
                       .append(",\"nom\":\"").append(_nom).append("\"")
                       .append(",\"photo\":\"").append(_photo).append("\"")
                       .append(",\"idprofil\":\"").append(_idprofil).append("\"}");
                }
                _sb.append("]}");
            }
            _sb.append("]}");
            out.print(_sb.toString());
        } finally {
            if (_conn != null) try { _conn.close(); } catch (Exception _e) {}
        }
    } catch (Exception _ex) {
        _ex.printStackTrace();
        out.print("{\"success\":false,\"error\":\"" + ejsonEsc(_ex.getMessage()) + "\"}");
    }
%>
