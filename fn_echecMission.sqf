// Vérification de l'échec de la mission
private _missionFailed = false;
private _failMessage = "";

// Si toute l'équipe d'appui "equipeAPPUI" est morte
if ({alive _x} count units equipeAPPUI == 0) then {
    systemChat "L'équipe d'appui a été anéantie...";
    _failMessage = "L'équipe d'appui a été anéantie. Mission échouée.";
    _missionFailed = true;
};

// Si l'hélicoptère est détruit ou ne peut plus voler
if (!alive heliBLUFOR) then {
    systemChat "L'hélicoptère a été détruit...";
    _failMessage = "L'hélicoptère a été détruit. Mission échouée.";
    _missionFailed = true;
} else {
    if (!canMove heliBLUFOR || damage heliBLUFOR > 0.9) then {
        systemChat "L'hélicoptère ne peut plus voler...";
        _failMessage = "L'hélicoptère ne peut plus voler. Mission échouée.";
        _missionFailed = true;
    };
};

// Si échec détecté, déclencher la fin de mission
if (_missionFailed) then {
    sleep 25; // Attendre 25 secondes pour éviter les conflits avec d'autres scripts
    [_false, _failMessage] call fn_echecMission;
};