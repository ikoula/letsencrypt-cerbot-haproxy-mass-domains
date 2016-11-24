for fichier_domaine in *_bon
# Parcours du fichier
do
 # creation de la lignes de domaines
 LIGNE_DOMAINE=""
 while read line
  do
  if [ -z "$LIGNE_DOMAINE" ]; then 
   LIGNE_DOMAINE="$line"
   NOM_PREMIER="$line"
  else
   LIGNE_DOMAINE="$LIGNE_DOMAINE, $line"
  fi
 done < $fichier_domaine
 NOM_FICHIER_LE=letsencrypt_$NOM_PREMIER.ini
 cp letsencrypt.ini $NOM_FICHIER_LE
 echo "domains = $LIGNE_DOMAINE" >> $NOM_FICHIER_LE
done
