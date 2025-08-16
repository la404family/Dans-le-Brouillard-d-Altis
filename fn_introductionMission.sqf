// Fonction d'introduction pour la mission "Dans le brouillard d'Altis"
[] spawn {
    // Activer l'écran noir
    titleCut ["", "BLACK FADED", 9999];
    // Afficher le texte d'introduction avec titleText
    titleText [
        "Dans le brouillard d'Altis",
        "PLAIN DOWN",
        3,
        true,
        true
    ];
    sleep 5; // Laisser le texte s'afficher un moment
    // Jouer la musique d'introduction
    playMusic "00intro";
    // Créer une caméra cinématographique
    private _camera = "camera" camCreate [0,0,50];// longitude, latitude, altitude
    _camera cameraEffect ["internal", "BACK"];

    // Plan 1 : Vue large de l'hélicoptère (heliBLUFOR) dans le brouillard
    private _heli = heliBLUFOR;
    private _heliPos = getPos _heli;
    _camera camSetPos [_heliPos select 0, (_heliPos select 1) - 100, 50];
    _camera camSetTarget _heli;
    _camera camSetFov 0.7;
    _camera camCommit 0;
    // Fondu depuis l'écran noir
    titleCut ["", "BLACK IN", 3];
    sleep 9;
    // Plan 2 : Zoom lent sur l'hélicoptère
    _camera camSetPos [_heliPos select 0, (_heliPos select 1) - 50, 50];
    _camera camSetFov 0.5;
    _camera camCommit 5;
    sleep 2;
    // Plan 3 : Vue du marqueur où se trouve l'otage (marker_0)
    private _markerPos = getMarkerPos "marker_0";
    _camera camSetPos [_markerPos select 0, (_markerPos select 1) - 50, 50];
    _camera camSetTarget _markerPos;
    _camera camSetFov 0.7;
    _camera camCommit 5;
    sleep 5;
    // Plan 4 : Vue dynamique autour du marqueur
    _camera camSetPos [(_markerPos select 0) + 20, (_markerPos select 1) + 50, 50];
    _camera camSetTarget _markerPos;
    _camera camSetFov 0.6;
    _camera camCommit 4;
    sleep 5;
    // faire un fondu vers le noir
    titleCut ["", "BLACK IN", 5];
    // Terminer la caméra
    _camera cameraEffect ["terminate", "BACK"];
    camDestroy _camera;
    sleep 10;
};