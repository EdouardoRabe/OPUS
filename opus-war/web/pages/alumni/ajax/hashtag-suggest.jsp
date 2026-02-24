<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%
    // =========================================================
    // Autocomplete hashtag : retourne JSON des promotions et specialites
    // Param GET : q  (fragment tape apres #, ex: "P1", "JAVA")
    // Retourne : [ {tag:"#P19", label:"Promotion P19", type:"PROMOTION", idref:"PRM000001"}, ... ]
    // =========================================================
    response.setHeader("Cache-Control", "no-store");

    UserEJB _u = (UserEJB) session.getAttribute("u");
    if (_u == null) { out.print("[]"); return; }

    String _q = request.getParameter("q");
    if (_q == null || _q.trim().isEmpty()) { out.print("[]"); return; }
    _q = _q.trim().toUpperCase().replaceAll("[^A-Z0-9]", "");
    if (_q.isEmpty()) { out.print("[]"); return; }

    StringBuilder _json = new StringBuilder("[");
    boolean _first = true;

    Connection _c = null;
    try {
        _c = new UtilDB().GetConn();

        // --- Promotions (libelle ex: P19, P23) ---
        PreparedStatement _ps = _c.prepareStatement(
            "SELECT idpromotion, libelle, annee FROM promotion "
            + "WHERE UPPER(REPLACE(libelle,' ','')) LIKE ? ORDER BY annee DESC LIMIT 5");
        _ps.setString(1, "%" + _q + "%");
        ResultSet _rs = _ps.executeQuery();
        while (_rs.next()) {
            String _tag   = "#" + _rs.getString("libelle").toUpperCase().replaceAll("[^A-Z0-9]", "");
            String _label = "Promotion " + _rs.getString("libelle") + " (" + _rs.getInt("annee") + ")";
            String _idref = _rs.getString("idpromotion");
            if (!_first) _json.append(",");
            _first = false;
            _json.append("{\"tag\":\"").append(_tag)
                 .append("\",\"label\":\"").append(_label.replace("\"", "'"))
                 .append("\",\"type\":\"PROMOTION\",\"idref\":\"").append(_idref).append("\"}");
        }
        _rs.close(); _ps.close();

        // --- Specialites ---
        _ps = _c.prepareStatement(
            "SELECT idspecialite, libelle FROM specialite "
            + "WHERE UPPER(REPLACE(libelle,' ','')) LIKE ? ORDER BY libelle LIMIT 5");
        _ps.setString(1, "%" + _q + "%");
        _rs = _ps.executeQuery();
        while (_rs.next()) {
            String _lib = _rs.getString("libelle");
            String _tag = "#" + _lib.toUpperCase().replaceAll("[^A-Z0-9]", "");
            if (_tag.length() > 21) _tag = _tag.substring(0, 21);
            String _idref = _rs.getString("idspecialite");
            if (!_first) _json.append(",");
            _first = false;
            _json.append("{\"tag\":\"").append(_tag)
                 .append("\",\"label\":\"").append(_lib.replace("\"", "'").replace("\\", ""))
                 .append("\",\"type\":\"SPECIALITE\",\"idref\":\"").append(_idref).append("\"}");
        }
        _rs.close(); _ps.close();

        // --- Parcours ---
        _ps = _c.prepareStatement(
            "SELECT idparcours, libelle FROM parcours "
            + "WHERE UPPER(REPLACE(libelle,' ','')) LIKE ? ORDER BY libelle LIMIT 5");
        _ps.setString(1, "%" + _q + "%");
        _rs = _ps.executeQuery();
        while (_rs.next()) {
            String _lib = _rs.getString("libelle");
            String _tag = "#" + _lib.toUpperCase().replaceAll("[^A-Z0-9]", "");
            if (_tag.length() > 21) _tag = _tag.substring(0, 21);
            String _idref = _rs.getString("idparcours");
            if (!_first) _json.append(",");
            _first = false;
            _json.append("{\"tag\":\"").append(_tag)
                 .append("\",\"label\":\"").append(_lib.replace("\"", "'"))
                 .append("\",\"type\":\"PARCOURS\",\"idref\":\"").append(_idref).append("\"}");
        }
        _rs.close(); _ps.close();

    } catch (Exception _ex) {
        _ex.printStackTrace();
    } finally {
        if (_c != null) try { _c.close(); } catch (Exception _x) {}
    }
    _json.append("]");
    out.print(_json.toString());
%>
