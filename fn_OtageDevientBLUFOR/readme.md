# Dans le brouillard d'Altis

## Choix de l'emplacement de la mission

Le village de Chalkeia (Altis)

### Pourquoi ce lieu ?

| ![capture001](Capture001.jpg) |
| :---------------------------: |

- Il est situé dans une zone montagneuse, ce qui permet de profiter du relief pour contourner les unités ennemies.
- Aux alentours, il y a des zones de plateaux pour faire atterrir un hélicoptère.
- La végétation est assez dense, ce qui permet de se cacher.

## Par quoi commencer ?

- Avant de commencer, il faut définir et coder la logique de jeu.
- Choisir un otage
- Définir sa place dans la mission
- Mettre un trigger (déclencheur pour activer une fonction) autour de l'otage pour définir son statut.

| ![capture002](Capture002.jpg) |
| :---------------------------: |

| ![capture002bis](Capture002bis.jpg) |
| :---------------------------------: |

## Dans le dossier de la mission (paramétrage pour toutes les missions)

- Ouvrir les fichiers de la mission (Documents/Arma 3/dossier de votre profil/missions/nom_de_la_mission) dans un éditeur de code (VSCode, Notepad++, Cursor, etc.).
- Créer un fichier init.sqf pour la fonction de base du jeu.
- Créer un fichier description.ext pour la description de la mission, la gestion du son, les paramètres de la mission, etc.
- Définir dans le fichier init en commentaire tout ce que vous avez défini dans l'éditeur Arma 3.

## Comment coder une fonction (fonction de conversion de l'otage en soldat BLUFOR)

- Créer un fichier fn_OtageDevientBLUFOR.sqf pour la fonction de conversion de l'otage en soldat BLUFOR.
- Dans l'éditeur Arma 3, nommer le déclencheur (nom de variable) avec le même nom que la fonction.
- Dans la section "Quand activation" du déclencheur, mettre l'appel de la fonction "[] execVM "fn_OtageDevientBLUFOR.sqf";"
- Tout cela permet de mieux se repérer dans le code, dans l'éditeur Arma 3 et les objets présents dans la mission.

### Dans le déclencheur

| ![capture003](Capture003.jpg) |
| :---------------------------: |

### Dans l'onglet "Quand activation" du déclencheur

| ![capture004](Capture004.jpg) |
| :---------------------------: |

### Dans la liste des objets de la mission

| ![capture005](Capture005.jpg) |
| :---------------------------: |

### Dans l'éditeur de code de votre mission

| ![capture006](Capture006.jpg) |
| :---------------------------: |

## Code de la fonction "fn_OtageDevientBLUFOR.sqf" avec les commentaires

La fonction est codée en sqf, c'est un langage de script pour Arma 3.
Elle est composée de plusieurs parties :

- Vérifier si l'otage existe
- Sauvegarder les informations de l'otage
- Sauvegarder les vêtements et équipements de l'otage
- Sauvegarder l'inventaire de l'otage
  - Toutes ses sauvegardes sont faites dans des variables privées pour ne pas interférer avec le jeu.
  - Toutes les variables sont préfixées par un underscore "\_" pour les différencier des variables du jeu.
  - Toutes les variables sont définies pour que le BLUFOR soit le même que le civil .
- Supprimer l'otage
  - On supprime le civil car il aura du mal à suivre et ne sera pas poursuivi par les ennemies.
- Créer un nouveau soldat BLUFOR
  - On crée un nouveau soldat BLUFOR avec les mêmes informations que le civil.
- Restaurer la position et direction de l'otage
  - On restaure la position et la direction de l'otage avec un peut plus de hauteur pour ne pas qu'il se retrouve dans le sol ou à l'étage en dessous.
- Restaurer l'identité de l'otage
- Vider l'inventaire de l'otage
- Restaurer les vêtements de l'otage
- Rejoindre le groupe du joueur
- Sortir de l'animation actuelle
- Restaurer l'inventaire de l'otage
- Améliorer les compétences du nouveau soldat
- Définir le moral et le comportement du nouveau soldat
- Message de confirmation (facultatif peut servir uniquement lors du développement)

```sqf

// Vérifier si hostageVIP existe
	if (isNil "hostageVIP" || isNull hostageVIP) exitWith {
		hint "Erreur: hostageVIP n'existe pas ou est null";
		false
	};

	// Sauvegarder les informations du civil
	private _originalPos = getPosATL hostageVIP;  // Utilise getPosATL pour garder la hauteur relative
	private _originalDir = getDir hostageVIP;
	private _originalName = name hostageVIP;
	private _originalFace = face hostageVIP;
	private _originalSpeaker = speaker hostageVIP;
	private _originalPitch = pitch hostageVIP;

	// Sauvegarder les vêtements et équipements
	private _uniform = uniform hostageVIP;
	private _vest = vest hostageVIP;
	private _backpack = backpack hostageVIP;
	private _headgear = headgear hostageVIP;
	private _goggles = goggles hostageVIP;

	// Sauvegarder l'inventaire complet
	private _uniformItems = uniformItems hostageVIP;
	private _vestItems = vestItems hostageVIP;
	private _backpackItems = backpackItems hostageVIP;
	private _assignedItems = assignedItems hostageVIP;
	private _weapons = weapons hostageVIP;
	private _magazines = magazines hostageVIP;

	// Supprimer l'ancien civil
	deleteVehicle hostageVIP;

	// Créer un nouveau soldat BLUFOR
	private _newGroup = createGroup west;
	hostageVIP = _newGroup createUnit ["B_Soldier_F", _originalPos, [], 0, "NONE"];

	// Attendre que l'unité soit complètement créée
	waitUntil {!isNull hostageVIP};

	// Restaurer la position et direction
	hostageVIP setPosATL _originalPos;  // Utilise setPosATL pour maintenir la hauteur relative
	// ajouter 0.5 de hauteur pour ne pas qu'il se retrouve dans le sol ou à l'étage en dessous
	_originalPos set [2, (_originalPos select 2) + 0.5];
	hostageVIP setDir _originalDir;

	// Restaurer l'identité
	hostageVIP setName _originalName;
	hostageVIP setFace _originalFace;
	hostageVIP setSpeaker _originalSpeaker;
	hostageVIP setPitch _originalPitch;



	// Vider l'inventaire par défaut
	removeAllWeapons hostageVIP;
	removeAllItems hostageVIP;
	removeAllAssignedItems hostageVIP;
	removeUniform hostageVIP;
	removeVest hostageVIP;
	removeBackpack hostageVIP;
	removeHeadgear hostageVIP;
	removeGoggles hostageVIP;

	// Restaurer les vêtements
	if (_uniform != "") then { hostageVIP forceAddUniform _uniform; };
	if (_vest != "") then { hostageVIP addVest _vest; };
	if (_backpack != "") then { hostageVIP addBackpack _backpack; };
	if (_headgear != "") then { hostageVIP addHeadgear _headgear; };
	if (_goggles != "") then { hostageVIP addGoggles _goggles; };



	// Rejoindre le groupe du joueur
	[hostageVIP] joinSilent group player;
	// Sortir de l'animation actuelle
	hostageVIP switchMove "";
	sleep 2;
	hostageVIP playMove "";
	// Restaurer l'inventaire
	{hostageVIP addItemToUniform _x} forEach _uniformItems;
	{hostageVIP addItemToVest _x} forEach _vestItems;
	{hostageVIP addItemToBackpack _x} forEach _backpackItems;
	{hostageVIP linkItem _x} forEach _assignedItems;
	{hostageVIP addWeapon _x} forEach _weapons;
	{hostageVIP addMagazine _x} forEach _magazines;

	// Améliorer les compétences du nouveau soldat
	hostageVIP setSkill ["aimingAccuracy", 0.8];     // Précision de tir (0-1)
	hostageVIP setSkill ["aimingShake", 0.7];        // Stabilité de visée
	hostageVIP setSkill ["aimingSpeed", 0.75];       // Vitesse de visée
	hostageVIP setSkill ["endurance", 0.9];          // Endurance
	hostageVIP setSkill ["spotDistance", 0.85];      // Distance de détection
	hostageVIP setSkill ["spotTime", 0.8];           // Vitesse de détection
	hostageVIP setSkill ["courage", 1.0];            // Courage (0-1)
	hostageVIP setSkill ["reloadSpeed", 0.8];        // Vitesse de rechargement
	hostageVIP setSkill ["commanding", 0.6];         // Capacité de commandement
	hostageVIP setSkill ["general", 0.8];            // Compétence générale

	// Définir le moral et le comportement
	hostageVIP setBehaviour "AWARE";                 // Comportement alerte
	hostageVIP setCombatMode "YELLOW";               // Mode de combat défensif
	hostageVIP setSpeedMode "NORMAL";                // Vitesse de déplacement normale
	hostageVIP allowFleeing 0.1;                     // Résistance à la fuite (0-1, plus bas = moins de fuite)

	// S'assurer que l'IA fonctionne correctement
	hostageVIP enableAI "MOVE";
	hostageVIP enableAI "TARGET";
	hostageVIP enableAI "AUTOTARGET";
	hostageVIP enableAI "FSM";
	hostageVIP enableAI "TEAMSWITCH";
	hostageVIP enableAI "PATH";

	// Message de confirmation
	hint format ["%1 a été converti en soldat BLUFOR avec des compétences améliorées!", name hostageVIP];

	// Retourner true pour indiquer le succès
	true

```

_NOTE_ : Le message de confirmation est affiché pour vérifier que la fonction a été appelée correctement. On peut le supprimer si on le souhaite.
