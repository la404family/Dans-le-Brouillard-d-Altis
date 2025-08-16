// Faire quitter le groupe actuel de l'otage
[hostageVIP] joinSilent grpNull;

// Assigner l'otage au groupe du conducteur du camion
[hostageVIP] joinSilent (group ConducteurCamionExtractionOtage);

// Faire monter l'otage dans le camion d'extraction
hostageVIP assignAsCargo camionExtractionOtage;
[hostageVIP] orderGetIn true;

// Attendre que l'otage soit dans le véhicule
waitUntil {hostageVIP in camionExtractionOtage};

// Verrouiller le camion pour empêcher d'autres unités de monter
camionExtractionOtage lock true;
// mettre l'essence du camion à 100%
camionExtractionOtage setFuel 1;

// Faire conduire le camion à toute vitesse vers directionCamionExtraction
ConducteurCamionExtractionOtage doMove (getPos directionCamionExtraction);
camionExtractionOtage setSpeedMode "FULL";
// Optionnel : Message de confirmation
systemChat "L'otage est en sécurité, continuez votre mission";