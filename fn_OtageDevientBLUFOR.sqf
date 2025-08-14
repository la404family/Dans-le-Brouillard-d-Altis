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
	// Attendre 1 seconde 
	sleep 1;
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
		// nom du soldat BLUFOR : Mathieu Bernard
	// Code gérer dans le fichier description.ext
	hostageVIP setIdentity "OtageMathieu";
	// Restaurer l'identité
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
	// Attendre 1 seconde 
	sleep 3;
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
