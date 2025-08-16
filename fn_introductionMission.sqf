[] spawn {
    // ===== CONFIGURATION =====
    private _missionTitle = "DANS LE BROUILLARD D'ALTIS";
    private _missionAuthor = "Par Kevin Du Chevreuil";
    private _missionType = "Opération de d'extraction";
    private _heli = heliBLUFOR;
    private _marker = "marker_0";

    // ===== INITIALISATION =====
    titleCut ["", "BLACK FADED", 999];
    showCinemaBorder true;
    0 fadeSound 0;
    0 fadeMusic 0;

    // ===== EFFETS VISUELS INITIAUX =====
    private _blur = ppEffectCreate ["DynamicBlur", 500];
    _blur ppEffectEnable true;
    _blur ppEffectAdjust [5];
    _blur ppEffectCommit 0;

    // ===== AFFICHAGE DU TITRE =====
    [
        parseText format [
            "<t font='PuristaBold' size='1.8' color='#ffffff' shadow='2' shadowColor='#000000' align='center'>%1</t><br/>"
            + "<t font='PuristaLight' size='0.9' color='#a0a0a0' align='center'>%2</t><br/><br/>"
            + "<t font='PuristaMedium' size='0.7' color='#d0d0d0' align='center'>%3</t>",
            _missionTitle, _missionType, _missionAuthor
        ], 
        true, nil, 7, 0.7, 0
    ] spawn BIS_fnc_textTiles;

    // ===== TRANSITION MUSICALE =====
    sleep 3;
    playMusic "00intro";
    5 fadeMusic 1;
    _blur ppEffectAdjust [0];
    _blur ppEffectCommit 4;

    // ===== CINEMATIQUE HELICOPTERE =====
    private _heliPos = getPos _heli;
    private _camera = "camera" camCreate [_heliPos select 0, (_heliPos select 1) - 150, 80];
    _camera cameraEffect ["internal", "BACK"];

    // Plan 1: Vue aérienne éloignée avec effet brouillard
    _camera camSetPos [_heliPos select 0, (_heliPos select 1) - 150, 80];
    _camera camSetTarget _heli;
    _camera camSetFov 0.9;
    _camera camCommit 0;

    titleCut ["", "BLACK IN", 5];
    5 fadeSound 1;
    sleep 5;
    // faire un fondu vers le noir
    titleCut ["", "BLACK IN", 5];
    // Plan 2: Mouvement orbital autour de l'hélicoptère
    [_camera, _heli, 100, 30, 0, 6] spawn {
        params ["_camera", "_target", "_radius", "_altitude", "_angle", "_duration"];
        private _startTime = time;
        while {time - _startTime < _duration} do {
            private _relPos = [sin(_angle) * _radius, cos(_angle) * _radius, _altitude];
            _camera camSetPos (getPos _target vectorAdd _relPos);
            _camera camSetTarget _target;
            _camera camCommit 0.1;
            _angle = _angle + (360 / _duration * 0.1);
            sleep 0.1;
        };
    };
    sleep 6;
    // ===== TRANSITION VERS LA ZONE OBJECTIVE =====
    private _markerPos = getMarkerPos _marker;

    // Plan 3: Vue satellite de la zone
    _camera camSetPos [_markerPos select 0, _markerPos select 1, 200];
    _camera camSetTarget _markerPos;
    _camera camSetFov 0.8;
    _camera camCommit 8;

    // Ajout de brouillard (remplacé par ColorCorrections)
    private _fog = ppEffectCreate ["ColorCorrections", 1501];
    _fog ppEffectEnable true;
    _fog ppEffectAdjust [1, 1, 0, [0.1, 0.1, 0.1, 0.1], [1, 1, 1, 0.8], [0.9, 0.9, 0.9, 0]];
    _fog ppEffectCommit 3;
    sleep 3;
    // Plan 3 : Vue du marqueur où se trouve l'otage (marker_0)
    private _markerPos = getMarkerPos "marker_0";
    _camera camSetPos [_markerPos select 0, (_markerPos select 1) - 50, 50];
    _camera camSetTarget _markerPos;
    _camera camSetFov 0.7;
    _camera camCommit 5;
    sleep 4;
    // Plan 4 : Vue dynamique autour du marqueur
    _camera camSetPos [(_markerPos select 0) + 20, (_markerPos select 1) + 50, 50];
    _camera camSetTarget _markerPos;
    _camera camSetFov 0.6;
    _camera camCommit 4;
    sleep 4;
    // faire un fondu vers le noir
    titleCut ["", "BLACK IN", 5];
    // Terminer la caméra
    _camera cameraEffect ["terminate", "BACK"];
    camDestroy _camera;
    sleep 10;
    // ===== FIN DE LA CINEMATIQUE =====
}