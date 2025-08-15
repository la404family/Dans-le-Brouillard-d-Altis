// Définir le nom du speaker français ("Male01FRE")
private _frenchSpeaker = "Male01FRE";

// Fonction pour appliquer la voix à une unité
private _applyFrenchVoice = {
    params ["_unit"];
    if (!isNull _unit && {alive _unit}) then {
        _unit setSpeaker _frenchSpeaker;
    };
};

// Appliquer aux unités BLUFOR uniquement
{
    if (side _x == west) then {
        [_x] call _applyFrenchVoice;
    };
} forEach allUnits;