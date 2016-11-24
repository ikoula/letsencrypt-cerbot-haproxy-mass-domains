#!/bin/bash
NOMBRE_DOMAINES=50
if [ -f alpha.txt ]; then
	rm -f alpha.txt
    rm -f domaines*
    rm -f letsencrypt_*
fi
sort $1 > alpha.txt
split -d -l $NOMBRE_DOMAINES alpha.txt domaines
#dos2unix.exe domaines*
for fichier_domaine in domaines*
 do
 echo "traitement de $fichier_domaine" 
 ./testdig.sh $fichier_domaine
 done
