package utils;

import bean.TypeObjet;

import java.sql.Connection;

public class TypeOuiNon extends TypeObjet {
    public TypeOuiNon() {
        setNomTable("typeouinon");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("TYF","get_seq_typeouinon");
        this.setId(makePK(c));
    }
}
