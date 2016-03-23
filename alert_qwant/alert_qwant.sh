#!/bin/bash

#Initialisation des variables
install="curl" #Logiciel à installer nécéssaire pour le fonctionnement du script
indice="news-content" #Repère pour la div ou se trouve les résultats de la recherche
verif_installation=$(dpkg -s $install | grep Status) #Vérification que curl est installé
nbline=0
jour_heure=$(date +%d/%m/%y' à '%kh%M)
cpt=0

#Lecture des options
if [ $# -ge 1 ]
then
	while [ $cpt -le $# ] #Boucle de lecture des options
	do
	((cpt++))
		#Option de mise à jour
        	if [ $1 = "--upgrade" ]
        	then
                	diff_maj=$(curl -s https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/sig.md5 | diff /srv/scripts/sig.md5 -)
			if [ "$diff_maj" != "" ]
			then
				wget -q -P /tmp/ https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/alert_qwant.sh
				wget -q -P /tmp/ https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/sig.md5
				rm /srv/scripts/alert_qwant.sh /srv/scripts/sig.md5
				mv /tmp/alert_qwant.sh /srv/scripts/alert_qwant.sh
				mv /tmp/sig.md5 /srv/scripts/sig.md5
				echo "Une mise à jour est disponible, elle à été téléchargé, alert_qwant est à jour " >> /srv/scripts/alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo "Une mise à jour est disponible, elle à été téléchargé, alert_qwant est à jour "; fi
				echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo "Fin de l'éxécution du programme"; fi
				echo " " >> /srv/scripts/alert_qwant.log		
				exit 0
			else
				echo "Aucune mise à jour disponible" >> /srv/scripts/alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo "Aucune mise à jour disponible"; fi
                                echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
                                if [ "$verbose" = "Activé" ]; then echo "Fin de l'éxécution du programme"; fi
                                echo " " >> /srv/scripts/alert_qwant.log
                                exit 0
			fi
        	elif [ $1 = "--dmail" ]
		then
			rm /srv/scripts/BDD_veille.mail
			echo "La base de donné de liens envoyés par mail à été vidé" >> /srv/scripts/alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo "La base de donné de liens envoyés par mail à été vidé"; fi
			echo 'Historique des liens envoyé par mail' >> /srv/scripts/BDD_veille.mail
		elif [ $1 = "--dlog" ] 
		then
			rm /srv/scripts/alert_qwant.log
			echo "Fichier log de alert_qwant" >> /srv/scripts/alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo "Les logs ont été vidés"; fi
		elif [ $1 = "-v" ]
		then
			verbose="Activé"
			if [ "$verbose" = "Activé" ]; then echo "Option verbose activé"; fi
                        echo "Option verbose activé" >> /srv/scripts/alert_qwant.log
		elif [ $1 = "--mail" ]
		then
			mail="Activé"
			echo "Option envoi de mail sans taille limite activé" >> /srv/scripts/alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo "Option envoi de mail sans taille limite activé"; fi
		else
                	if [ "$verbose" = "Activé" ]; then echo "Erreur : Option non reconnue"; fi
			echo 'Erreur : Option non reconnue' >> /srv/scripts/alert_qwant.log
        	fi
		shift
	done
fi

#Ecrire dans le log l'heure du lancement
echo "Lancement alert_qwant.sh le $jour_heure :" >> /srv/scripts/alert_qwant.log
if [ "$verbose" = "Activé" ]; then echo "Lancement alert_qwant.sh le $jour_heure :"; fi

#Vérification de l'emplacement du script
ou_suis_je=$(pwd)"/alert_qwant.sh"
if [ ! -d "/srv/scripts/" ] #Vérification de l'existance du dossier scripts
then
        mkdir /srv/scripts
        echo "Le dossier scripts à été créé dans /srv/" >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Le dossier scripts à été créé dans /srv/"; fi
fi

if [ ! -f "/srv/scripts/alert_qwant.sh" ] #Vérification de l'existance du script alert_qwant.sh
then
        cp $ou_suis_je /srv/scripts/
        echo 'Erreur : Le script est mal placé. Il a été copier dans le repertoire /srv/scripts/'
        echo 'Erreur : Le script est mal placé. Il a été copier dans le repertoire /srv/scripts/' >> /srv/scripts/alert_qwant.log
        echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Fin de l'éxécution du programme"; fi
        exit 0
fi

#Vérification de la présence des fichiers systèmes
if [ ! -f "/srv/scripts/alert_qwant.conf" ] # Test de la présence du fichier de configuration
then
        echo "###Fichier de configuration pour alert_qwant###" >> /srv/scripts/alert_qwant.conf
        echo "" >> /srv/scripts/alert_qwant.conf
        echo "Fréquence de lancement de alert_qwant par jour (Divisé par le nombre d'heure par jour doit être entier) : 12" >> /srv/scripts/alert_qwant.conf
        echo "Nombre de liens récupéré par mot clef : 4" >> /srv/scripts/alert_qwant.conf
        echo "Nombre de liens envoyé par mail : 50" >> /srv/scripts/alert_qwant.conf
        echo "Une fois les liens récupérés, les envoyers par mail (tapez : mail) ou les envoyers dans un fichier (tapez : le/lien/absolu/du/fichier) :" >> /srv/scripts/alert_qwant.conf
        echo "Adresse mail : adresse@mail.eu" >> /srv/scripts/alert_qwant.conf
	echo "Chemin absolu du fichier :" >> /srv/scripts/alert_qwant.conf
	echo "Envoyer les liens par mail (érivez mail) ou dans un fichier (écrivez fichier) :" >> /srv/scripts/alert_qwant.conf
        echo "Création du fichier de configuration, alert_qwant.conf dans /srv/scripts/, avec les paramètres de bases. Pensez à changer l'adresse mail." >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Création du fichier de configuration, alert_qwant.conf dans /srv/scripts/, avec les paramètres de bases. Pensez à changer l'adresse mail."; fi
fi

if [ ! -f "/srv/scripts/Mots_clefs.list" ] # Test de la présence de la liste des mots clefs 
then
        echo 'Qwant' >> /srv/scripts/Mots_clefs.list
        echo 'Erreur : Votre liste de mots clefs est vide et a été créé automatiquement. Pensez à éditer le fichier Mots_clefs.list' >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Erreur : Votre liste de mots clefs est vide et a été créé automatiquement. Pensez à éditer le fichier Mots_clefs.list"; fi
elif [ ! -f "/srv/scripts/BDD_veille.mail" ] # Test de la présence de la BDD des mails envoyés
then
        echo 'Historique des liens envoyé par mail' >> /srv/scripts/BDD_veille.mail
        echo "Le fichier de base de donnée de liens envoyé par mail a été créé" >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Le fichier de base de donnée de liens envoyé par mail a été créé"; fi
fi

#Vérification de l'existance du man alert_qwant
if [ ! -f "/usr/share/man/man1/alert_qwant.1.gz" ]
then
	#Création du man alert_qwant
	echo 'Man de alert_qwant' >> /usr/share/man/man1/alert_qwant.1
	echo "alert_qwant est un script Bash d'automatisation de la veille à l'aide de la fonctionnalité actu du moteur de recherche Qwant" >> /usr/share/man/man1/alert_qwant.1
	gzip /usr/share/man/man1/alert_qwant.1
	rm  /usr/share/man/man1/alert_qwant.1
	echo 'Création de la page de manuel. Vous pouvez y accéder avec la commande man alert_qwant' >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Création de la page de manuel. Vous pouvez y accéder avec la commande man alert_qwant"; fi
fi

#Suppression des espaces dans le fichier contenant les mots clefs
cat /srv/scripts/Mots_clefs.list | sed s/' '/'+'/g > /srv/scripts/Mots_clefs.tmp

#Création de BDD_veille.data pour permettre la comparaison entre les liens des différents mots clefs
if [ ! -f "/srv/scripts/BDD_veille.data" ]
then
	touch /srv/scripts/BDD_veille.data
fi

#Lecture du fichier de configuration
freq=$(cat /srv/scripts/alert_qwant.conf | grep -o Fréquence.* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
nbliens_mots_clefs=$(cat /srv/scripts/alert_qwant.conf | grep -o "Nombre de liens récupéré".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
nbliens_par_mail=$(cat /srv/scripts/alert_qwant.conf | grep -o "Nombre de liens envoyé".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
choix_mail_ou_fichier=$(cat /srv/scripts/alert_qwant.conf | grep -o "Envoyer".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
adresse_mail=$(cat /srv/scripts/alert_qwant.conf | grep -o "Adresse".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
freq_cron=$((24/$freq))
chemin_fichier=$(cat /srv/scripts/alert_qwant.conf | grep -o "Chemin".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)

#Mise en place du lancement automatique avec cron
crontab -l > /tmp/crontab_tmp.tmp
lancement_auto=$(grep alert_qwant /tmp/crontab_tmp.tmp)
if [ "$lancement_auto" != "0 */$freq_cron * * * bash /srv/scripts/alert_qwant.sh >> /srv/scripts/cron.log 2>&1" ]
then
	sed '/alert_qwant/d' /tmp/crontab_tmp.tmp > /tmp/crontab_tmp_tmp.tmp
	cat /tmp/crontab_tmp_tmp.tmp > /tmp/crontab_tmp.tmp
	echo "0 */$freq_cron * * * bash /srv/scripts/alert_qwant.sh >> /srv/scripts/cron.log 2>&1" >> /tmp/crontab_tmp.tmp
	crontab /tmp/crontab_tmp.tmp
	rm -f /tmp/crontab_tmp.tmp /tmp/crontab_tmp_tmp.tmp
	echo "Ajout d'une règle dans crontab" >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Ajout d'une règle dans crontab"; fi
else
	rm /tmp/crontab_tmp.tmp
fi

if [ "$verif_installation" = "Status: install ok installed" ] # Test de l'installation de curl
then
	#Boucle pour rechercher les liens pour chaque mot clef
	cat /srv/scripts/Mots_clefs.tmp | while read line #Lecture ligne par ligne
	do
        	mots_clefs=$line
		#Inscription de l'entête
		if [ ! -f "/srv/scripts/$mots_clefs.data" ]
		then
			 echo "<br><br><b>$mots_clefs<b><br>" | sed s/'+'/' '/g > /srv/scripts/$mots_clefs.data
		fi

        	moteur="https://lite.qwant.com/?lang=fr_fr&q=$mots_clefs&t=news&l=fr" #Lien du moteur de recherche
		curl -s $moteur | grep -A 3 $indice | grep -o '<a href'.*'</a>'$ | head -n $nbliens_mots_clefs | sed s/'\<\/a\>'/'\<\/a\>\n'/g >> /srv/scripts/$mots_clefs.tmp #Récupération des liens sur le moteur de recherche

		#Vérification des doublons
		cat /srv/scripts/$mots_clefs.tmp | sort > /srv/scripts/tmp
		cat /srv/scripts/BDD_veille.mail | sort >> /srv/scripts/tmp
		cat /srv/scripts/BDD_veille.data | sort >> /srv/scripts/tmp
		cat /srv/scripts/tmp | sort | uniq -d > /srv/scripts/tmp.tmp
	        rm /srv/scripts/tmp
 		cat /srv/scripts/$mots_clefs.tmp >> /srv/scripts/tmp.tmp
        	cat /srv/scripts/tmp.tmp | sort | uniq -u > /srv/scripts/$mots_clefs.tmp
	        rm /srv/scripts/tmp.tmp
		cat /srv/scripts/$mots_clefs.tmp | sed '/^$/d' >> /srv/scripts/$mots_clefs.data
		cat /srv/scripts/$mots_clefs.tmp | sed '/^$/d' >> /srv/scripts/BDD_veille.data
		rm /srv/scripts/$mots_clefs.tmp
	done
else
	apt-get install $install #installation de curl
	echo "Le logiciel $install a été installé" >> /srv/scripts/alert_qwant.log
	echo "Fin de l'éxécution du programme avec une erreur critique, veuillez relancer" >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Le logiciel $install a été installé"; fi
	if [ "$verbose" = "Activé" ]; then echo "Fin de l'éxécution du programme avec une erreur critique, veuillez relancer"; fi
fi

#Boucle pour le comptage des lignes du fichier de liens
cat /srv/scripts/BDD_veille.data | while read line
do
       	((nbline++))
	echo "$nbline" > /srv/scripts/nbline.tmp
done

#Test de la présence du fichier nbline.tmp
if [ -f "/srv/scripts/nbline.tmp" ] 
then
	nbline=$(cat /srv/scripts/nbline.tmp)
fi

#Test pour le nombre maximum de lien
if [ $nbline -ge $nbliens_par_mail ] || [ "$mail" = "Activé" ]
then
	#Mise en forme du MEF
	echo '<img src="https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/QwantandBash.png" width="250" align="left" alt="Logo" /><br/><br/><br/>' >> /srv/scripts/BDD_veille.mef
	echo "<br><font color="grey" align="right" >Newsletter du $jour_heure</font><br/>" >> /srv/scripts/BDD_veille.mef
	
	cat /srv/scripts/BDD_veille.data | sort >> /srv/scripts/BDD_veille.mail
	cat /srv/scripts/Mots_clefs.tmp | while read line # Boucle de concaténation des résultats dans le fichier mis en forme 
	do
		vide=$(cat /srv/scripts/$line.data)
		elem_comparaison="<b>""$line""<b>"
		if [ "$vide" != "$elem_comparaison" ]
		then
			cat /srv/scripts/$line.data >> /srv/scripts/BDD_veille.mef
			echo "" >> /srv/scripts/BDD_veille.mef
		fi
	done
	cat /srv/scripts/BDD_veille.mef | sed s/'\n'/'<br>'/g > /srv/scripts/BDD_veilleMEF.tmp
	cat /srv/scripts/BDD_veilleMEF.tmp | sed s/'<a href'/'<br><a href'/g > /srv/scripts/BDD_veille.mef
	echo '<br><center><font color="grey" size="1pt"> Le logo de Qwant et le logo de Bash sont la propriété de leur auteurs respectif. En cas de réclamation ou de problème me contacter sur https://github.com/Gspohu</font></center>' >> /srv/scripts/BDD_veille.mef
	if [ "$choix_mail_ou_fichier" = "mail" ]
	then
		mail -s "$(echo -e "[Alert Qwant] Newsletter de $nbline liens\nContent-Type: text/html")" $adresse_mail < /srv/scripts/BDD_veille.mef
        elif [ "$choix_mail_ou_fichier" = "fichier" ]
	then
		cat /srv/scripts/BDD_veille.mef > $chemin_fichier/Newsletter.html
	else
		echo "Choix mail ou fichier argument invalide" >> /srv/scripts/alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Choix mail ou fichier argument invalide"; fi
	fi
	rm /srv/scripts/*.mef /srv/scripts/*.data /srv/scripts/*.tmp
        echo "Un mail avec $nbline liens à été envoyé" >> /srv/scripts/alert_qwant.log
        echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Un mail avec $nbline liens à été envoyé"; fi
	if [ "$verbose" = "Activé" ]; then echo "Fin de l'éxécution du programme"; fi
	echo " " >> /srv/scripts/alert_qwant.log
        exit 0
fi

echo "Le fichier de base de donnée de veille contient $nbline liens" >> /srv/scripts/alert_qwant.log
if [ "$verbose" = "Activé" ]; then echo "Le fichier de base de donnée de veille contient $nbline liens"; fi
rm /srv/scripts/*.tmp
echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
if [ "$verbose" = "Activé" ]; then echo "Fin de l'éxécution du programme"; fi
echo " " >> /srv/scripts/alert_qwant.log
exit 0
