#!/bin/bash
FICHIER=$1
PASBON_FICHIER=$1_pasbon
PASBON_FICHIER_WWW=$1_pasbon_www
BON_FICHIER=$1_bon
while read line
do
 # test sans www....
 # echo -e "On cherche : $line"
 DIG=$(/usr/bin/dig -t a $line +short)
 # echo -e "Resultat de la commande : $DIG"
 if [ "$DIG" = "IP_du_serveur" ]; then
	#echo -e "$line n existe pas dans le dns!!\n"
	echo -e "$line" >> $BON_FICHIER
 else 
	# echo -e "$line existe dans le dns\n"
	echo -e "$line" >> $PASBON_FICHIER

 fi
 # test www....
 DIGWWW=$(/usr/bin/dig -t cname www.$line +short)
 # echo -e "Resultat de la commande : $DIGWWW"
 if [ "$DIGWWW" = "valeur_champ_cname" ]; then
 	#echo -e "www.$line existe dans le dns!!\n"
	echo -e "www.$line" >> $BON_FICHIER
else 
 	#echo -e "$line n'existe pas dans le dns\n"
	echo -e "www.$line" >> $PASBON_FICHIER_WWW
 fi
done < $FICHIER