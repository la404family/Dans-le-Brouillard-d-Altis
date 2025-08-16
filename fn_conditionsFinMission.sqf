private _playersArray = [player_1, player_2, player_3, player_4, player_5, 
                        player_6, player_7, player_8, player_9, player_10];
private _equipeAPPUI = equipeAPPUI;
private _playersValides = _playersArray select {!isNull _x && alive _x && isPlayer _x};

// Action initiale - Message aux joueurs
{
    if (isPlayer _x) then {
        ["Retournez au point d'extraction"] remoteExec ["systemChat", _x];
        
        private _task = _x createSimpleTask ["extraction"];
        _task setSimpleTaskDescription [
            "Rejoignez l'hélicoptère d'extraction", 
            "Extraction", 
            "Zone d'extraction"
        ];
        _task setSimpleTaskDestination (getPos heliBLUFOR);
        _x setCurrentTask _task;
    };
} forEach _playersValides;

// Créer un marqueur temporaire pour l'extraction
if (!isNull heliBLUFOR) then {
    private _markerExtraction = createMarker ["extraction_zone", getPos heliBLUFOR];
    _markerExtraction setMarkerType "hd_pickup";
    _markerExtraction setMarkerColor "ColorBLUFOR";
    _markerExtraction setMarkerText "Zone d'extraction";
    _markerExtraction setMarkerSize [1, 1];
};

// Boucle de vérification de proximité
private _extractionDeclenche = false;
private _timeout = time + 600;

while {!_extractionDeclenche && time < _timeout} do {
    sleep 2;
    {
        if (alive _x && _x distance heliBLUFOR <= 30) exitWith {
            _extractionDeclenche = true;
        };
    } forEach _playersValides;
};

// Vérifications avant décollage
if (!isNull heliBLUFOR) then {
    // Vérifier et réparer l'hélicoptère si nécessaire
    if (damage heliBLUFOR > 0) then {
        heliBLUFOR setDamage 0;
        ["Hélicoptère réparé."] remoteExec ["systemChat", 0];
    };
    
    // Vérifier et ajouter du carburant
    if (fuel heliBLUFOR < 0.2) then {
        heliBLUFOR setFuel 1;
        ["Hélicoptère ravitaillé."] remoteExec ["systemChat", 0];
    };
    
    // Déverrouiller et démarrer l'hélicoptère
    heliBLUFOR lock false;
    heliBLUFOR engineOn true;
    publicVariable "heliBLUFOR";
};

["Zone d'extraction atteinte. Préparation du décollage."] remoteExec ["systemChat", 0];

// Activer l'IA de l'équipe d'appui AVANT l'embarquement
if (!isNull _equipeAPPUI) then {
    // Réactiver toutes les capacités IA pour l'équipe d'appui
    {
        _x enableAI "PATH";
        _x enableAI "MOVE";
        _x enableAI "TARGET";
        _x enableAI "AUTOTARGET";
        _x enableAI "FSM";
        _x enableAI "TEAMSWITCH";
        _x enableAI "CHECKVISIBLE";
        _x enableAI "COVER";
        _x enableAI "SUPPRESSION";
        _x enableAI "AUTOCOMBAT";
        _x enableAI "RADIOPROTOCOL";
        _x setUnitPos "AUTO";
        doStop _x;
    } forEach (units _equipeAPPUI);
    
    // Utiliser heliBLUFORPILOT
    private _piloteEquipeAppui = heliBLUFORPILOT;
    
    // Assigner le pilote
    if (!isNull _piloteEquipeAppui && alive _piloteEquipeAppui) then {
        _piloteEquipeAppui assignAsDriver heliBLUFOR;
        _piloteEquipeAppui moveInDriver heliBLUFOR;
        sleep 1;
        
        // Configurer le pilote avec toutes les capacités IA nécessaires
        _piloteEquipeAppui enableAI "PATH";
        _piloteEquipeAppui enableAI "MOVE";
        _piloteEquipeAppui setSkill ["airportTaxi", 1];
        _piloteEquipeAppui setSkill ["general", 1];
        _piloteEquipeAppui setBehaviour "CARELESS";
        _piloteEquipeAppui setCombatMode "BLUE";
        _piloteEquipeAppui disableAI "AUTOCOMBAT";
        
        // Séparer le pilote dans un nouveau groupe
        private _nouveauGroupe = createGroup (side _piloteEquipeAppui);
        [_piloteEquipeAppui] joinSilent _nouveauGroupe;
    };
    
    // Faire monter le reste de l'équipe
    {
        if (_x != _piloteEquipeAppui && !isNull _x && alive _x) then {
            _x assignAsCargo heliBLUFOR;
            _x moveInCargo heliBLUFOR;
            sleep 0.5;
        };
    } forEach (units _equipeAPPUI);
};

// Faire monter les joueurs
{
    if (alive _x && isPlayer _x) then {
        [_x] joinSilent grpNull;
        _x assignAsCargo heliBLUFOR;
        [_x] orderGetIn true;
        ["Montée à bord de l'hélicoptère d'extraction."] remoteExec ["systemChat", _x];
    };
} forEach _playersValides;

// Compte à rebours
private _tempsRestant = 30;
playMusic "00outro";

while {_tempsRestant > 0} do {
    if (_tempsRestant in [30,10,5,3,2,1]) then {
        private _message = format ["Décollage dans %1 seconde%2", _tempsRestant, if (_tempsRestant > 1) then {"s"} else {""}];
        [_message] remoteExec ["systemChat", 0];
    };
    sleep 1;
    _tempsRestant = _tempsRestant - 1;
};

deleteMarker "extraction_zone";
["Décollage immédiat !"] remoteExec ["systemChat", 0];

// DÉCOLLAGE - Structure corrigée
heliBLUFOR lock 2;
heliBLUFOR engineOn true;

if (!isNull heliBLUFOR && alive heliBLUFORPILOT && vehicle heliBLUFORPILOT == heliBLUFOR) then {
    private _groupHeli = group heliBLUFORPILOT;
    
    // Supprimer les waypoints existants pour éviter les conflits
    while {(count (waypoints _groupHeli)) > 0} do {
        deleteWaypoint [_groupHeli, 0];
    };
    
    // Ajouter un waypoint pour décoller et se déplacer
    private _wp = _groupHeli addWaypoint [[5000, 5000, 500], 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "CARELESS";
    _wp setWaypointCombatMode "BLUE";
    _wp setWaypointSpeed "FULL";
    _wp setWaypointCompletionRadius 100;
    
    // Ordre direct au pilote
    heliBLUFORPILOT doMove [5000, 5000, 500];
    ["Décollage avec pilote IA"] remoteExec ["systemChat", 0];
} else {
    // Décollage de secours si pas de pilote
    heliBLUFOR setVelocity [0, 0, 8];
    ["Décollage automatique"] remoteExec ["systemChat", 0];
};


// Vérification finale de la mission
private _joueurPrincipal = if (!isNull player_1) then {player_1} else {player};

if (alive _joueurPrincipal && {_joueurPrincipal in crew heliBLUFOR}) then {
    ["Mission accomplie. Extraction réussie."] remoteExec ["systemChat", 0];
    sleep 55
    ["END1", true] remoteExec ["BIS_fnc_endMission", 0];
} else {
    ["Mission échouée. Extraction avortée."] remoteExec ["systemChat", 0];
    sleep 25
    ["END2", false] remoteExec ["BIS_fnc_endMission", 0];
};