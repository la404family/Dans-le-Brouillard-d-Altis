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
            };
        } forEach (units group player);
    };
};

// Boucle de regroupement limitée à 5 itérations (CORRIGÉE)
fnc_startRegroupLoop = {
    if (missionNamespace getVariable ["RegroupLoopActive", false]) exitWith {
        hint "Le regroupement est déjà actif !";
    };
    
    if !(call fnc_isPlayerLeader) exitWith {
        hint "Vous devez être le leader pour utiliser cette commande !";
    };
    
    missionNamespace setVariable ["RegroupLoopActive", true];
    hint "Regroupement des troupes activé (5 cycles)";
    
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
            
            // Afficher le compteur (optionnel)
            if (missionNamespace getVariable ["RegroupLoopActive", false]) then {
                hintSilent format ["Motivation des troupes: %1/2", _i];
            };
            
            sleep 15;
        };
        
        // Fin automatique après 5 cycles
        missionNamespace setVariable ["RegroupLoopActive", false];
        // dofollow a tous
        {
            if (!isPlayer _x && alive _x) then {
                _x doFollow player;
            };
        } forEach (units group player);
    };
};

// Fonction pour arrêter la boucle (CORRIGÉE)
fnc_stopRegroupLoop = {
    if !(missionNamespace getVariable ["RegroupLoopActive", false]) exitWith {
        hint "Aucun regroupement en cours";
    };
    
    missionNamespace setVariable ["RegroupLoopActive", false];
    hint "Regroupement des troupes arrêté";
};

// Variables globales pour le briefing
briefingActive = false;
briefingDisplay = displayNull;

// Fonction pour créer le briefing à la demande (INTERFACE PERSONNALISÉE AGRANDIE)
fnc_createBriefing = {
    if !(call fnc_isPlayerLeader) exitWith {
        hint "Seul le leader peut accéder au briefing";
    };
    
    // Fermer le briefing s'il est déjà ouvert
    if (briefingActive) exitWith {
        [] call fnc_closeBriefing;
    };
    
    briefingActive = true;
    
    // Créer l'affichage du briefing
    [] spawn {
        disableSerialization;
        
        // Créer le display principal
        _display = findDisplay 46 createDisplay "RscDisplayEmpty";
        briefingDisplay = _display;
        
        // Background semi-transparent 
        _background = _display ctrlCreate ["RscText", 1000];
        _background ctrlSetPosition [0.15, 0.1, 0.7, 0.8]; // Plus large et plus haut
        _background ctrlSetBackgroundColor [0, 0, 0, 0.85];
        _background ctrlCommit 0;
        
        // Bordure décorative
        _border = _display ctrlCreate ["RscFrame", 1004];
        _border ctrlSetPosition [0.15, 0.1, 0.7, 0.8];
        _border ctrlCommit 0;
        
        // Titre du briefing 
        _title = _display ctrlCreate ["RscStructuredText", 1001];
        _title ctrlSetPosition [0.18, 0.13, 0.64, 0.1]; // Plus large
        _title ctrlSetStructuredText parseText "<t size='2' color='#FF0000' align='center'>MISSION D'EXTRACTION</t>";
        _title ctrlCommit 0;
        
        // Contenu principal du briefing
        _content = _display ctrlCreate ["RscStructuredText", 1002];
        _content ctrlSetPosition [0.18, 0.25, 0.64, 0.55]; // Beaucoup plus grand
        _content ctrlSetStructuredText parseText "
        <t size='1.2' color='#FFFF00'>Renseignements opérationnels</t><br/>
- Localiser et escorter l'otage jusqu'au point d'extraction (P.E.) civil - voir GPS.<br/>
- Un drone de reconnaissance est en attente de votre arrivée pour déploiement sur zone.<br/>
- La portée de détection du drone est limitée, restez en alerte maximale.<br/>
- L'hélicoptère est un arsenal si vous avez besoin de changer vos équipements.<br/>
- Si l'allié au P.E. civil est neutralisé, évacuez l'otage vers le P.E. militaire (soldats) - voir GPS.<br/>
- Des commandes d'action sont disponibles pour la gestion tactique de l'escouade.<br/><br/>";
        _content ctrlCommit 0;
        
        // Bouton Fermer REPOSITIONNÉ
        _closeBtn = _display ctrlCreate ["RscButton", 1003];
        _closeBtn ctrlSetPosition [0.7, 0.82, 0.12, 0.06]; // Repositionné en bas à droite
        _closeBtn ctrlSetText "FERMER";
        _closeBtn ctrlSetTextColor [1, 1, 1, 1];
        _closeBtn ctrlSetBackgroundColor [0.8, 0.2, 0.2, 0.8];
        _closeBtn ctrlCommit 0;
        
        // Action du bouton fermer
        _closeBtn ctrlAddEventHandler ["ButtonClick", {
            [] call fnc_closeBriefing;
        }];
        
        // Fermeture automatique avec ESC
        _display displayAddEventHandler ["KeyDown", {
            params ["_display", "_key"];
            if (_key == 1) then { // ESC key
                [] call fnc_closeBriefing;
                true
            } else {
                false
            }
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

// Fonction pour les soins de groupe (AMÉLIORÉE)
fnc_groupHeal = {
    if !(call fnc_isPlayerLeader) exitWith {
        hint "Seul le leader peut donner cet ordre";
    };
    
    private _healedCount = 0;
    {
        if (!isPlayer _x && alive _x) then {
            // Vérifier si l'unité est blessée
            if (damage _x > 0.1) then {
                _x action ["HealSoldierSelf", _x];
                _healedCount = _healedCount + 1;
            };
        };
    } forEach (units group player);
    
};

// ========================================
// INITIALISATION DES ACTIONS
// ========================================

// Attendre que le joueur soit complètement initialisé
waitUntil {!isNull player && alive player};
sleep 1; // Petit délai pour s'assurer que tout est chargé

// Vérifier le leadership et ajouter les actions
if (call fnc_isPlayerLeader) then {
    
    // Action pour afficher le briefing (PRIORITÉ HAUTE)
    player addAction [
        "<t color='#00FFFF'>Afficher le briefing</t>",
        {[] call fnc_createBriefing;},
        [],
        10, // Priorité élevée
        true,
        true,
        "",
        "call fnc_isPlayerLeader"
    ];
    
    // Action pour activer le regroupement
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
    
    // Action pour désactiver le regroupement
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
    
    // Action pour ordonner les soins
    player addAction [
        "<t color='#FF0080'>Soignez vous !</t>",
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

// ========================================
// EVENT HANDLERS POUR GESTION AVANCÉE
// ========================================

// Event handler pour nettoyer si le joueur change de statut
[] spawn {
    while {alive player} do {
        // Si le joueur n'est plus leader et qu'un regroupement est actif
        if (!(call fnc_isPlayerLeader) && (missionNamespace getVariable ["RegroupLoopActive", false])) then {
            missionNamespace setVariable ["RegroupLoopActive", false];
            hint "Regroupement arrêté : leadership perdu";
        };
        sleep 5;
    };
};

// Nettoyage à la mort du joueur
player addEventHandler ["Killed", {
    missionNamespace setVariable ["RegroupLoopActive", false];
    [] call fnc_closeBriefing; // Fermer le briefing si ouvert
}];
