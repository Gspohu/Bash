#!/bin/bash

#Initialisation des variables
install="curl" #Logiciel nécessaire pour le fonctionnement du script
indice="news-content" #Repère pour la div ou se trouve les résultats de la recherche
verif_installation=$(dpkg -s $install | grep Status) #Vérification que curl est installé
nbline=0
jour_heure=$(date +%d/%m/%y' à '%kh%M)
cpt=0

#Lecture des options
if [ $# -ge 1 ]
then
	nboptions=$(echo $#)
	while [ $cpt -lt $nboptions ] #Boucle de lecture des options
	do
	((cpt++))
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
				echo "Fin de l'exécution du programme" >> alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
				echo " " >> alert_qwant.log		
				exit 0 #Fin du programme
			else
				echo "Aucune mise à jour disponible" >> alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo "Aucune mise à jour disponible"; fi
                                echo "Fin de l'exécution du programme" >> alert_qwant.log
                                if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
                                echo " " >> alert_qwant.log
                                exit 0 #Fin du programme
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
		shift #Permet de décalage du prochain paramètre dans la variable $1
	done
fi

#Ecrire dans le log l'heure du lancement
echo "Lancement alert_qwant.sh le $jour_heure :" >> alert_qwant.log
if [ "$verbose" = "Activé" ]; then echo "Lancement alert_qwant.sh le $jour_heure :"; fi

#Vérification de l'emplacement du script
ou_suis_je_home=$(pwd | cut -d\/ -f 2)
ou_suis_je_proffondeur=$(pwd | grep -o /)

if [ "$ou_suis_je_home" != "home" ] && [ "$ou_suis_je_proffondeur" != "/ /" ] #Vérification de l'existence du script alert_qwant.sh
then
        echo 'Erreur critique : Le script est mal placé. Il doit être placé à la racine de votre home'
        echo 'Erreur critique : Le script est mal placé. Il doit être placé à la racine de votre home' >> alert_qwant.log
        echo "Fin de l'exécution du programme" >> alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
	echo " " >> alert_qwant.log
        exit 0 #Fin du programme
fi

#Vérification de la présence des fichiers systèmes
if [ ! -f "alert_qwant.conf" ] # Test de la présence du fichier de configuration
then
	#Création du fichier de configuration
        echo "###Fichier de configuration pour alert_qwant###" >> alert_qwant.conf
        echo "" >> alert_qwant.conf
        echo "Fréquence de lancement de alert_qwant par jour (Le nombre d'heure par jours divisé par ce nombre doit être entier) : 12" >> alert_qwant.conf
	echo "Langue de la veille : fr" >> alert_qwant.conf
        echo "Nombre de liens récupéré par mot clef : 4" >> alert_qwant.conf
        echo "Nombre de liens envoyé par mail : 50" >> alert_qwant.conf
        echo "Une fois les liens récupérés, les envoyers par mail (tapez mail) ou les envoyers dans un fichier (tapez le/lien/absolu/du/fichier) :" >> alert_qwant.conf
        echo "Adresse mail (séparé par une virgule) : adresse@mail.eu" >> alert_qwant.conf
	echo "Chemin absolu du fichier :" >> alert_qwant.conf
	echo "Mode multi-utilisateurs (Activé/Désactivé) : Désactivé" >> alert_qwant.conf 
	echo "En cas d'activation du mode multi-utilisateurs listez ci-dessous les utilisateurs sous cette forme Pseudo : adresse@mail.eu : Chemin absolu du fichier" >> alert_qwant.conf
        echo "Création du fichier de configuration, alert_qwant.conf dans , avec les paramètres de bases. Pensez à l'éditer." >> alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Création du fichier de configuration, alert_qwant.conf dans , avec les paramètres de bases. Pensez à l'éditer."; fi
        echo "Fin de l'exécution du programme" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
	echo " " >> alert_qwant.log
        exit 0 #Fin du programme
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

#Suppression des espaces dans le fichier contenant les mots clefs
cat Mots_clefs.list | sed s/' '/'+'/g > Mots_clefs.tmp

#Création de BDD_veille.data pour permettre la comparaison entre les liens des différents mots clefs
if [ ! -f "BDD_veille.data" ]
then
	touch BDD_veille.data >> alert_qwant.log 2>&1
fi

#Lecture du fichier de configuration
freq=$(cat alert_qwant.conf | grep -o Fréquence.* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
nbliens_mots_clefs=$(cat alert_qwant.conf | grep -o "Nombre de liens récupéré".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
nbliens_par_mail=$(cat alert_qwant.conf | grep -o "Nombre de liens envoyé".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
choix_mail_ou_fichier=$(cat alert_qwant.conf | grep -o "Une fois".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
adresse_mail=$(cat alert_qwant.conf | grep -o "Adresse".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
freq_cron=$((24/$freq))
chemin_fichier=$(cat alert_qwant.conf | grep -o "Chemin".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
langue=$(cat alert_qwant.conf | grep -o "Langue".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)


#Vérification des erreurs dans la récupération des variables du fichier de configuration
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
		echo "Fin de l'exécution du programme" >> alert_qwant.log
	        if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
		echo " " >> alert_qwant.log
        	exit 0 #Fin du programme
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
               	echo "Fin de l'exécution du programme" >> alert_qwant.log
               	if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
		echo " " >> alert_qwant.log
               	exit 0 #Fin du programme
	fi
fi

#chemin fichier
if [ ! -d "$chemin_fichier" ]
then
        echo "Le dossier $chemin_fichier n'existe pas, il sera créé" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "Le dossier $chemin_fichier n'existe pas, il sera créé"; fi
fi

#langue
if [ "$langue" != "en" ] && [ "$langue" != "fr" ] && [ "$langue" != "de" ] && [ "$langue" != "es" ] && [ "$langue" != "it" ] && [ "$langue" != "pt" ] && [ "$langue" != "nl" ] && [ "$langue" != "ru" ] && [ "$langue" != "pl" ] && [ "$langue" != "zh" ]
then
        echo "La langue entré n'est pas disponible, langue est passé en Français" >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo "La langue entré n'est pas disponible, langue est passé en Français"; fi
	langue="fr"
fi


#Mise en place du lancement automatique avec cron
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

if [ "$verif_installation" = "Status: install ok installed" ] #Test de l'installation de curl
then
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
else
	apt-get install $install >>alert_qwant.log 2>&1 #installation de curl
	echo "Le logiciel $install a été installé" >> alert_qwant.log

	echo "Fin de l'exécution du programme avec une erreur critique, veuillez relancer" >> alert_qwant.log
	if [ "$verbose" = "Activé" ]; then echo "Le logiciel $install a été installé"; fi
	if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme avec une erreur critique, veuillez relancer"; fi
fi

#Boucle pour le comptage des lignes du fichier de liens
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

#Test pour le nombre maximum de lien
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
			link=$(echo $line | cut -d '"' -f1)
			echo $line | sed s/'<\/a>'/'   <\/a><a href="https:\/\/cairn-devices.eu\/save_link?link=$link" ><img src="https:\/\/raw.githubusercontent.com\/Gspohu\/Bash\/master\/alert_qwant\/ico_save.png" width="17"  alt="icon_save" \/><\/a>'/g >> BDD_veille.mef.tmp
		else
			echo $line >> BDD_veille.mef.tmp
		fi
	done
        cat BDD_veille.mef.tmp | sed s/'\n'/'<br>'/g > BDD_veilleMEF.tmp
        cat BDD_veilleMEF.tmp | sed s/'<a href'/'<br><a href'/g > BDD_veille.mef


	echo '<br/><br/><br/><br/><center><font color="grey" size="1pt"> Powered by <img src="https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/Qwant_lite_logo.jpg" width="80"  alt="Logo_qwant_lite" /><br/>Le logo de Qwant et le logo de Bash sont la propriété de leur auteurs respectif. En cas de réclamation ou de problème me contacter sur https://github.com/Gspohu</font></center>' >> BDD_veille.mef
	echo '</body>' >> BDD_veille.mef
	echo '</html>' >> BDD_veille.mef

	if [ "$choix_mail_ou_fichier" = "mail" ] || [ "$mail" = "Activé" ] && [ "$fichier" != "Activé" ]
	then
		mail -s "$(echo -e "[Alert Qwant] Newsletter de $nbline liens\nContent-Type: text/html")" $adresse_mail < BDD_veille.mef
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
	if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
	echo " " >> alert_qwant.log
        exit 0 #Fin du programme
fi

echo "Le fichier de base de données de veille contient $nbline liens" >> alert_qwant.log
if [ "$verbose" = "Activé" ]; then echo "Le fichier de base de données de veille contient $nbline liens"; fi
rm *.tmp >>alert_qwant.log 2>&1
echo "Fin de l'exécution du programme" >> alert_qwant.log
if [ "$verbose" = "Activé" ]; then echo "Fin de l'exécution du programme"; fi
echo " " >> alert_qwant.log
exit 0 #Fin du programme
