
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

/// Attribution automatique des identités françaises
private _identitesFrancaises = [
    "FrenchSoldier01", "FrenchSoldier02", "FrenchSoldier03", "FrenchSoldier04",
    "FrenchSoldier05", "FrenchSoldier06", "FrenchSoldier07", "FrenchSoldier08",
    "FrenchSoldier09", "FrenchSoldier10", "FrenchSoldier11", "FrenchSoldier12",
    "FrenchSoldier13", "FrenchSoldier14", "FrenchSoldier15", "FrenchSoldier16",
    "FrenchSoldier17", "FrenchSoldier18", "FrenchSoldier19", "FrenchSoldier20",
    "FrenchSoldier21", "FrenchSoldier22", "FrenchSoldier23", "FrenchSoldier24",
    "FrenchSoldier25", "FrenchSoldier26", "FrenchSoldier27", "FrenchSoldier28",
    "FrenchSoldier29", "FrenchSoldier30"
];

// Vérification et attribution des identités
{
    if (!isPlayer _x && {side _x == west}) then {
        private _identiteAleatoire = selectRandom _identitesFrancaises;
        
        // Sauvegarde de l'identité originale pour vérification
        private _originalFace = face _x;
        private _originalSpeaker = speaker _x;
        
        // Application de la nouvelle identité
        _x setIdentity _identiteAleatoire;
        
        // Vérification que le changement a bien été appliqué
        if (face _x == _originalFace || {speaker _x == _originalSpeaker}) then {
            diag_log format ["Erreur: L'identité %1 n'a pas pu être appliquée à l'unité %2", _identiteAleatoire, _x];
        };
    };
} forEach allUnits;

// Journal de débogage
diag_log "Attribution des identités françaises terminée";