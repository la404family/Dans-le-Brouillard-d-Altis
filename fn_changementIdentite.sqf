
// Attribution automatique des identités françaises
_identitesFrancaises = [
    "FrenchSoldier01", "FrenchSoldier02", "FrenchSoldier03", "FrenchSoldier04",
    "FrenchSoldier05", "FrenchSoldier06", "FrenchSoldier07", "FrenchSoldier08",
    "FrenchSoldier09", "FrenchSoldier10", "FrenchSoldier11", "FrenchSoldier12",
    "FrenchSoldier13", "FrenchSoldier14", "FrenchSoldier15", "FrenchSoldier16",
    "FrenchSoldier17", "FrenchSoldier18", "FrenchSoldier19", "FrenchSoldier20",
    "FrenchSoldier21", "FrenchSoldier22", "FrenchSoldier23", "FrenchSoldier24",
    "FrenchSoldier25", "FrenchSoldier26", "FrenchSoldier27", "FrenchSoldier28",
    "FrenchSoldier29", "FrenchSoldier30"
];

// Attribution des identités françaises
{
    if (!isPlayer _x && side _x == west) then {
        _identiteAleatoire = selectRandom _identitesFrancaises;
        _x setIdentity _identiteAleatoire;
    };
} forEach allUnits;