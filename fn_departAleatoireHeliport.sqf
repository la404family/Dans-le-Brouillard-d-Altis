// Liste des héliports et marqueurs
private _heliports = [heliport_01, heliport_02, heliport_03, heliport_04];
private _markers = ["helimarker_01", "helimarker_02", "helimarker_03", "helimarker_04"];

// Sélection aléatoire d'un héliport
private _selectedIndex = floor(random count _heliports);
private _selectedHeliport = _heliports select _selectedIndex;
private _selectedMarker = _markers select _selectedIndex;

// Supprimer les autres héliports et leurs marqueurs
{
    if (_forEachIndex != _selectedIndex) then {
        deleteVehicle _x;
        deleteMarker (_markers select _forEachIndex);
    };
} forEach _heliports;

// Configurer l'hélicoptère et le pilote
private _heli = heliBLUFOR;
private _pilot = heliBLUFORPILOT;
private _pilotGroup = group _pilot;

// Créer un groupe séparé pour les joueurs (unités non-joueurs)
private _playerUnits = [player_2, player_3, player_4, player_5, player_6, player_7, player_8, player_9, player_10];
private _player = player_1;
private _pilot = heliBLUFORPILOT;
private _playerGroup = group _pilot;

{
    [_x] joinSilent _player;
} forEach _playerUnits;

// Supprimer tous les waypoints existants pour les deux groupes
{
    for "_i" from 0 to (count waypoints _x - 1) do {
        deleteWaypoint [_x, 0];
    };
} forEach [_pilotGroup, _playerGroup];

// Configurer le comportement des groupes
{
    _x setBehaviour "CARELESS";
    _x setSpeedMode "LIMITED";
    // tirer à vue
    _x setCombatMode "YELLOW";
} forEach [_pilotGroup, _playerGroup];

// Créer le waypoint d'atterrissage
private _landingPos = getPosATL _selectedHeliport;
private _wp = _pilotGroup addWaypoint [_landingPos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointStatements [
    "true", 
    "vehicle this land 'LAND';"
];

// Surveiller l'atterrissage
[_heli, _pilot, _selectedHeliport, _selectedMarker, _pilotGroup, _playerGroup, _playerUnits] spawn {
    params ["_heli", "_pilot", "_selectedHeliport", "_selectedMarker", "_pilotGroup", "_playerGroup", "_playerUnits"];
    
    // Attendre que l'hélicoptère soit au sol
    waitUntil {isTouchingGround _heli || (getPosATL _heli select 2) < 0.5 && speed _heli < 1};
    
    // Ejecter tout le monde de l'hélicoptère
    {
        moveOut _x;
        unassignVehicle _x;
    } forEach crew _heli;

    // Arrêter le moteur et verrouiller l'hélicoptère
    _heli engineOn false;
    _heli lock 2;
    
    // Attendre que tout le monde soit sorti
    waitUntil {{_x in _heli} count (units _pilotGroup + _playerUnits) == 0};
    
    // Positionner le groupe pilote en cercle autour de l'hélicoptère (10m)
    private _pos = getPosATL _heli;
    private _pilotCount = count units _pilotGroup;
    private _angleStep = 360 / _pilotCount;
    
    {
        private _angle = _angleStep * _forEachIndex;
        private _newPos = _pos getPos [10, _angle];
        _x setPosATL [_newPos select 0, _newPos select 1, 0];
        _x setDir (_angle + 180);
        _x setUnitPos "UP";
        _x disableAI "PATH";
        doStop _x;
    } forEach units _pilotGroup;
    
    // Positionner le groupe joueur en cercle autour de l'hélicoptère (15m)
    private _playerCount = count _playerUnits;
    private _playerAngleStep = 360 / _playerCount;
    
    {
        private _angle = _playerAngleStep * _forEachIndex;
        private _newPos = _pos getPos [15, _angle];
        _x setPosATL [_newPos select 0, _newPos select 1, 0];
        _x setDir (_angle + 180);
        _x setUnitPos "UP";
        _x disableAI "PATH";
        doStop _x;
    } forEach _playerUnits;
    
    // Mettre à jour le marqueur
    _selectedMarker setMarkerType "mil_end";
    _selectedMarker setMarkerText "P.E (Soldats)";
   
    
    // Gestion du comportement en cas d'attaque pour les deux groupes
    {
        [_x] spawn {
            params ["_group"];
            
            while {{alive _x} count units _group > 0} do {
                if ({behaviour _x == "COMBAT"} count units _group > 0) then {
                    {
                        _x enableAI "PATH";
                        _x setBehaviour "AWARE";
                        _x setCombatMode "YELLOW";
                    } forEach units _group;
                    
                    // Retour au comportement normal après 30s sans combat
                    [_group] spawn {
                        params ["_group"];
                        sleep 30;
                        if ({behaviour _x == "COMBAT"} count units _group == 0) then {
                            {
                                _x disableAI "PATH";
                                _x setBehaviour "AWARE";
                                _x setCombatMode "BLUE";
                                _x doMove (getPosATL _x);
                            } forEach units _group;
                        };
                    };
                };
                sleep 5;
            };
        };
    } forEach [_pilotGroup, _playerGroup];
    
    // Attendre 15 secondes puis faire rejoindre les joueurs au joueur principal
    sleep 15;
    {
        _x enableAI "PATH";
        _x doFollow player;
        // ajouter des compétences au groupe
        // Améliorer les compétences du nouveau soldat
	_x setSkill ["aimingAccuracy", 0.9];     // Précision de tir (0-1)
	_x setSkill ["aimingShake", 0.7];        // Stabilité de visée
	_x setSkill ["aimingSpeed", 0.75];       // Vitesse de visée
	_x setSkill ["endurance", 0.9];          // Endurance
	_x setSkill ["spotDistance", 0.85];      // Distance de détection
	_x setSkill ["spotTime", 0.8];           // Vitesse de détection
	_x setSkill ["courage", 1.0];            // Courage (0-1)
	_x setSkill ["reloadSpeed", 0.8];        // Vitesse de rechargement
	_x setSkill ["commanding", 0.6];         // Capacité de commandement
	_x setSkill ["general", 0.8];            // Compétence générale
    } forEach _playerUnits;
};