#!/bin/bash

#Met fin au script
Stop_script()
{
        echo "Fin de l'exécution du script le $jour_heure " >> alert_qwant.log
        if [ "$verbose" = "Activé" ]; then echo -e "Fin de l'exécution du script à $jour_heure "; fi
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
				if [ "$verbose" = "Activé" ]; then echo -e "Une mise à jour est disponible, elle a été téléchargé, alert_qwant est à jour "; fi
				Stop_script
			else
				echo "Aucune mise à jour disponible" >> alert_qwant.log
				if [ "$verbose" = "Activé" ]; then echo -e "Aucune mise à jour disponible"; fi
				Stop_script
			fi
        	elif [ $1 = "--dmail" ]
		then
			rm *.mail >>alert_qwant.log 2>&1
		
			echo "La base de donné de liens envoyés par mail à été vidé" >> alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo -e "La base de donné de liens envoyés par mail à été vidé"; fi
		elif [ $1 = "--dlog" ] 
		then
			rm alert_qwant.log >>alert_qwant.log 2>&1
		
			echo "Fichier log de alert_qwant" >> alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo -e "Les logs ont été vidés"; fi
		elif [ $1 = "-v" ]
		then
			verbose="Activé"

			if [ "$verbose" = "Activé" ]; then echo -e "Option verbose activé"; fi
                        echo "Option verbose activé" >> alert_qwant.log
		elif [ $1 = "--mail" ]
		then
			mail="Activé"

			echo "Option envoi de mail sans taille limite activé" >> alert_qwant.log
			if [ "$verbose" = "Activé" ]; then echo -e "Option envoi de mail sans taille limite activé"; fi
		elif [ $1 = "--fichier" ]
		then
			fichier="Activé"

			echo "Option envoi vers un fichier sans taille limite activé" >> alert_qwant.log
                        if [ "$verbose" = "Activé" ]; then echo -e "Option envoi vers un fichier sans taille limite activé"; fi
		else
                	if [ "$verbose" = "Activé" ]; then echo -e "\033[31mErreur : Option non reconnue\033[00m"; fi
			echo 'Erreur : Option non reconnue' >> alert_qwant.log
        	fi
if [ "$verbose" = "Activé" ]; then echo -e "Lecture des options.......\033[32mFait\033[00m"; fi
}

#Ecrire dans le log l'heure du lancement
Write_timestart_inlog()
{
	echo "Lancement alert_qwant.sh le $jour_heure :" >> alert_qwant.log
}

#Vérification de l'emplacement du script
Check_WhereamI()
{
	ou_suis_je=$(pwd)

	# Vérification de l'existence du script alert_qwant.sh
	if [ "$ou_suis_je" != "/home/alertqwant" ]
	then
        	echo "\033[31mErreur critique : Le script est mal placé. Il doit être placé à la racine du home de l\'utilisateur alertqwant\033[00m"
        	echo "Erreur critique : Le script est mal placé. Il doit être placé à la racine du home de l\'utilisateur alertqwant" >> alert_qwant.log
		Stop_script
	fi
if [ "$verbose" = "Activé" ]; then echo -e "Vérification de l'emplacement.......\033[32mFait\033[00m"; fi
}

#Vérification de la présence des fichiers systèmes
Check_sysfiles()
{
	# Test de la présence du fichier de configuration
	if [ ! -f "alert_qwant.conf" ]
	then
		#Création du fichier de configuration
	        echo "###Fichier de configuration pour alert_qwant###" >> alert_qwant.conf
	        echo "" >> alert_qwant.conf
	        echo "1- Fréquence de lancement de alert_qwant par jour (Le nombre d'heure par jours divisé par ce nombre doit être entier) : 12" >> alert_qwant.conf
		echo "2- Langue de la veille " >> alert_qwant.conf
	        echo "3- Nombre de liens par mot clef" >> alert_qwant.conf
        	echo "4- Nombre limite de liens pour le déclenchement du mail" >> alert_qwant.conf
	        echo "5- Une fois les liens récupérés, les envoyers par mail (mail) ou les envoyers dans un fichier (fichier)" >> alert_qwant.conf
        	echo "6- Adresse mail" >> alert_qwant.conf
		echo "7- Chemin absolu du fichier" >> alert_qwant.conf
		echo "8- Activation du boutton de sauvegarde (Oui/Non)" >> alert_qwant.conf
		echo "9- Adresse absolue de la page PHP de sauvegarde des liens : /var/www/" >> alert_qwant.conf
		echo "10- Adresse web de la page PHP de sauvegarde des liens : monsite.eu/save_links.php" >> alert_qwant.conf
		echo "" >> alert_qwant.conf 
		echo "#Listez ci-dessous les utilisateurs sous cette forme sans le #, pensez à supprimer les exemples en # :"  >> alert_qwant.conf
		echo "#<0> Pseudo0 : 2 : 3 : 4 : 5 : 6 : 7 : 8 <" >> alert_qwant.conf
		echo "#<1> Aymeric : fr : 4 : 50 : mail : adresse@mail.eu : /home/alertqwant/ : Oui <" >> alert_qwant.conf
	        echo "Création du fichier de configuration, alert_qwant.conf, avec les paramètres de bases. Pensez à l'éditer." >> alert_qwant.log
		if [ "$verbose" = "Activé" ]; then echo -e "Création du fichier de configuration, alert_qwant.conf, avec les paramètres de bases. Pensez à l'éditer."; fi
	        Stop_script
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
		if [ "$verbose" = "Activé" ]; then echo -e "Création de la page de manuel. Vous pouvez y accéder avec la commande man alert_qwant"; fi
	fi
if [ "$verbose" = "Activé" ]; then echo -e "Vérification des fichiers systèmes.......\033[32mFait\033[00m"; fi
}

#Vérification et création des listes de mots clefs pour chaque utilisateurs et suppression des espaces
Check_keywords_lists()
{
	cpt_user=0
	while [ $cpt_user -lt $nbuser ]	
	do
		filename_keywords_list="${multi_pseudo[$cpt_user]}""_""mots_clefs.list"
		filename_keywords_list_tmp="${multi_pseudo[$cpt_user]}""_""mots_clefs.tmp"
		if [ ! -f "$filename_keywords_list" ]
		then
			echo "Qwant" >> $filename_keywords_list

        	        echo "Erreur : La liste de mots clefs pour l'utilisateur ${multi_pseudo[$cpt_user]} n'existe pas elle a été créée automatiquement. Pensez à éditer le fichier $filename_keywords_list" >> alert_qwant.log
	                if [ "$verbose" = "Activé" ]; then echo -e "\033[31mErreur : La liste de mots clefs pour l'utilisateur ${multi_pseudo[$cpt_user]} n'existe pas elle a été créée automatiquement. Pensez à éditer le fichier $filename_keywords_list \033[00m"; fi
			Stop="O"
		else
			cat $filename_keywords_list | sed s/' '/'+'/g > $filename_keywords_list_tmp
		fi
		((cpt_user++))
	done

	if [ "$Stop" = "O" ]
	then
		Stop_script
	fi

if [ "$verbose" = "Activé" ]; then echo -e "Vérification de l'existance de la liste des mots clefs pour chaque utilisateur.......\033[32mFait\033[00m"; fi
}

#Lecture du fichier de configuration
Read_conffile()
{
	freq=$(cat alert_qwant.conf | grep -o "1-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	adress_PHP=$(cat alert_qwant.conf | grep -o "9-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	adress_web_PHP_saver=$(cat alert_qwant.conf | grep -o "10-".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
	nbuser=$(cat alert_qwant.conf | grep -o "<".* | wc -l)

	cpt_user=0
	while [ $cpt_user -lt $nbuser ]
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

	#Concaténation de l'adresse et du nom de la page PHP de sauvegarde des liens
	adress_PHP_saver="$adress_PHP""save_links.php"
if [ "$verbose" = "Activé" ]; then echo -e "Lecture du fichier de configuration.......\033[32mFait\033[00m"; fi
}

#Vérification des erreurs dans la récupération des variables du fichier de configuration
Check_read_conffile()
{
	#freq
	test_entier=$(($freq*$freq_cron))
	if [ $test_entier -ne 24 ]
	then
		echo "La frequence de lancement divisé par 24 ne donne pas un nombre entier, le résultat à été troncaturé, veuillez éditer le fichier de configuration afin de corriger" >> alert_qwant.log
        	if [ "$verbose" = "Activé" ]; then echo -e "La frequence de lancement divisé par 24 ne donne pas un nombre entier, le résultat à été troncaturé, veuillez éditer le fichier de configuration afin de corriger"; fi
	fi

	cpt_user=0
	while [ $cpt_user -lt $nbuser ]
	do
		#Nombre de liens par mots clefs
		if [ ${multi_nbliens_mots_clefs[$cpt_user]} -eq 0 ]
		then
			echo "Le nombre de liens par mot clef choisi par l'utilisateur ${multi_pseudo[$cpt_user]} dans le fichier de configuration est égale à 0 il a été interprété comme 4, veuillez éditer le fichier de configuration afin de corriger" >> alert_qwant.log
	        	if [ "$verbose" = "Activé" ]; then echo -e "Le nombre de liens par mot clef choisi par l'utilisateur ${multi_pseudo[$cpt_user]} dans le fichier de configuration est égale à 0 il a été interprété comme 4, veuillez éditer le fichier de configuration afin de corriger"; fi
			multi_nbliens_mots_clefs[$cpt_user]=4
		elif [ ${multi_nbliens_mots_clefs[$cpt_user]} -gt 10 ]
		then
		        echo "Le nombre de liens par mot clef choisi par l'utilisateur ${multi_pseudo[$cpt_user]} dans le fichier de configuration est supérieur à 10 il a été interprété comme 10, veuillez éditer le fichier de configuration afin de corriger" >> alert_qwant.log
	        	if [ "$verbose" = "Activé" ]; then echo -e "Le nombre de liens par mot clef choisi par l'utilisateur ${multi_pseudo[$cpt_user]} dans le fichier de configuration est supérieur à 10 il a été interprété comme 10, veuillez éditer le fichier de configuration afin de corriger"; fi
        		multi_nbliens_mots_clefs[$cpt_user]=10
		fi

		#Choix mail ou fichier
		if [ "${multi_choix_mail_ou_fichier[$cpt_user]}" != "mail" ] && [ "${multi_choix_mail_ou_fichier[$cpt_user]}" != "fichier"]
		then
			if [ "${multi_adresse_mail[$cpt_user]}" = "" ] && [ "${multi_chemin_fichier[$cpt_user]}" != "" ]
			then
				$choix_mail_ou_fichier="fichier"
			elif [ "${multi_chemin_fichier[$cpt_user]}" = "" ] && [ "${multi_adresse_mail[$cpt_user]}" != "" ]
			then
				$choix_mail_ou_fichier="mail"
			else
				echo "Erreur critique : le fichier de configuration est mal complèté dans la partie choix mail ou fichier de l'utilisateur ${multi_pseudo[$cpt_user]}" >> alert_qwant.log
        			if [ "$verbose" = "Activé" ]; then echo -e "\033[32mErreur critique : le fichier de configuration est mal complèté dans la partie choix mail ou fichier de l'utilisateur ${multi_pseudo[$cpt_user]} \033[00m"; fi
        			Stop_script
			fi
		fi

		#Adresse mail
		arob=$(echo ${multi_adresse_mail[$cpt_user]} | grep -o @.*) #Recherche de la présence d'un @
		domaine=$(echo $arob | grep -o [.].*) #Recherche de la présence d'un nom de domaine

		if [ "$arob" = "" ] || [ "$domaine" = "" ] && [ "${multi_choix_mail_ou_fichier[$cpt_user]}" = "mail" ]
		then
			echo "L'adresse mail entré est fausse, veuillez corriger" >> alert_qwant.log
        		if [ "$verbose" = "Activé" ]; then echo -e "L'adresse mail entré est fausse, veuillez corriger"; fi
               		Stop_script
		fi

		#Chemin fichier
		if [ ! -d "${multi_chemin_fichier[$cpt_user]}" ]
		then
        		echo "Le dossier $chemin_fichier n'existe pas, il sera créé" >> alert_qwant.log
        		if [ "$verbose" = "Activé" ]; then echo -e "Le dossier $chemin_fichier n'existe pas, il sera créé"; fi
		fi

		#Langue
		i=0
		while [ $i -le 10 ]
		do
			if [ "${multi_langue[$cpt_user]}" = "${langue_dispo[$i]}" ]
			then
				i=11
			elif [ $i -eq 10 ]
			then
        			echo "La langue entrée pour l'utilisateur ${multi_pseudo[$cpt_user]} n'est pas disponible, la langue est passé en Français" >> alert_qwant.log
        			if [ "$verbose" = "Activé" ]; then echo -e "La langue entrée pour l'utilisateur ${multi_pseudo[$cpt_user]} n'est pas disponible, la langue est passé en Français"; fi
				multi_langue[$cpt_user]="fr"
			else
				((i++))
			fi
		done
		
		((cpt_user++))
	done

	if [ "$verbose" = "Activé" ]; then echo -e "Vérification des options de configurations.......\033[32mFait\033[00m"; fi
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
		if [ "$verbose" = "Activé" ]; then echo -e "Ajout d'une règle dans crontab"; fi
	else	
		rm /tmp/crontab_tmp.tmp >>alert_qwant.log 2>&1
	fi
if [ "$verbose" = "Activé" ]; then echo -e "Vérification de l'existance d'un règle crontab.......\033[32mFait\033[00m"; fi
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
if [ "$verbose" = "Activé" ]; then echo -e "Vérification des dépendances.......\033[32mFait\033[00m"; fi
}

#Vérification de l'existance des fichiers de BDD 
Check_BBD_files()
{
	cpt_user=0
	while [ $cpt_user -lt $nbuser ]
	do
		BDD_veille_mail_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.mail"
                BDD_veille_data_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.data"

		if [ ! -f "$BDD_veille_mail_by_user" ]
		then
                	touch $BDD_veille_mail_by_user >> alert_qwant.log 2>&1
			if [ "$verbose" = "Activé" ]; then echo -e "Création du fichier $BDD_veille_mail_by_user"; fi
			echo "Création du fichier $BDD_veille_mail_by_user"  >> alert_qwant.log
		fi
		if [ ! -f "$BDD_veille_data_by_user" ]
		then
			touch $BDD_veille_data_by_user >> alert_qwant.log 2>&1
			if [ "$verbose" = "Activé" ]; then echo -e "Création du fichier $BDD_veille_data_by_user"; fi
			echo "Création du fichier $BDD_veille_data_by_user" >> alert_qwant.log
		fi
		
		((cpt_user++))
	done
if [ "$verbose" = "Activé" ]; then echo -e "Vérification de l'existance des BDD_veille pour chaque utilisateur.......\033[32mFait\033[00m"; fi
}

#Récupération des liens
Search_links()
{
		cpt_user=0
		while [ $cpt_user -lt $nbuser ]
		do
			filename_keywords_list_tmp="${multi_pseudo[$cpt_user]}""_""mots_clefs.tmp"
			#Boucle pour rechercher les liens pour chaque mot clef
	                cat $filename_keywords_list_tmp | while read line #Lecture ligne par ligne
        	        do
                	        mots_clefs=$line
				filename_keywords_result_by_user="${multi_pseudo[$cpt_user]}""_""$mots_clefs"".data"
				filename_keywords_result_by_user_tmp="${multi_pseudo[$cpt_user]}""_""$mots_clefs"".tmp"				
				BDD_veille_mail_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.mail"
				BDD_veille_data_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.data"
 
                        	#Inscription de l'entête
                        	if [ ! -f "$filename_keywords_result_by_user" ]
                        	then
                                	echo "<br><br><b>$mots_clefs<b><br>" | sed s/'+'/' '/g > $filename_keywords_result_by_user
                        	fi

				#Lien du moteur de recherche
                        	moteur="https://lite.qwant.com/?q=$mots_clefs&t=news&l=${multi_langue[$cpt_user]}" 

				#Récupération des liens sur le moteur de recherche
                        	curl -s $moteur | grep -A 3 $indice | grep -o '<a href'.*'</a>'$ | head -n ${multi_nbliens_mots_clefs[$cpt_user]} | sed s/'\<\/a\>'/'\<\/a\>\n'/g >> $filename_keywords_result_by_user_tmp

                        	#Vérification des doublons
              			cat $filename_keywords_result_by_user_tmp | sort > tmp
                        	cat $BDD_veille_mail_by_user | sort >> tmp
                    	    	cat $BDD_veille_data_by_user | sort >> tmp
                        	cat tmp | sort | uniq -d > tmp.tmp
               	         	rm tmp >>alert_qwant.log 2>&1
                	        cat $filename_keywords_result_by_user_tmp >> tmp.tmp
                        	cat tmp.tmp | sort | uniq -u > $filename_keywords_result_by_user_tmp
                    		rm tmp.tmp >>alert_qwant.log 2>&1
                       		cat $filename_keywords_result_by_user_tmp | sed '/^$/d' >> $filename_keywords_result_by_user
                  	        cat $filename_keywords_result_by_user_tmp | sed '/^$/d' >> $BDD_veille_data_by_user
                        	rm $filename_keywords_result_by_user_tmp >>alert_qwant.log 2>&1
		               	done
			((cpt_user++))
		done
			
	if [ "$verbose" = "Activé" ]; then echo -e "Recherche des liens.......\033[32mFait\033[00m"; fi
}

#Boucle pour le comptage des lignes de la base de donnée de liens
Check_howmany_links()
{
	cpt_user=0
	while [ $cpt_user -lt $nbuser ]
	do
		BDD_veille_data_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.data"
		filename_nbline_by_user="${multi_pseudo[$cpt_user]}""_""nbline.tmp"
		nbline[$cpt_user]=0			

               	cat $BDD_veille_data_by_user | while read line
               	do
                       	((nbline[$cpt_user]++))
                       	echo "${nbline[$cpt_user]}" > $filename_nbline_by_user
               	done

               	#Test de la présence du fichier user_nbline.tmp
	        if [ -f "$filename_nbline_by_user" ] 
                then
                       	nbline[$cpt_user]=$(cat $filename_nbline_by_user)
               	fi
                ((cpt_user++))
	done

	if [ "$verbose" = "Activé" ]; then echo -e "Compte du nombre de liens.......\033[32mFait\033[00m"; fi
}

#Génération du document final
Creat_finaldoc()
{
	if [ "$verbose" = "Activé" ]; then echo -e "Création du document final.......en cours"; fi
	BDD_veille_mail_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.mail"
        BDD_veille_data_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.data"
	BDD_veille_MEF_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.mef"
	BDD_veille_MEFtmp_by_user="${multi_pseudo[$cpt_user]}""_""BDD_veille.mef.tmp"
			
	#Mise en forme du MEF
        echo '<!doctype html>' >> $BDD_veille_MEF_by_user
	echo '<html lang="fr">' >> $BDD_veille_MEF_by_user
        echo '<head>' >> $BDD_veille_MEF_by_user
      	echo '<meta charset="utf-8">' >> $BDD_veille_MEF_by_user
    	echo '<title>[Alert Qwant] Newsletter</title>' >> $BDD_veille_MEF_by_user
       	echo '<link rel="stylesheet" href="style.css">' >> $BDD_veille_MEF_by_user
       	echo '</head>' >> $BDD_veille_MEF_by_user
       	echo '<body>' >> $BDD_veille_MEF_by_user
       	echo '<img src="https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/QwantandBash.png" width="250" align="left" alt="Logo" /><br/><br/><br/>' >> $BDD_veille_MEF_by_user
      	echo "<br><p align="right"><font color="grey" >Newsletter du $jour_heure</font></p><br/>" >> $BDD_veille_MEF_by_user
	echo "<br><p align="left"><font color="black" >Bonjour ${multi_pseudo[$cpt_user]},</font></p><br/>" >> $BDD_veille_MEF_by_user

	cat $BDD_veille_data_by_user | sort >> $BDD_veille_mail_by_user
        poids_BDD_mail=$(ls -lh $BDD_veille_mail_by_user | cut -d ' ' -f5)

       	# Boucle de concaténation des résultats dans le fichier mis en forme
	cat $filename_keywords_list_tmp | while read line
        do
               	mot_clef=$(echo $line | sed s/'+'/' '/g)
               	vide=$(cat "${multi_pseudo[$cpt_user]}""_""$line"".data")
               	elem_comparaison="<br><br><b>""$mot_clef""<b><br>"
               	if [ "$vide" != "$elem_comparaison" ]
              	then
               	        cat "${multi_pseudo[$cpt_user]}""_""$line"".data" >> $BDD_veille_MEF_by_user
              		echo "" >> $BDD_veille_MEF_by_user
              	fi
               	done
			
		if [ "${multi_enable_save[$cpt_user]}" = "Oui" ]
               	then
			echo "" > $BDD_veille_MEFtmp_by_user
                       # Lecture des liens ligne par ligne pour ajouter le paramètre en URL
       	                cat $BDD_veille_MEF_by_user | while read line
               	        do
                       	        if [ "${line:0:2}" = "<a" ]
                               	then
                                       	link=$(echo $line | cut -d '"' -f2 | sed 's/\//\\\//g')
                                       	lien_sauv='\&\#8239\;\&\#8239\;\&\#8239\;\&\#8239\;<\/a><a href="https:\/\/cairn-devices.eu\/save_links.php?user='${multi_pseudo[$cpt_user]}'\&link='$link'" ><img src="https:\/\/raw.githubusercontent.com\/Gspohu\/Bash\/master\/alert_qwant\/ico_save.png" width="17"  alt="icon_save" \/><\/a>'
                              		echo $line | sed "s/<\/a>/$lien_sauv/g" >> $BDD_veille_MEFtmp_by_user
                               	else
                                       	echo $line >> $BDD_veille_MEFtmp_by_user
                               	fi
                       	done
			cat $BDD_veille_MEFtmp_by_user > $BDD_veille_MEF_by_user
               	fi

               	cat $BDD_veille_MEF_by_user | sed s/'\n'/'<br>'/g > BDD_veilleMEF.tmp
               	cat BDD_veilleMEF.tmp | sed s/'\/><\/a>'/'\/><\/a><br>'/g > $BDD_veille_MEF_by_user

               	echo '<br/><br/><br/><br/><center><font color="grey" size="1pt"> Powered by <img src="https://raw.githubusercontent.com/Gspohu/Bash/master/alert_qwant/Qwant_lite_logo.jpg" width="80"  alt="Logo_qwant_lite" /><br/>Le logo de Qwant et le logo de Bash sont la propriété de leur auteurs respectif. En cas de réclamation ou de problème me contacter sur https://github.com/Gspohu</font></center>' >> $BDD_veille_MEF_by_user
               	echo '</body>' >> $BDD_veille_MEF_by_user
               	echo '</html>' >> $BDD_veille_MEF_by_user			

		if [ "${multi_choix_mail_ou_fichier[$cpt_user]}" = "mail" ] || [ "$mail" = "Activé" ] && [ "$fichier" != "Activé" ]
               	then
                       	mail -s "$(echo -e "Newsletter de ${nbline[$cpt_user]} liens\nContent-Type: text/html")" ${multi_adresse_mail[$cpt_user]} < $BDD_veille_MEF_by_user
                       	echo "Un mail avec ${nbline[$cpt_user]} liens à été envoyé à ${multi_adresse_mail[$cpt_user]}" >> alert_qwant.log
                       	if [ "$verbose" = "Activé" ]; then echo -e "Un mail avec ${nbline[$cpt_user]} liens à été envoyé à ${multi_adresse_mail[$cpt_user]}"; fi
               	elif [ "${multi_choix_mail_ou_fichier[$cpt_user]}" = "fichier" ] || [ "$fichier" = "Activé" ]
               	then
                       	cat $BDD_veille_MEF_by_user > ${multi_chemin_fichier[$cpt_user]}/Newsletter-${multi_pseudo[$cpt_user]}.html
                       	echo "La newsletter avec ${nbline[$cpt_user]} liens est consultable ici ${multi_chemin_fichier[$cpt_user]}" >> alert_qwant.log
                       	if [ "$verbose" = "Activé" ]; then echo -e "La newsletter avec ${nbline[$cpt_user]} liens est consultable ici ${multi_chemin_fichier[$cpt_user]}"; fi
               	else
                       	echo "Choix mail ou fichier argument invalide" >> alert_qwant.log
                       	if [ "$verbose" = "Activé" ]; then echo -e "Choix mail ou fichier argument invalide"; fi
               	fi

               	echo "Le fichier $BDD_veille_mail_by_user de ${multi_pseudo[$cpt_user]} pèse $poids_BDD_mail" >> alert_qwant.log
               	if [ "$verbose" = "Activé" ]; then echo -e "Le fichier $BDD_veille_mail_by_user de ${multi_pseudo[$cpt_user]} pèse $poids_BDD_mail"; fi
}

Check_PHP_savepage()
{
	if [ ! -f "$adress_PHP_saver" ]
        then
		echo "La page PHP de sauvegarde des liens n'existe pas" >> alert_qwant.log
	        if [ "$verbose" = "Activé" ]; then echo -e "La page PHP de sauvegarde des liens n'existe pas";fi
		
		echo '<?php' >> $adress_PHP_saver_local
		echo "if (isset(\$_GET['user']) AND isset(\$_GET['link']))" >> $adress_PHP_saver_local
		echo '{' >> $adress_PHP_saver_local
		echo "\$user = htmlspecialchars(\$_GET['user']);" >> $adress_PHP_saver_local
		echo "\$link = htmlspecialchars(\$_GET['link']);" >> $adress_PHP_saver_local
		echo "\$comma = ',';" >> $adress_PHP_saver_local
		echo '$eol = "\n";' >> $adress_PHP_saver_local
		echo "\$BDD_noSQL = fopen('/home/alertqwant/BDD_links.csv', 'a');" >> $adress_PHP_saver_local
		echo 'fprintf( $BDD_noSQL, $user );' >> $adress_PHP_saver_local
		echo 'fprintf( $BDD_noSQL, $comma );' >> $adress_PHP_saver_local
		echo 'fprintf( $BDD_noSQL, $link );' >> $adress_PHP_saver_local
		echo 'fprintf( $BDD_noSQL, $eol );' >> $adress_PHP_saver_local
		echo 'fclose($BDD_noSQL);' >> $adress_PHP_saver_local
		echo 'echo "Le lien a bien ete sauvegarde, vous pouvez fermer la page"; ' >> $adress_PHP_saver_local
		echo '}' >> $adress_PHP_saver_local
		echo '?>' >> $adress_PHP_saver_local
		touch BDD_links.csv
		chmod 666 BDD_links.csv

		echo "La page PHP de sauvegarde des liens à été créé, pensez à la copier sur votre serveur web" >> alert_qwant.log
                if [ "$verbose" = "Activé" ]; then echo -e "\033[33mLa page PHP de sauvegarde des liens à été créé, pensez à la copier sur votre serveur web\033[00m";fi

	Stop_script
	fi	
if [ "$verbose" = "Activé" ]; then echo -e "Vérification de l'existance de la page PHP de sauvegarde des liens.......\033[32mFait\033[00m"; fi
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
cpt_user=0 # Compteur de lecture des profiles utilisateur
langue_dispo=( 'en' 'fr' 'de' 'es' 'it' 'pt' 'nl' 'ru' 'pl' 'zh' 'XYZcaseenplusXYZ' )
user="main"
adress_PHP_saver_local="/home/alertqwant/save_links.php"

Write_timestart_inlog

while [ $# -ge $cpt ] && [ $# -ge 1 ]
do
	Read_option "$1"
	shift #Permet de décalage du prochain paramètre dans la variable $1
	((cpt++))
done

Check_dependancy
Check_WhereamI
Check_sysfiles

Read_conffile
Check_read_conffile

Check_BBD_files
Check_keywords_lists

Check_PHP_savepage

Crontab_addrule

Search_links
Check_howmany_links

cpt_user=0
while [ $cpt_user -lt $nbuser ] 
do
	if [ ${nbline[$cpt_user]} -ge ${multi_nbliens_par_mail[$cpt_user]} ] || [ "$mail" = "Activé" ] || [ "$fichier" = "Activé" ]
	then
		Creat_finaldoc
		rm ${multi_pseudo[$cpt_user]}*.data>>alert_qwant.log 2>&1
	fi
	rm *.mef >>alert_qwant.log 2>&1
	((cpt_user++))
done


Stop_script
