/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlet;

import java.io.File;
import utilitaire.ChiffreLettre;
import utilitaireAcade.UtilitaireAcade;

/**
 *
 * @author Murielle
 */
public class UtilitaireFormat {

    public static String generateEntete(String titre, String logo, String width, String height) {
        String htmlStringEntete = "<html><head><title></title></head><body>";
        htmlStringEntete += "<br/>";
        return htmlStringEntete;
    }
    
    public static String generateEntete(String titre, String logo) {
        return generateEntete(titre, logo, "200px", "75px");
    }

    public static String generateBasPage(int nombre, double montant) {
        String htmlStringBasPage = "<div align='left'><h5>Arr�t� le nombre � " + UtilitaireAcade.formaterSansVirgule(nombre) + "</h5>";
        if (montant > 0) {
            htmlStringBasPage += "<h5>Arr�t� le pr�sent �tat � la somme de " + ChiffreLettre.convertRealToString(montant) + " Ariary</h5></div>";
        }
        return htmlStringBasPage;
    }
}
