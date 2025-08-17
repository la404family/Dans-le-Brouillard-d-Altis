private _playersArray = [player_1, player_2, player_3, player_4, player_5, player_6, player_7, player_8, player_9, player_10];
private _equipeAPPUI = equipeAPPUI;
private _playersValides = _playersArray select {!isNull _x && alive _x && isPlayer _x};

// Action initiale - Message aux joueurs
{
    if (isPlayer _x) then {
        ["Retournez au point d'extraction"] remoteExec ["systemChat", _x];
        private _task = _x createSimpleTask ["extraction"];
        _task setSimpleTaskDescription ["Rejoignez l'hélicoptère d'extraction", "Extraction", "Zone d'extraction"];
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
} else {
    ["ERREUR: Hélicoptère (heliBLUFOR) non défini"] remoteExec ["systemChat", 0];
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

["Zone d'extraction atteinte. Préparation du décollage."] remoteExec ["systemChat", 0];

// FORCER LES CAPACITÉS DE L'HÉLICOPTÈRE
if (!isNull heliBLUFOR) then {
    heliBLUFOR setDamage 0;
    heliBLUFOR setFuel 1;
    heliBLUFOR lock false;
    heliBLUFOR engineOn true;
    heliBLUFOR allowDamage false;
    publicVariable "heliBLUFOR";
    ["Hélicoptère préparé pour le décollage (réparé, ravitaillé, démarré)."] remoteExec ["systemChat", 0];
} else {
    ["ERREUR: Hélicoptère (heliBLUFOR) non défini"] remoteExec ["systemChat", 0];
    // Terminer la mission immédiatement en cas d'erreur critique
    ["END2", false] remoteExec ["BIS_fnc_endMission", 0];
    terminate _thisScript;
};

// FORCER LE PILOTE
private _piloteChoisi = objNull;
if (!isNull heliBLUFORPILOT && alive heliBLUFORPILOT) then {
    _piloteChoisi = heliBLUFORPILOT;
} else {
    if (!isNull _equipeAPPUI && count units _equipeAPPUI > 0) then {
        private _membresVivants = (units _equipeAPPUI) select {alive _x};
        if (count _membresVivants > 0) then {
            _piloteChoisi = _membresVivants select 0;
        };
    };
};

// Si pas de pilote trouvé, créer une unité pilote
if (isNull _piloteChoisi) then {
    private _group = createGroup west;
    _piloteChoisi = _group createUnit ["B_Helipilot_F", getPos heliBLUFOR, [], 0, "NONE"];
    _piloteChoisi setSkill 1;
    ["Pilote d'urgence créé."] remoteExec ["systemChat", 0];
};

// CONFIGURATION FORCÉE DU PILOTE
if (!isNull _piloteChoisi && alive _piloteChoisi) then {
    if (vehicle _piloteChoisi != _piloteChoisi) then {
        unassignVehicle _piloteChoisi;
        _piloteChoisi action ["GetOut", vehicle _piloteChoisi];
        sleep 1;
    };
    if (_piloteChoisi distance heliBLUFOR > 10) then {
        _piloteChoisi setPos (heliBLUFOR modelToWorld [3, 0, 0]);
        sleep 0.5;
    };
    _piloteChoisi assignAsDriver heliBLUFOR;
    _piloteChoisi moveInDriver heliBLUFOR;
    sleep 1;
    _piloteChoisi enableAI "ALL";
    _piloteChoisi setSkill ["general", 1];
    _piloteChoisi setBehaviour "CARELESS";
    _piloteChoisi setCombatMode "BLUE";
    _piloteChoisi setSpeedMode "FULL";
    private _nouveauGroupe = createGroup (side _piloteChoisi);
    [_piloteChoisi] joinSilent _nouveauGroupe;
    ["Pilote configuré et installé: " + name _piloteChoisi] remoteExec ["systemChat", 0];
} else {
    ["ERREUR: Aucun pilote valide trouvé"] remoteExec ["systemChat", 0];
};

// EMBARQUER L'ÉQUIPE D'APPUI (sauf le pilote)
if (!isNull _equipeAPPUI) then {
    {
        if (_x != _piloteChoisi && !isNull _x && alive _x) then {
            if (vehicle _x != _x) then {
                unassignVehicle _x;
                _x action ["GetOut", vehicle _x];
                sleep 0.5;
            };
            if (_x distance heliBLUFOR > 15) then {
                _x setPos (heliBLUFOR modelToWorld [5, 5, 0]);
                sleep 0.3;
            };
            _x assignAsCargo heliBLUFOR;
            _x moveInAny heliBLUFOR; // Utiliser moveInAny pour garantir l'embarquement
            sleep 0.5;
        };
    } forEach (units _equipeAPPUI);
};

// SÉPARER ET EMBARQUER LES JOUEURS
{
    if (alive _x && isPlayer _x) then {
        // Séparer le joueur de son groupe actuel
        [_x] joinSilent grpNull;
        // Sortir le joueur de son véhicule actuel
        if (vehicle _x != _x) then {
            unassignVehicle _x;
            _x action ["GetOut", vehicle _x];
            sleep 0.5;
        };
        // Téléporter près de l'hélicoptère si nécessaire
        if (_x distance heliBLUFOR > 15) then {
            _x setPos (heliBLUFOR modelToWorld [-5, 5, 0]);
            sleep 0.3;
        };
        // Forcer l'embarquement
        _x assignAsCargo heliBLUFOR;
        _x moveInAny heliBLUFOR; // Utiliser moveInAny pour garantir l'embarquement
        ["Joueur " + name _x + " forcé à bord de l'hélicoptère."] remoteExec ["systemChat", _x];
        sleep 0.5;
    };
} forEach _playersValides;

// EMBARQUER L'OTAGE SI VIVANT
if (!isNull hostageVIP && alive hostageVIP) then {
    if (hostageVIP distance heliBLUFOR > 15) then {
        hostageVIP setPos (heliBLUFOR modelToWorld [0, -5, 0]);
        sleep 0.5;
    };
    hostageVIP assignAsCargo heliBLUFOR;
    hostageVIP moveInAny heliBLUFOR;
    ["Otage embarqué."] remoteExec ["systemChat", 0];
};

// Compte à rebours de 55 secondes
private _tempsRestant = 55;
playMusic "00outro";

// Supprimer les tâches au début du compte à rebours
{
    if (isPlayer _x && alive _x) then {
        _x removeSimpleTask (_x getVariable ["task_extraction", taskNull]);
    };
} forEach _playersValides;

// COMPTE À REBOURS AVEC MESSAGES
while {_tempsRestant > 0} do {
    if (_tempsRestant in [55, 45, 30, 20, 10, 5, 3, 2, 1]) then {
        private _message = format ["Décollage dans %1 seconde%2", _tempsRestant, if (_tempsRestant > 1) then {"s"} else {""}];
        [_message] remoteExec ["systemChat", 0];
    };
    // Vérifier que le pilote reste dans l'hélicoptère
    if (!isNull _piloteChoisi && alive _piloteChoisi && vehicle _piloteChoisi != heliBLUFOR) then {
        _piloteChoisi moveInDriver heliBLUFOR;
    };
    sleep 1;
    _tempsRestant = _tempsRestant - 1;
};

deleteMarker "extraction_zone";
["Décollage forcé !"] remoteExec ["systemChat", 0];

// VERROUILLAGE FINAL ET DÉCOLLAGE FORCÉ
heliBLUFOR lock 0;
heliBLUFOR engineOn true;

// FORCER LE DÉCOLLAGE AVEC DIRECTION
if (!isNull _piloteChoisi && alive _piloteChoisi && !isNull heliBLUFOR && !isNull directionDroneFinDeMission) then {
    private _groupHeli = group _piloteChoisi;
    while {count (waypoints _groupHeli) > 0} do {
        deleteWaypoint [_groupHeli, 0];
    };
    private _destination = getPos directionDroneFinDeMission;
    _destination set [2, (_destination select 2) + 200]; // 200 = altitude de vol
    private _wp = _groupHeli addWaypoint [_destination, 0];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "CARELESS";
    _wp setWaypointCombatMode "BLUE";
    _wp setWaypointSpeed "FULL";
    _wp setWaypointCompletionRadius 100;
    _piloteChoisi doMove _destination;
    _piloteChoisi commandMove _destination;
    heliBLUFOR flyInHeight 150;
    ["Hélicoptère en décollage forcé vers: " + str _destination] remoteExec ["systemChat", 0];
    ["Pilote: " + name _piloteChoisi] remoteExec ["systemChat", 0];
} else {
    ["ERREUR: Impossible de déterminer la destination ou le pilote"] remoteExec ["systemChat", 0];
    // Terminer la mission immédiatement en cas d'erreur critique
    ["END2", false] remoteExec ["BIS_fnc_endMission", 0];
    terminate _thisScript;
};

// Vérification de la mission
private _missionReussie = false;
if (!isNil "_playersValides" && !isNull heliBLUFOR) then {
    _missionReussie = _playersValides findIf {alive _x && isPlayer _x && _x in crew heliBLUFOR} != -1;
};

// TIMER DE 55 SECONDES APRÈS LE DÉCOLLAGE
private _finTimer = time + 55;
private _destination = getPos directionDroneFinDeMission;
_destination set [2, (_destination select 2) + 500];

while {time < _finTimer} do {
    private _secondesRestantes = round (_finTimer - time);
    if (_secondesRestantes in [45, 30, 20, 10, 5, 3, 2, 1]) then {
        if (_missionReussie) then {
            [format ["Mission accomplie ! Fin dans %1 seconde%2...", _secondesRestantes, if (_secondesRestantes > 1) then {"s"} else {""}]] remoteExec ["systemChat", 0];
        } else {
            [format ["Mission échouée ! Fin dans %1 seconde%2...", _secondesRestantes, if (_secondesRestantes > 1) then {"s"} else {""}]] remoteExec ["systemChat", 0];
        };
    };
    // Forcer le pilote à continuer vers la destination
    if (!isNull _piloteChoisi && alive _piloteChoisi) then {
        _piloteChoisi doMove _destination;
        _piloteChoisi commandMove _destination;
    };
    // Vérifier que les unités restent dans l'hélicoptère
    {
        if (alive _x && !(_x in crew heliBLUFOR) && _x distance heliBLUFOR < 50) then {
            _x moveInAny heliBLUFOR;
        };
    } forEach (_playersValides + (units _equipeAPPUI));
    sleep 1;
};

// RENDRE L'HÉLICOPTÈRE VULNÉRABLE À NOUVEAU
heliBLUFOR allowDamage true;

// FIN DE MISSION APRÈS 45 SECONDES
if (_missionReussie) then {
    ["Mission accomplie. Extraction réussie."] remoteExec ["systemChat", 0];
    ["END1", true] remoteExec ["BIS_fnc_endMission", 0];
} else {
    ["Mission échouée. Extraction avortée."] remoteExec ["systemChat", 0];
    {
        if (isPlayer _x) then {
            _x enableSimulation false;
        };
    } forEach _playersValides;
    ["END2", false] remoteExec ["BIS_fnc_endMission", 0];
};