// ========================================
// SYSTÈME DE BRIEFING ET COMMANDES - VERSION CORRIGÉE
// ========================================

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
        for "_i" from 1 to 5 do {
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
                hintSilent format ["Motivation des troupes: %1/5", _i];
            };
            
            sleep 15;
        };
        
        // Fin automatique après 5 cycles
        missionNamespace setVariable ["RegroupLoopActive", false];
        hint "Cycle de motivation terminé";
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

// Fonction pour créer le briefing à la demande (INTERFACE PERSONNALISÉE)
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
        _background ctrlSetPosition [0.25, 0.15, 0.5, 0.7];
        _background ctrlSetBackgroundColor [0, 0, 0, 0.8];
        _background ctrlCommit 0;
        
        // Titre du briefing
        _title = _display ctrlCreate ["RscStructuredText", 1001];
        _title ctrlSetPosition [0.27, 0.18, 0.46, 0.08];
        _title ctrlSetStructuredText parseText "<t size='1.5' color='#FF0000' align='center'>MISSION D'EXTRACTION</t>";
        _title ctrlCommit 0;
        
        // Contenu principal du briefing
        _content = _display ctrlCreate ["RscStructuredText", 1002];
        _content ctrlSetPosition [0.27, 0.28, 0.46, 0.45];
        _content ctrlSetStructuredText parseText "
        <t size='1.1' color='#FFFF00'>SITUATION :</t><br/>
        Un ancien soldat a été kidnappé par des forces ennemies. L'<t color='#00FF00'>otage a été localisé</t> dans une zone contrôlée par l'ennemi.<br/><br/>
        Nous attendons votre présence pour déployer un drone dans zone qui vous indiquera les positions ennemies.
        <t size='1.1' color='#FFFF00'>OBJECTIF :</t><br/>
        Récupérer l'ancien soldat kidnappé et le ramener sain et sauf à son point d'extraction. Un <t color='#00FF00'>camion allié</t> vous attend au point d'extraction (civil).<br/><br/>
        Si l'<t color='#00FF00'>allié</t> est repéré, prennez l'ancien soldat avec vous dans l'hélicoptère.
        <t size='1.1' color='#FFFF00'>COMMANDEMENT :</t><br/>
        Des commandes d'action sont disponibles pour le leader du groupe :<br/>
        • <t color='#00FF00'>Motiver les troupes</t> : Regroupement automatique (5 cycles)<br/>
        • <t color='#00FF00'>Cesser la motivation</t> : Arrêt du regroupement<br/>
        • <t color='#00FF00'>Soignez vous !</t> : Ordre de soins aux IA<br/><br/>
        
        <t size='1.1' color='#FFFF00'>INSTRUCTIONS :</t><br/>
        - Localisez et escortez l'otage<br/>
        - Escortez l'otage jusqu'au point d'extraction <br/>
        - Restez vigilants la zone de détection du drone est limitée<br/><br/>
        
        <t size='1.2' color='#FF6600'>Bonne chance, oldats!</t>
        ";
        _content ctrlCommit 0;
        
        // Bouton Fermer
        _closeBtn = _display ctrlCreate ["RscButton", 1003];
        _closeBtn ctrlSetPosition [0.6, 0.75, 0.12, 0.06];
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
        
        hint "Briefing affiché ! (ESC ou bouton FERMER pour fermer)";
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
        "<t color='#00FFFF'>Afficher/Fermer briefing</t>",
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
        "call fnc_isPlayerLeader && !(missionNamespace getVariable ['RegroupLoopActive', false])"
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
        "call fnc_isPlayerLeader && (missionNamespace getVariable ['RegroupLoopActive', false])"
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
    
} 

// ========================================
// EVENT HANDLERS POUR GESTION AVANCÉE
// ========================================

// Event handler pour nettoyer si le joueur change de statut
[] spawn {
    while {alive player} do {
        // Si le joueur n'est plus leader et qu'un regroupement est actif
        if (!(call fnc_isPlayerLeader) && (missionNamespace getVariable ["RegroupLoopActive", false])) then {
            missionNamespace setVariable ["RegroupLoopActive", false];
        };
        sleep 5;
    };
};

// Nettoyage à la mort du joueur
player addEventHandler ["Killed", {
    missionNamespace setVariable ["RegroupLoopActive", false];
    [] call fnc_closeBriefing; // Fermer le briefing si ouvert
}];

hint "Système de briefing initialisé !";