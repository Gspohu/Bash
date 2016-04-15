#!/bin/bash

#Met fin au script
Stop_script()
{
        echo "Fin de l'exécution du script le $jour_heure " >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du script à $jour_heure "; fi
        echo " " >> alert_qwant.log
        rm *.tmp >>alert_qwant.log 2>&1
        exit 0 #Fin du programme
}

#Lecture des options
Read_option()
{
		#Option de mise à jour
        	if [ $1 = "--upgrade" ]
        	then
			#Création de la signature md5 locale
			openssl md5 alert_qwant.sh > sig.md5
			#Récupération de la signature MD5 de la dernière version
                	diff_maj=$(curl -s https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/sig.md5 | diff sig.md5 -)
			rm sig.md5
			if [ "$diff_maj" != "" ] 
			then
				wget -q -P /tmp/ https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/alert_qwant.sh >>alert_qwant.log 2>&1
				
				rm alert_qwant.sh
				mv /tmp/alert_qwant.sh alert_qwant.sh
				chmod +x alert_qwant.sh

				echo "Une mise à jour est disponible, elle a été téléchargé, alert_qwant est à jour " >> alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo "Une mise à jour est disponible, elle a été téléchargé, alert_qwant est à jour "; fi
				Stop_script
			else
				echo "Aucune mise à jour disponible" >> alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo "Aucune mise à jour disponible"; fi
				Stop_script
			fi
        	elif [ $1 = "--dmail" ]
		then
			rm BDD_veille.mail >>alert_qwant.log 2>&1
		
			echo "La base de donné de liens envoyés par mail à été vidé" >> alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo "La base de donné de liens envoyés par mail à été vidé"; fi
			echo 'Historique des liens envoyé par mail' >> BDD_veille.mail
		elif [ $1 = "--dlog" ] 
		then
			rm alert_qwant.log >>alert_qwant.log 2>&1
		
			echo "Fichier log de alert_qwant" >> alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo "Les logs ont été vidés"; fi
		elif [ $1 = "-v" ]
		then
			verbose="Activé"

			if [ "$verbose" = "Activé" ]; then echo "Option verbose activé"; fi
                        echo "Option verbose activé" >> alert_qwant.log
		elif [ $1 = "--mail" ]
		then
			mail="Activé"

			echo "Option envoi de mail sans taille limite activé" >> alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo "Option envoi de mail sans taille limite activé"; fi
		elif [ $1 = "--fichier" ]
		then
			fichier="Activé"

			echo "Option envoi vers un fichier sans taille limite activé" >> alert_qwant.log
                        if [ "$verbose" = "Activé" ]; then echo "Option envoi vers un fichier sans taille limite activé"; fi
		else
                	if [ "$verbose" = "Activé" ]; then echo "Erreur : Option non reconnue"; fi
			echo 'Erreur : Option non reconnue' >> alert_qwant.log
        	fi
}

#Ecrire dans le log l'heure du lancement
Log_write_timestrart()
{
	echo "Lancement alert_qwant.sh le $jour_heure :" >> alert_qwant.log
}

#Vérification de l'emplacement du script
Check_WhereamI()
{
	ou_suis_je_home=$(pwd | cut -d\/ -f 2)
	ou_suis_je_proffondeur=$(pwd | grep -o /)

	if [ "$ou_suis_je_home" != "home" ] && [ "$ou_suis_je_proffondeur" != "/ /" ] #Vérification de l'existence du script alert_qwant.sh
	then
        	echo 'Erreur critique : Le script est mal placé. Il doit être placé à la racine de votre home'
        	echo 'Erreur critique : Le script est mal placé. Il doit être placé à la racine de votre home' >> alert_qwant.log
		Stop_script
	fi
}

#Vérification de la présence des fichiers systèmes
Check_sysfiles()
{
	if [ ! -f "alert_qwant.conf" ] # Test de la présence du fichier de configuration
	then
		#Création du fichier de configuration
	        echo "###Fichier de configuration pour alert_qwant###" >> alert_qwant.conf
	        echo "" >> alert_qwant.conf
	        echo "1- Fréquence de lancement de alert_qwant par jour (Le nombre d'heure par jours divisé par ce nombre doit être entier) : 12" >> alert_qwant.conf
		echo "2- Langue de la veille : fr" >> alert_qwant.conf
	        echo "3- Nombre de liens par mot clef : 4" >> alert_qwant.conf
        	echo "4- Nombre limite de liens pour le déclenchement du mail : 50" >> alert_qwant.conf
	        echo "5- Une fois les liens récupérés, les envoyers par mail (mail) ou les envoyers dans un fichier (fichier) : mail" >> alert_qwant.conf
        	echo "6- Adresse mail (séparé par une virgule) : adresse@mail.eu" >> alert_qwant.conf
		echo "7- Chemin absolu du fichier : /home/alertqwant" >> alert_qwant.conf
		echo "8- Activation du boutton de sauvegarde (Oui/Non) : Oui" >> alert_qwant.conf
		echo "9- Adresse absolue de la page PHP de sauvegarde des liens : /var/www/" >> alert_qwant.conf
		echo "10- Adresse web de la page PHP de sauvegarde des liens : www.monsite.eu/save_link" >> alert_qwant.conf
		echo "11- Mode multi-utilisateurs (Activé/Désactivé) : Désactivé" >> alert_qwant.conf
		echo "" >> alert_qwant.conf 
		echo "#En cas d'activation du mode multi-utilisateurs listez ci-dessous les utilisateurs sous cette forme :"  >> alert_qwant.conf
		echo "<0> Pseudo0 : 2 : 3 : 4 : 5 : 6 : 7 : 8 <" >> alert_qwant.conf
		echo "<1> Pseudo1 : 2 : 3 : 4 : 5 : 6 : 7 : 8 <" >> alert_qwant.conf
	        echo "Création du fichier de configuration, alert_qwant.conf dans , avec les paramètres de bases. Pensez à l'éditer." >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Création du fichier de configuration, alert_qwant.conf dans , avec les paramètres de bases. Pensez à l'éditer."; fi
	        Stop_script
	fi

	if [ ! -f "Mots_clefs.list" ] # Test de la présence de la liste des mots clefs 
	then
		#Création de la liste des mots clefs
	        echo 'Qwant' >> Mots_clefs.list

        	echo 'Erreur : Votre liste de mots clefs est vide et a été créé automatiquement. Pensez à éditer le fichier Mots_clefs.list' >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Erreur : Votre liste de mots clefs est vide et a été créé automatiquement. Pensez à éditer le fichier Mots_clefs.list"; fi
	fi
	if [ ! -f "BDD_veille.mail" ] # Test de la présence de la BDD des mails envoyés
	then
		#Création de la BDD_veille.mail
        	echo 'Historique des liens envoyé par mail' >> BDD_veille.mail

        	echo "Le fichier de base de données de liens envoyé par mail a été créé" >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Le fichier de base de données de liens envoyé par mail a été créé"; fi
	fi

	#Vérification de l'existence du man alert_qwant
	if [ ! -f "/usr/share/man/man1/alert_qwant.1.gz" ]
	then
		#Création du man alert_qwant
		echo "Man de alert_qwant" >> /usr/share/man/man1/alert_qwant.1
		echo "Alert Qwant est un script Bash d'automatisation de la veille à l'aide de la fonctionnalité actualité du moteur de recherche Qwant" >> /usr/share/man/man1/alert_qwant.1
		echo "Alert_qwant utilise une liste de mots clefs [mots_clefs.list] (le fichier est généré automatiquement), le script insert chaque mot clef dans le moteur de recherche qwant et récupère un nombre de liens définit par l'utilisateur. Une fois une limite atteinte (définit par l'utilisateur), le script envoie par mail ou dans un fichier (définit par l'utilisateur) une newsletter." >> /usr/share/man/man1/alert_qwant.1
		echo "Le script est fait pour se lancer automatiquement, il insère une règle dans crontab" >> /usr/share/man/man1/alert_qwant.1
		echo " " >> /usr/share/man/man1/alert_qwant.1
		echo "Le fichier de configuration permet de configurer le script. Ce fichier de configuration est généré automatiquement au premier lancement. Pensez à le complèter." >> /usr/share/man/man1/alert_qwant.1
		echo "" >> /usr/share/man/man1/alert_qwant.1
		echo "Le script doit être placé dans /srv/scripts et doit être lancé en tant que root. Si le script est mal placé il se copiera lui même dans le le dossier et renverra une erreur."
		echo "" >> /usr/share/man/man1/alert_qwant.1
		echo "Option :" >> /usr/share/man/man1/alert_qwant.1
		echo "--upgrade" >> /usr/share/man/man1/alert_qwant.1
		echo "          Permet la mise à jour" >> /usr/share/man/man1/alert_qwant.1
		echo "--dmail" >> /usr/share/man/man1/alert_qwant.1
		echo "        Efface la base de donnéess des mails envoyés" >> /usr/share/man/man1/alert_qwant.1
		echo "--dlog" >> /usr/share/man/man1/alert_qwant.1
		echo "       Efface les log" >> /usr/share/man/man1/alert_qwant.1
		echo "-v" >> /usr/share/man/man1/alert_qwant.1
		echo "   Verbose" >> /usr/share/man/man1/alert_qwant.1
		echo "--mail" >> /usr/share/man/man1/alert_qwant.1
		echo "       Envoi un mail sans limite de taille" >> /usr/share/man/man1/alert_qwant.1
		echo "--fichier" >> /usr/share/man/man1/alert_qwant.1
		echo "          Envoi vers un fichier sans limite de taille" >> /usr/share/man/man1/alert_qwant.1
		echo " " >> /usr/share/man/man1/alert_qwant.1
		gzip /usr/share/man/man1/alert_qwant.1 >>alert_qwant.log 2>&1
		rm  /usr/share/man/man1/alert_qwant.1 >>alert_qwant.log 2>&1

		echo 'Création de la page de manuel. Vous pouvez y accéder avec la commande man alert_qwant' >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Création de la page de manuel. Vous pouvez y accéder avec la commande man alert_qwant"; fi
fi
}

#Suppression des espaces dans le fichier contenant les mots clefs
Del_space_keywords()
{
	cat Mots_clefs.list | sed s/' '/'+'/g > Mots_clefs.tmp
}

#Création de BDD_veille.data pour permettre la comparaison entre les liens des différents mots clefs
Check_BDD_veille()
{
	if [ ! -f "BDD_veille.data" ]
	then
		touch BDD_veille.data >> alert_qwant.log 2>&1
	fi
}

#Lecture du fichier de configuration
Read_conffile()
{
	freq=$(cat alert_qwant.conf | grep -o "1-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	langue=$(cat alert_qwant.conf | grep -o "2-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	nbliens_mots_clefs=$(cat alert_qwant.conf | grep -o "3-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	nbliens_par_mail=$(cat alert_qwant.conf | grep -o "4-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	choix_mail_ou_fichier=$(cat alert_qwant.conf | grep -o "5-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	adresse_mail=$(cat alert_qwant.conf | grep -o "6-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	chemin_fichier=$(cat alert_qwant.conf | grep -o "7-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	enable_save=$(cat alert_qwant.conf | grep -o "8-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)	
	adress_PHP=$(cat alert_qwant.conf | grep -o "9-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	adress_web_PHP_saver=$(cat alert_qwant.conf | grep -o "10-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	enable_multi=$(cat alert_qwant.conf | grep -o "11-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)

		echo "Mode multi-utilisateurs activé" >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Mode multi-utilisateurs activé"; fi
		nbuser=$(cat alert_qwant.conf | grep -o "<".* | wc -l)
		while [ $cpt_user -lt $nbuser ] && [ "$enable_multi" = "Activé" ]
		do
			multi_pseudo[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \> -f 2 | cut -d \: -f 1 | sed s/' '/''/g )
			multi_langue[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \: -f 2 | cut -d \: -f 2 | sed s/' '/''/g )
			multi_nbliens_mots_clefs[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \: -f 3 | cut -d \: -f 3 | sed s/' '/''/g )
			multi_nbliens_par_mail[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \: -f 4 | cut -d \: -f 4 | sed s/' '/''/g )
			multi_choix_mail_ou_fichier[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \: -f 5 | cut -d \: -f 5 | sed s/' '/''/g )
			multi_adresse_mail[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \: -f 6 | cut -d \: -f 6 | sed s/' '/''/g )
			multi_chemin_fichier[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \: -f 7 | cut -d \: -f 7 | sed s/' '/''/g )
			multi_enable_save[$cpt_user]=$(cat alert_qwant.conf | grep -o "<""$cpt_user".* | cut  -d \: -f 8 | cut -d \< -f 1 | sed s/' '/''/g )

			((cpt_user++))
		done

	#Conversion de la fréquence pour la crontab
	freq_cron=$((24/$freq))

	#Concaténation du nom de la page PHP de sauvegarde des liens
	adress_PHP_saver="$adress_PHP""save_links.php"
}

#Vérification des erreurs dans la récupération des variables du fichier de configuration
Check_read_conffile()
{
#freq
test_entier=$(($freq*$freq_cron))
if [ $test_entier -ne 24 ]
then
	echo "La frequence de lancement divisé par 24 ne donne pas un nombre entier, le résultat à été troncaturé, veuillez éditer le fichier de configuration afin de corriger" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "La frequence de lancement divisé par 24 ne donne pas un nombre entier, le résultat à été troncaturé, veuillez éditer le fichier de configuration afin de corriger"; fi
fi

#nbliens_mots_clefs
if [ $nbliens_mots_clefs -eq 0 ]
then
	echo "Le nombre de liens choisi dans le fichier de configuration est égale à 0 il a été interprété comme 4, veuillez éditer le fichier de configuration afin de corriger" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "Le nombre de liens choisi dans le fichier de configuration est égale à 0 il a été interprété comme 4, veuillez éditer le fichier de configuration afin de corriger"; fi
	nbliens_mots_clefs=4
elif [ $nbliens_mots_clefs -gt 10 ]
then
	        echo "Le nombre de liens choisi dans le fichier de configuration est supérieur à 10 il a été interprété comme 10, veuillez éditer le fichier de configuration afin de corriger" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "Le nombre de liens choisi dans le fichier de configuration est supérieur à 10 il a été interprété comme 10, veuillez éditer le fichier de configuration afin de corriger"; fi
        nbliens_mots_clefs=10
fi

#choix_mail_ou_fichier
if [ "$choix_mail_ou_fichier" != "mail" ] && [ "$choix_mail_ou_fichier" != "fichier"]
then
	if [ "$adresse_mail" = "" ] && [ "$chemin_fichier" != "" ]
	then
		$choix_mail_ou_fichier="fichier"
	elif [ "$chemin_fichier" = "" ] && [ "$adresse_mail" != "" ]
	then
		$choix_mail_ou_fichier="mail"
	else
		echo "Erreur critique : le fichier de configuration est mal complèté dans la partie choix mail ou fichier" >> alert_qwant.log
        	if [ "$verbose" = "Activé" ]; then echo "Erreur critique : le fichier de configuration est mal complèté dans la partie choix mail ou fichier"; fi
        	Stop_script
	fi
fi
#adresse_mail
arob=$(echo $adresse_mail | grep -o @.*) #Recherche de la présence d'un @
domaine=$(echo $arob | grep -o [.].*) #Recherche de la présence d'un nom de domaine

if [ "$arob" = "" ] || [ "$domaine" = "" ]
then
	echo "L'adresse mail entré est fausse, veuillez corriger" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "L'adresse mail entré est fausse, veuillez corriger"; fi
	if [ "$choix_mail_ou_fichier" = "mail" ]
	then
               	Stop_script
	fi
fi

#chemin fichier
if [ ! -d "$chemin_fichier" ]
then
        echo "Le dossier $chemin_fichier n'existe pas, il sera créé" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "Le dossier $chemin_fichier n'existe pas, il sera créé"; fi
fi

	#Langue
	while [ $i -le 10 ]
	do
		if [ "$langue" = "${langue_dispo[$i]}" ]
		then
			i=11
		elif [ $i -eq 10 ]
		then
        		echo "La langue entré n'est pas disponible, la langue est passé en Français" >> alert_qwant.log
        		if [ "$verbose" = "Activé" ]; then echo "La langue entré n'est pas disponible, langue est passé en Français"; fi
			langue="fr"
		else
			((i++))
		fi
	done
}

#Mise en place du lancement automatique avec cron
Crontab_addrule()
{
	crontab -l > /tmp/crontab_tmp.tmp
	lancement_auto=$(grep alert_qwant /tmp/crontab_tmp.tmp)

	if [ "$lancement_auto" != "0 */$freq_cron * * * bash alert_qwant.sh >> cron.log 2>&1" ]
	then
		sed '/alert_qwant/d' /tmp/crontab_tmp.tmp > /tmp/crontab_tmp_tmp.tmp
		cat /tmp/crontab_tmp_tmp.tmp > /tmp/crontab_tmp.tmp
		echo "0 */$freq_cron * * * bash alert_qwant.sh >> cron.log 2>&1" >> /tmp/crontab_tmp.tmp
		crontab /tmp/crontab_tmp.tmp
		rm -f /tmp/crontab_tmp.tmp /tmp/crontab_tmp_tmp.tmp >>alert_qwant.log 2>&1
		echo "Ajout d'une règle dans crontab" >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Ajout d'une règle dans crontab"; fi
	else	
		rm /tmp/crontab_tmp.tmp >>alert_qwant.log 2>&1
	fi
}

#Vérification de l'installation des dépendance
Check_dependancy()
{
	if [ "$verif_installation" != "Status: install ok installed" ] #Test de l'installation de curl
	then
		echo "Fin de l'exécution du programme avec une erreur critique, veuillez relancer" >> alert_qwant.log
		echo "Certaines dépendance ne sont pas satisfaitent" >> alert_qwant.log
		Stop_script
	fi

}

#Récupération des liens
Search_links()
{
	if [ "$enable_multi" = "Activé" ]
	then
		echo "singe"	
	else
		#Boucle pour rechercher les liens pour chaque mot clef
		cat Mots_clefs.tmp | while read line #Lecture ligne par ligne
		do
        		mots_clefs=$line
	
			#Inscription de l'entête
			if [ ! -f "$mots_clefs.data" ]
			then
				echo "<br><br><b>$mots_clefs<b><br>" | sed s/'+'/' '/g > $mots_clefs.data
			fi

        		moteur="https://lite.qwant.com/?q=$mots_clefs&t=news&l=$langue" #Lien du moteur de recherche
			curl -s $moteur | grep -A 3 $indice | grep -o '<a href'.*'</a>'$ | head -n $nbliens_mots_clefs | sed s/'\<\/a\>'/'\<\/a\>\n'/g >> $mots_clefs.tmp #Récupération des liens sur le moteur de recherche

			#Vérification des doublons
			cat $mots_clefs.tmp | sort > tmp
			cat BDD_veille.mail | sort >> tmp
			cat BDD_veille.data | sort >> tmp
			cat tmp | sort | uniq -d > tmp.tmp
	  	        rm tmp >>alert_qwant.log 2>&1
 			cat $mots_clefs.tmp >> tmp.tmp
        		cat tmp.tmp | sort | uniq -u > $mots_clefs.tmp
		        rm tmp.tmp >>alert_qwant.log 2>&1
			cat $mots_clefs.tmp | sed '/^$/d' >> $mots_clefs.data
			cat $mots_clefs.tmp | sed '/^$/d' >> BDD_veille.data
			rm $mots_clefs.tmp >>alert_qwant.log 2>&1
		done
	fi
}

#Boucle pour le comptage des lignes de la base de donnée de liens
Check_howmany_links()
{
	cat BDD_veille.data | while read line
	do
       		((nbline++))
		echo "$nbline" > nbline.tmp
	done

	#Test de la présence du fichier nbline.tmp
	if [ -f "nbline.tmp" ] 
	then
		nbline=$(cat nbline.tmp)
	fi
}

#Génération du document final
Creat_finaldoc()
{
#Test les conditions pour créer le document final, nombre maximum de liens, option mail ou option fichier
if [ $nbline -ge $nbliens_par_mail ] || [ "$mail" = "Activé" ] || [ "$fichier" = "Activé" ]
then
	#Mise en forme du MEF
	echo '<!doctype html>' >> BDD_veille.mef
	echo '<html lang="fr">' >> BDD_veille.mef
	echo '<head>' >> BDD_veille.mef
	echo '<meta charset="utf-8">' >> BDD_veille.mef
	echo '<title>[Alert Qwant] Newsletter</title>' >> BDD_veille.mef
	echo '<link rel="stylesheet" href="style.css">' >> BDD_veille.mef
	echo '</head>' >> BDD_veille.mef
	echo '<body>' >> BDD_veille.mef
	echo '<img src="https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/QwantandBash.png" width="250" align="left" alt="Logo" /><br/><br/><br/>' >> BDD_veille.mef
	echo "<br><p align="right"><font color="grey" >Newsletter du $jour_heure</font></p><br/>" >> BDD_veille.mef
	
	cat BDD_veille.data | sort >> BDD_veille.mail
	poids_BDD_mail=$(ls -lh BDD_veille.mail | cut -d ' ' -f5)
	cat Mots_clefs.tmp | while read line # Boucle de concaténation des résultats dans le fichier mis en forme 
	do
		mot_clef=$(echo $line | sed s/'+'/' '/g)
		vide=$(cat $line.data)
		elem_comparaison="<br><br><b>""$mot_clef""<b><br>"
		if [ "$vide" != "$elem_comparaison" ]
		then
			cat $line.data >> BDD_veille.mef
			echo "" >> BDD_veille.mef
		fi
	done

	cat BDD_veille.mef | while read line # Lecture des liens ligne par ligne pour ajouter le paramètre en URL
	do
		if [ "${line:0:2}" = "<a" ]
		then
			link=$(echo $line | cut -d '"' -f2 | sed 's/\//\\\//g')
			lien_sauv='\&\#8239\;\&\#8239\;\&\#8239\;\&\#8239\;<\/a><a href="https:\/\/cairn-devices.eu\/save_links?user='$user'\&link='$link'" ><img src="https:\/\/raw.githubusercontent.com\/Gspohu\/Bash\/master\/alert_qwant\/ico_save.png" width="17"  alt="icon_save" \/><\/a>'
			echo $line | sed "s/<\/a>/$lien_sauv/g" >> BDD_veille.mef.tmp
		else
			echo $line >> BDD_veille.mef.tmp
		fi
	done
        cat BDD_veille.mef.tmp | sed s/'\n'/'<br>'/g > BDD_veilleMEF.tmp
        cat BDD_veilleMEF.tmp | sed s/'\/><\/a>'/'\/><\/a><br>'/g > BDD_veille.mef


	echo '<br/><br/><br/><br/><center><font color="grey" size="1pt"> Powered by <img src="https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/Qwant_lite_logo.jpg" width="80"  alt="Logo_qwant_lite" /><br/>Le logo de Qwant et le logo de Bash sont la propriété de leur auteurs respectif. En cas de réclamation ou de problème me contacter sur https://github.com/Gspohu</font></center>' >> BDD_veille.mef
	echo '</body>' >> BDD_veille.mef
	echo '</html>' >> BDD_veille.mef

	if [ "$choix_mail_ou_fichier" = "mail" ] || [ "$mail" = "Activé" ] && [ "$fichier" != "Activé" ]
	then
		mail -s "$(echo -e "Newsletter de $nbline liens\nContent-Type: text/html")" $adresse_mail < BDD_veille.mef
		echo "Un mail avec $nbline liens à été envoyé" >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Un mail avec $nbline liens à été envoyé"; fi
        elif [ "$choix_mail_ou_fichier" = "fichier" ] || [ "$fichier" = "Activé" ]
	then
		cat BDD_veille.mef > $chemin_fichier/Newsletter.html
		echo "La newsletter avec $nbline liens est consultable ici $chemin_fichier" >> alert_qwant.log
                if [ "$verbose" = "Activé" ]; then echo "La newsletter avec $nbline liens est consultable ici $chemin_fichier"; fi
	else
		echo "Choix mail ou fichier argument invalide" >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo "Choix mail ou fichier argument invalide"; fi
	fi
	rm *.mef *.data *.tmp >>alert_qwant.log 2>&1
        echo "Le fichier BDD_veille.mail pèse $poids_BDD_mail" >> alert_qwant.log
	echo "Fin de l'exécution du programme" >> alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Le fichier BDD_veille.mail pèse $poids_BDD_mail"; fi
        Stop_script
fi
}


#Récupération du poids de la BDD_veille.mail
Print_weight_BDD_veille()
{
	echo "Le fichier de base de données de veille contient $nbline liens" >> alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Le fichier de base de données de veille contient $nbline liens"; fi
}

Check_PHP_savepage()
{
	if [ ! -f "$adress_PHP_saver" ]
        then
		echo "La page PHP de sauvegarde des liens n'existe pas" >> alert_qwant.log
	        if [ "$verbose" = "Activé" ]; then echo "La page PHP de sauvegarde des liens n'existe pas";fi
		
		echo "<?php" >> $adress_PHP_saver
		echo "if (isset($_GET['user']) AND isset($_GET['link']))" >> $adress_PHP_saver
		echo "{" >> $adress_PHP_saver
		echo "$user = htmlspecialchars($_GET['user']);" >> $adress_PHP_saver
		echo "$link = htmlspecialchars($_GET['link']);" >> $adress_PHP_saver
		echo "$BDD_noSQL = fopen('BDD_links.nsq', 'a');" >> $adress_PHP_saver
		echo "fprintf( $BDD_noSQL, $user ":" $link );" >> $adress_PHP_saver
		echo "fclose($BDD_noSQL);" >> $adress_PHP_saver
		echo "?>" >> $adress_PHP_saver

		echo "La page PHP de sauvegarde des liens à été créé" >> alert_qwant.log
                if [ "$verbose" = "Activé" ]; then echo "La page PHP de sauvegarde des liens à été créé";fi    		fi	
}

####################
########Main########
####################


#Initialisation des variables
install="curl" #Logiciel nécessaire pour le fonctionnement du script
indice="news-content" #Repère pour la div ou se trouve les résultats de la recherche
verif_installation=$(dpkg -s $install | grep Status) #Vérification que curl est installé
nbline=0
jour_heure=$(date +%d/%m/%y' à '%kh%M)
cpt=0 # Compteur de lecture des options
i=0 # Compteur
cpt_user=0 # Compteur de lecture des profiles utilisateur
langue_dispo=( 'en' 'fr' 'de' 'es' 'it' 'pt' 'nl' 'ru' 'pl' 'zh' 'XYZcaseenplusXYZ' )
user=""

Log_write_timestrart
while [ $# -ge $cpt ] && [ $# -ge 1 ]
do
	Read_option "$1"
	shift #Permet de décalage du prochain paramètre dans la variable $1
	((cpt++))
done

Check_dependancy
Check_WhereamI
Check_sysfiles
Check_BDD_veille

Del_space_keywords

Read_conffile
Check_read_conffile

Crontab_addrule

Search_links
Check_howmany_links

Creat_finaldoc


Stop_script
