
// Attribution automatique des identités françaises (voir le fichier description.ext)
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


// Vérification et attribution des identités
private _identitesUtilisees = []; // Tableau pour stocker les identités déjà attribuées

{
    if (!isPlayer _x && {side _x == west}) then {
        // Filtrer les identités non encore utilisées
        private _identitesDisponibles = _identitesFrancaises - _identitesUtilisees;
        
        // Si plus d'identités disponibles, réinitialiser la liste
        if (count _identitesDisponibles == 0) then {
            _identitesUtilisees = [];
            _identitesDisponibles = _identitesFrancaises;
        };
        
        // Sélectionner une identité aléatoire parmi celles disponibles
        private _identiteAleatoire = selectRandom _identitesDisponibles;
        
        // Ajouter l'identité à la liste des utilisées
        _identitesUtilisees pushBack _identiteAleatoire;
        
        // Sauvegarde de l'identité originale pour vérification
        private _originalFace = face _x;
        private _originalSpeaker = speaker _x;
        
        // Application de la nouvelle identité
        _x setIdentity _identiteAleatoire;
        
        
    };
} forEach allUnits;
