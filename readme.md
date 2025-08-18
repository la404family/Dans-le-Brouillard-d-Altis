# Dans le brouillard d'Altis

Je vous partage la mission "Dans le brouillard d'Altis" que j'ai codé en sqf pour Arma 3.
Cette mission est une mission de type "mission de sauvetage" où les soldats BLUFOR doivent extraire un otage.

Vous arrivez au petit matin, le soleil va se lever dans les minutes qui vont suivre l'atterrissage.
L'objectif est de récupérer l'otage et de le ramener à un véhicule puis prendre un hélicoptère pour s'extraire de la zone.
Il y a un brouillard qui rend la vue limitée, il faut donc être prudent.
Quand vous serez proche de la cible, un drone survolera la zone pour détecter les ennemies et les indiquer sur la carte.

Des fonctions d'optimisation du suivi des IA sont implémentées dans la mission (boutton d'action : motiver vos troupes).
Le boutton d'action "Se soignez !" permet aux soldats IA de se soigner.
La mission est un échec si vous mourrez seulement.
Si l'otage meurt, retourner à l'hélicoptère en vie
Si le transporteur meurt, emmener l'otage avec vous dans l'hélcoptère.

Bonne chance !

## Variables en jeu

- hostageVIP est un civil otage dans le village
- ConducteurCamionExtractionOtage est le conducteur du camion qui va extraire l'otage
- camionExtractionOtage est le camion qui va extraire l'otage
- fn_ottageDansVehicule le déclancher qui dépose le hostageVIP dans le camion
- directionCamionExtraction est un objet vide dans le jeu qui permet de définir la direction du camion
- zoneCouvertureDrone est un marker qui permet de définir la zone de couverture du drone
- droneBLUFOR est le drone qui surveille la zone
- directionDroneFinDeMission est un objet vide dans le jeu qui permet de définir la direction du drone à la fin de la mission
- volEnAttente est un Waypoint qui permet de définir le vol en attente du drone
- heliport_01, heliport_02, heliport_03, heliport_04 sont les héliports de départ et d'arrivée de l'hélicoptère
- helimarker_01, helimarker_02, helimarker_03, helimarker_04 sont les marqueurs des héliports
- heliBLUFOR est l'hélicoptère BLUFOR
- heliBLUFORPILOT est le pilote de l'hélicoptère et le chef de groupe
- player_1, player_2, player_3, player_4, player_5, player_6, player_7, player_8, player_9, player_10 sont les joueurs
- equipeAPPUI est l'équipe du pilot heliBLUFORPILOT qui appuie les players

### Mise en place de la mission [1er partie]

- 1.[Conversion d'un civil en soldat BLUFOR](./fn_OtageDevientBLUFOR.sqf)
- 2.[Extraction de l'otage dans un véhicule](./fn_ottageDansVehicule.sqf)

[Regarder la vidéo sur YouTube](https://www.youtube.com/shorts/S-8VCvEvptc)

### Ajout de la zone de couverture du drone [2ème partie]

- 3.[Mettre les voix des BLUFOR et des civils en français](./fn_BLUFORenFR.sqf)
- 4.[Ajout de la zone de couverture du drone](./fn_zoneCouvertureDrone.sqf)

[Regarder la vidéo sur YouTube](https://www.youtube.com/shorts/kc7yryzdNM4)

### Ajout d'un lieu aléatoire pour l'atterrissage de départ [3ème partie]

- 5.[Changement des identités des BLUFOR](./fn_changementIdentite.sqf)
- 6.[Départ aléatoire de l'hélicoptère](./fn_departAleatoireHeliport.sqf)

### Intro et fin de mission [4ème partie]

- 7.[Conditions de fin de mission](./fn_conditionsFinMission.sqf)
- 8.[Introduction de la mission](./fn_introductionMission.sqf)
- 9.[Condition d'échec de la mission](./fn_echecMission.sqf)

### Ajout des actions de commandement [5ème partie]

- 10.[Création des actions de commandement](./fn_buttonActions.sqf)
- 11.[Ajout d'une lumière dans l'hélicoptère](./fn_lumiereHeli.sqf)
