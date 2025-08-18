// Initialisation de la variable globale pour contrôler la boucle
missionNamespace setVariable ["RegroupLoopActive", false];

// Fonction pour vérifier si le joueur est le leader
fnc_isPlayerLeader = {
    player == leader group player
};



// Fonction pour ordonner aux IA de se regrouper
fnc_regroupAI = {
    if !(missionNamespace getVariable ["RegroupLoopActive", false]) exitWith {};
    
    // Vérifie que le joueur est toujours le leader
    if (call fnc_isPlayerLeader) then {
        {
            if (!isPlayer _x && alive _x) then {
                // Génère une position aléatoire dans un rayon de 9 mètres autour du joueur
                private _pos = [position player, 9, random 360] call BIS_fnc_relPos;
                _x doMove _pos;
                
                // Ajouter des compétences (optimisé)
                _x setSkill ["aimingAccuracy", 0.9];
                _x setSkill ["aimingShake", 0.7];
                _x setSkill ["aimingSpeed", 0.85];
                _x setSkill ["endurance", 0.9];
                _x setSkill ["spotDistance", 0.85];
                _x setSkill ["spotTime", 0.8];
                _x setSkill ["courage", 1.0];
                _x setSkill ["reloadSpeed", 0.8];
                _x setSkill ["commanding", 0.6];
                _x setSkill ["general", 0.8];
// Liste de réponses possibles pour les IA motivées
private _motivationResponses = [
    "À vos ordres, chef ! On se regroupe !",
    "C'est parti, on suit le plan !",
    "On reste serrés, patron !",
    "Prêt à bouger, donnez l'ordre !",
    "On se replie sur vous, commandant !",
    "Motivation au max, on y va !",
    "On vous couvre, chef, c'est quoi la suite ?",
    "Regroupement en cours, restez sur vos gardes !"
];
                // Faire parler l'IA avec une réponse aléatoire
                _x groupChat (selectRandom _motivationResponses);
            };
        } forEach (units group player);
    };
};

// Boucle de regroupement limitée à 2 itérations
fnc_startRegroupLoop = {
    if (missionNamespace getVariable ["RegroupLoopActive", false]) exitWith {
        hint "Le regroupement est déjà actif !";
    };
    
    if !(call fnc_isPlayerLeader) exitWith {
        hint "Vous devez être le leader pour utiliser cette commande !";
    };
    
    missionNamespace setVariable ["RegroupLoopActive", true];
    hint "Regroupement des troupes activé (2 cycles)";
    
    // Lancer la boucle dans un thread séparé
    [] spawn {
        for "_i" from 1 to 2 do {
            // Vérifier si la boucle doit continuer
            if !(missionNamespace getVariable ["RegroupLoopActive", false]) exitWith {};
            
            // Vérifier si le joueur est toujours leader
            if !(call fnc_isPlayerLeader) exitWith {
                missionNamespace setVariable ["RegroupLoopActive", false];
                hint "Regroupement arrêté : vous n'êtes plus le leader";
            };
            
            call fnc_regroupAI;
            
            // Afficher le compteur
            if (missionNamespace getVariable ["RegroupLoopActive", false]) then {
                hintSilent format ["Motivation des troupes : %1/2", _i];
            };
            
            sleep 15;
        };
        
        // Fin automatique après 2 cycles
        missionNamespace setVariable ["RegroupLoopActive", false];
        // doFollow pour tous
        {
            if (!isPlayer _x && alive _x) then {
                _x doFollow player;
                _x groupChat "Regroupement terminé, on vous suit, chef !";
            };
        } forEach (units group player);
        hint "Regroupement terminé.";
    };
};

// Fonction pour arrêter la boucle
fnc_stopRegroupLoop = {
    if !(missionNamespace getVariable ["RegroupLoopActive", false]) exitWith {
        hint "Aucun regroupement en cours";
    };
    
    missionNamespace setVariable ["RegroupLoopActive", false];
    {
        if (!isPlayer _x && alive _x) then {
            _x groupChat "Ordre reçu, on arrête le regroupement.";
        };
    } forEach (units group player);
    hint "Regroupement des troupes arrêté";
};

// Variables globales pour le briefing
briefingActive = false;
briefingDisplay = displayNull;

// Fonction pour créer le briefing
fnc_createBriefing = {
    if !(call fnc_isPlayerLeader) exitWith {
        hint "Seul le leader peut accéder au briefing";
    };
    
    if (briefingActive) exitWith {
        [] call fnc_closeBriefing;
    };
    
    briefingActive = true;
    
    // Créer l'affichage du briefing
    [] spawn {
        disableSerialization;
        
        // Créer le display principal
        private _display = findDisplay 46 createDisplay "RscDisplayEmpty";
        briefingDisplay = _display;
        
        // Configuration des dimensions et positions
        private _windowW = 0.7;
        private _windowH = 0.8;
        private _windowX = safeZoneX + (safeZoneW - _windowW) / 2;
        private _windowY = safeZoneY + (safeZoneH - _windowH) / 2;
        
        // Background semi-transparent
        private _background = _display ctrlCreate ["RscText", 1000];
        _background ctrlSetPosition [_windowX, _windowY, _windowW, _windowH];
        _background ctrlSetBackgroundColor [0.05, 0.05, 0.05, 0.9];
        _background ctrlCommit 0;
        
        // Bordure décorative
        private _border = _display ctrlCreate ["RscFrame", 1004];
        _border ctrlSetPosition [_windowX, _windowY, _windowW, _windowH];
        _border ctrlSetTextColor [0.2, 0.8, 0.2, 0.7];
        _border ctrlCommit 0;
        
        // Titre du briefing
        private _title = _display ctrlCreate ["RscStructuredText", 1001];
        _title ctrlSetPosition [_windowX + 0.02, _windowY + 0.02, _windowW - 0.04, 0.08];
        _title ctrlSetStructuredText parseText "<t size='1.4' color='#32F842' shadow='2' align='center' font='PuristaBold'>MISSION D'EXTRACTION</t>";
        _title ctrlSetBackgroundColor [0, 0, 0, 0.2];
        _title ctrlCommit 0;
        
        // Séparateur
        private _separator = _display ctrlCreate ["RscText", 1005];
        _separator ctrlSetPosition [_windowX + 0.05, _windowY + 0.12, _windowW - 0.1, 0.002];
        _separator ctrlSetBackgroundColor [0.2, 0.8, 0.2, 0.6];
        _separator ctrlCommit 0;
        
        // Contenu principal du briefing
        private _content = _display ctrlCreate ["RscStructuredText", 1002];
        _content ctrlSetPosition [_windowX + 0.05, _windowY + 0.20, _windowW - 0.1, _windowH - 0.25];
        _content ctrlSetStructuredText parseText "
            <t size='1.1' color='#FFD700' font='PuristaSemiBold'>RENSEIGNEMENTS OPÉRATIONNELS</t><br/><br/>
            <t size='0.95' color='#FFFFFF' align='left'>
        Localiser et escorter l'otage jusqu'au point d'extraction civil (P.E.) - voir GPS.<br/>
        Si l'allié au P.E. civil est neutralisé, évacuer l'otage vers le P.E. militaire - voir GPS.<br/>
        Un drone de reconnaissance est disponible pour déploiement sur zone.<br/>
        La portée de détection du drone est limitée (zone orange sur GPS), restez en alerte.<br/>
        L'hélicoptère sert d'arsenal pour modifier votre équipement.<br/>
        Des commandes tactiques sont disponibles pour gérer l'escouade.<br/>
        Tous les membres du groupe doivent être dans l'hélicoptère pour l'extraction.<br/>
            </t>";
        _content ctrlSetBackgroundColor [0, 0, 0, 0.1];
        _content ctrlCommit 0;
        
        // Bouton Fermer
        private _closeBtn = _display ctrlCreate ["RscButtonMenu", 1003];
        _closeBtn ctrlSetPosition [_windowX + _windowW - 0.15, _windowY + _windowH - 0.08, 0.12, 0.05];
        _closeBtn ctrlSetText "FERMER";
        _closeBtn ctrlSetFont "PuristaBold";
        _closeBtn ctrlSetTextColor [1, 1, 1, 1];
        _closeBtn ctrlSetBackgroundColor [0.7, 0.1, 0.1, 0.9];
        _closeBtn ctrlSetActiveColor [1, 0.2, 0.2, 1];
        _closeBtn ctrlCommit 0;
        
        // Action du bouton fermer
        _closeBtn ctrlAddEventHandler ["ButtonClick", {
            [] call fnc_closeBriefing;
        }];
        
        // Fermeture automatique avec ESC
        _display displayAddEventHandler ["KeyDown", {
            params ["_display", "_key"];
            if (_key == 1) then {
                [] call fnc_closeBriefing;
                true
            } else {
                false
            };
        }];
    };
};

// Fonction pour fermer le briefing
fnc_closeBriefing = {
    if (briefingActive) then {
        briefingActive = false;
        if (!isNull briefingDisplay) then {
            briefingDisplay closeDisplay 1;
            briefingDisplay = displayNull;
        };
    };
};

// Fonction pour les soins de groupe
fnc_groupHeal = {
    if !(call fnc_isPlayerLeader) exitWith {
        hint "Seul le leader peut donner cet ordre";
    };
    
    private _healedCount = 0;
    {
        if (!isPlayer _x && alive _x) then {
            if (damage _x > 0.1) then {
                _x action ["HealSoldierSelf", _x];
                _x groupChat "Merci chef, je me soigne !";
                _healedCount = _healedCount + 1;
            };
        };
    } forEach (units group player);
    if (_healedCount > 0) then {
        hint format ["%1 unité(s) soignée(s).", _healedCount];
    } else {
        hint "Aucune unité blessée à soigner.";
    };
};

// INITIALISATION DES ACTIONS
waitUntil {!isNull player && alive player};
sleep 1;

if (call fnc_isPlayerLeader) then {
    player addAction [
        "<t color='#00FFFF'>Afficher le briefing</t>",
        {[] call fnc_createBriefing;},
        [],
        10,
        true,
        true,
        "",
        "call fnc_isPlayerLeader"
    ];
    
    player addAction [
        "<t color='#00FF00'>Motiver les troupes</t>",
        {[] call fnc_startRegroupLoop;},
        [],
        6,
        true,
        true,
        "",
        "call fnc_isPlayerLeader"
    ];
    
    player addAction [
        "<t color='#FF6600'>Cesser la motivation</t>",
        {[] call fnc_stopRegroupLoop;},
        [],
        5,
        true,
        true,
        "",
        "call fnc_isPlayerLeader"
    ];
    
    player addAction [
        "<t color='#FF0080'>Soignez-vous !</t>",
        {[] call fnc_groupHeal;},
        [],
        5,
        true,
        true,
        "",
        "call fnc_isPlayerLeader"
    ];
} else {
    hint "Vous n'êtes pas le leader du groupe";
};

// EVENT HANDLERS
[] spawn {
    while {alive player} do {
        if (!(call fnc_isPlayerLeader) && (missionNamespace getVariable ["RegroupLoopActive", false])) then {
            missionNamespace setVariable ["RegroupLoopActive", false];
            hint "Regroupement arrêté : leadership perdu";
        };
        sleep 5;
    };
};

player addEventHandler ["Killed", {
    missionNamespace setVariable ["RegroupLoopActive", false];
    [] call fnc_closeBriefing;
}];