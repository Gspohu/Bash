#!/bin/bash

#Initialisation des variables
install="curl" #Logiciel à installer nécéssaire pour le fonctionnement du script
indice="news-content" #Repère pour la div ou se trouve les résultats de la recherche
verif_installation=$(dpkg -s $install | grep Status) #Vérification que curl est installé
nbline=0
jour_heure=$(date +%d/%m/%y' à '%kh%M)

#Vérification de l'emplacement du script
ou_suis_je=$(pwd)"/alert_qwant.sh"
if [ ! -d "/srv/scripts/" ] #Vérification de l'existance du dossier scripts
then
        mkdir /srv/scripts
        echo "Le dossier scripts à été créé dans /srv/" >> /srv/scripts/alert_qwant.log
fi

if [ ! -f "/srv/scripts/alert_qwant.sh" ] #Vérification de l'existance du script alert_qwant.sh
then
        cp $ou_suis_je /srv/scripts/
        echo 'Erreur : Le script est mal placé. Il a été copier dans le repertoire /srv/scripts/'
        echo 'Erreur : Le script est mal placé. Il a été copier dans le repertoire /srv/scripts/' >> /srv/scripts/alert_qwant.log
        echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
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
        echo "Adresse mail : adresse@mail.eu" >> /srv/scripts/alert_qwant.conf
        echo "Création du fichier de configuration, alert_qwant.conf dans /srv/scripts/, avec les paramètres de bases. Pensez à changer l'adresse mail." >> /srv/scripts/alert_qwant.log
fi

if [ ! -f "/srv/scripts/Mots_clefs.list" ] # Test de la présence de la liste des mots clefs 
then
        echo 'Qwant' >> /srv/scripts/Mots_clefs.list
        echo 'Erreur : Votre liste de mots clefs est vide et a été créé automatiquement. Pensez à éditer le fichier Mots_clefs.list' >> /srv/scripts/alert_qwant.log
elif [ ! -f "/srv/scripts/BDD_veille.mail" ] # Test de la présence de la BDD des mails envoyés
then
        echo 'Historique des liens envoyé par mail' >> /srv/scripts/BDD_veille.mail
        echo "Le fichier de base de donnée de liens envoyé par mail a été créé" >> /srv/scripts/alert_qwant.log
fi

#Ecrire dans le log l'heure du lancement
echo "Lancement alert_qwant.sh le $jour_heure :" >> /srv/scripts/alert_qwant.log

#Lecture des options
if [ $# -ge 1 ]
then
	#Option de mise à jour
        if [ $1 = "--upgrade" ]
        then
                wget -q -P /tmp/ https://github.com/Gspohu/Bash/raw/master/alert_qwant/alert_qwant.sh
                diff_maj=$(diff /srv/scripts/alert_qwant.sh /tmp/alert_qwant.sh)
		if [ "$diff_maj" != "" ]
		then
			rm /srv/scripts/alert_qwant.sh
			mv /tmp/alert_qwant.sh /srv/scripts/alert_qwant.sh
			echo "Une mise à jour est disponible, elle à été téléchargé, alert_qwant est à jour " >> /srv/scripts/alert_qwant.log
		else
			rm /tmp/alert_qwant.sh
			echo "Aucune mise à jour disponible" >> /srv/scripts/alert_qwant.log
		fi
        elif [ $1 = "--dmail" ]
	then
		rm BDD_veille.mail
		echo "La base de donné de liens envoyés par mail à été vidé" >> /srv/scripts/alert_qwant.log
		echo 'Historique des liens envoyé par mail' >> /srv/scripts/BDD_veille.mail
	elif [ $1 = "--dlog" ] 
	then
		rm /srv/scripts/alert_qwant.log
		echo "Fichier log de alert_qwant" >> /srv/scripts/alert_qwant.log
	else
                echo 'Erreur : Option non reconnue'
        fi
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
fi

#Lecture du fichier de configuration
freq=$(cat /srv/scripts/alert_qwant.conf | grep -o Fréquence.* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
nbliens_mots_clefs=$(cat /srv/scripts/alert_qwant.conf | grep -o "Nombre de liens récupéré".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
nbliens_par_mail=$(cat /srv/scripts/alert_qwant.conf | grep -o "Nombre de liens envoyé".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
adresse_mail=$(cat /srv/scripts/alert_qwant.conf | grep -o "Adresse".* | head -n 1 | cut -d \:  -f 2 |cut -d\  -f 2)
freq_cron=$((24/$freq))

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
else
	rm /tmp/crontab_tmp.tmp
fi

if [ "$verif_installation" = "Status: install ok installed" ] # Test de l'installation de curl
then
	#Boucle pour rechercher les liens pour chaque mot clef
	cat /srv/scripts/Mots_clefs.list | while read line #Lecture ligne par ligne
	do
        	mots_clef=$line
        	moteur="https://lite.qwant.com/?lang=fr_fr&q=$mots_clef&t=news" #Lien du moteur de recherche
        	curl -s $moteur | grep -A 3 $indice | grep -o http[^\"]* | head -n $nbliens_mots_clefs | sed s/' '/'\n '/g >> /srv/scripts/BDD_veille.data #Récupération des liens sur le moteur

		#Vérification des doublons
        	cat /srv/scripts/BDD_veille.data | sort | uniq > /srv/scripts/BDD_veille.tmp
        	rm /srv/scripts/BDD_veille.data
        	mv /srv/scripts/BDD_veille.tmp /srv/scripts/BDD_veille.data
	done
	#Suppression des doublons entre les mails déjà envoyé et la BDD
        cat /srv/scripts/BDD_veille.data | sort > /srv/scripts/tmp
        cat /srv/scripts/BDD_veille.mail | sort >> /srv/scripts/tmp
        cat /srv/scripts/tmp | sort | uniq -d > /srv/scripts/tmp.tmp
        rm /srv/scripts/tmp
        cat /srv/scripts/BDD_veille.data >> /srv/scripts/tmp.tmp
        cat /srv/scripts/tmp.tmp | sort | uniq -u > /srv/scripts/BDD_veille.data
        rm /srv/scripts/tmp.tmp
else
	apt-get install $install #installation de curl
	echo "Le logiciel $install a été installé" >> /srv/scripts/alert_qwant.log
	echo "Fin de l'éxécution du programme avec une erreur critique, veuillez relancer" >> /srv/scripts/alert_qwant.log
fi

#Boucle pour le comptage des lignes du fichier de liens
cat /srv/scripts/BDD_veille.data | while read line
do
       	((nbline++))
	echo "$nbline" > /srv/scripts/nbline.tmp
	echo "Le fichier de base de donnée de veille contient $nbline liens" > /srv/scripts/alert_qwant.log.tmp
done

#Test pour le nombre maximum de lien
nbline=$(cat /srv/scripts/nbline.tmp)
rm /srv/scripts/nbline.tmp
if [ $nbline -ge $nbliens_par_mail ]
then
	mail -s "[Alert Qwant] Newsletter de $nbline liens" $adresse_mail < /srv/scripts/BDD_veille.data
        cat /srv/scripts/BDD_veille.data | sort >> /srv/scripts/BDD_veille.mail
        rm /srv/scripts/BDD_veille.data
        echo "Un mail avec $nbline liens à été envoyé" >> /srv/scripts/alert_qwant.log
        echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
        exit 0
fi

cat /srv/scripts/alert_qwant.log.tmp >> /srv/scripts/alert_qwant.log
rm /srv/scripts/alert_qwant.log.tmp
echo "Fin de l'éxécution du programme" >> /srv/scripts/alert_qwant.log
echo " " >> /srv/scripts/alert_qwant.log
exit 0
