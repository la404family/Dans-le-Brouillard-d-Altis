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

// Faire monter l'équipe d'appui
if (!isNull _equipeAPPUI) then {
    private _piloteEquipeAppui = leader _equipeAPPUI;
    
    // Assigner le pilote
    if (!isNull _piloteEquipeAppui && alive _piloteEquipeAppui) then {
        _piloteEquipeAppui assignAsDriver heliBLUFOR;
        _piloteEquipeAppui moveInDriver heliBLUFOR;
        sleep 1;
        
        // Configurer le pilote
        _piloteEquipeAppui setSkill 1;
        _piloteEquipeAppui setBehaviour "CARELESS";
        _piloteEquipeAppui disableAI "AUTOCOMBAT";
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

// Allumer le moteur de l'hélicoptère
heliBLUFOR engineOn true;

// Créer un waypoint pour le décollage et le déplacement
if (!isNull heliBLUFOR && alive (driver heliBLUFOR)) then {
    private _groupHeli = group (driver heliBLUFOR);
    
    // Supprimer les waypoints existants pour éviter les conflits
    while {(count (waypoints _groupHeli)) > 0} do {
        deleteWaypoint [_groupHeli, 0];
    };
    
    // Ajouter un waypoint pour décoller et se déplacer
    private _wp = _groupHeli addWaypoint [[5000, 5000, 500], 0]; // [[longitude, latitude, altitude], 0]
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "CARELESS";
    _wp setWaypointSpeed "FULL";
    _wp setWaypointStatements ["true", "vehicle this land 'GET OUT';"];
    
    // Forcer l'hélicoptère à décoller
    heliBLUFOR doMove [5000, 5000, 500];
};
heliBLUFOR doMove [5000, 5000, 500];
// Fin de mission
sleep 55;
["Mission accomplie. Extraction réussie."] remoteExec ["systemChat", 0];
sleep 55;
["END1", true] remoteExec ["BIS_fnc_endMission", 0];