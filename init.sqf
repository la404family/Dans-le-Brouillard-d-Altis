// Variables définies en jeu 

// hostageVIP est un civil otage dans le village
// ConducteurCamionExtractionOtage est le conducteur du camion qui va extraire l'otage
// camionExtractionOtage est le camion qui va extraire l'otage
// directionCamionExtraction est un objet vide dans le jeu qui permet de définir la direction du camion
// zoneCouvertureDrone est un marker qui permet de définir la zone de couverture du drone
// droneBLUFOR est le drone qui surveille la zone
// directionDroneFinDeMission est un objet vide dans le jeu qui permet de définir la direction du drone à la fin de la mission
// volEnAttente est un Waypoint qui permet de définir le vol en attente du drone
// heliport_01, heliport_02, heliport_03, heliport_04 sont les héliports de départ et d'arrivée de l'hélicoptère
// helimarker_01, helimarker_02, helimarker_03, helimarker_04 sont les marqueurs des héliports
// heliBLUFOR est l'hélicoptère BLUFOR
// heliBLUFORPILOT est le pilote de l'hélicoptère et le chef de groupe
// player1, player2, player3, player4, player5, player6, player7, player8, player9, player10 sont les joueurs


// lance de la music d'intro
playMusic "00intro";
// fn_departAleatoireHeliport est une fontion qui permet de déclancher le départ aléatoire de l'hélicoptère
[] execVM "fn_departAleatoireHeliport.sqf";

// fn_zoneCouvertureDrone est un trigger qui permet de déclancher la zone de couverture du drone
// [] execVM "fn_zoneCouvertureDrone.sqf";

// fn_OtageDevientBLUFOR est un trigger qui permet de changer le civile en BLUFOR
// [] execVM "fn_OtageDevientBLUFOR.sqf";

// fn_ottageDansVehicule est un trigger qui permet de mettre l'otage d'etre extradé dans le vehicule
// [] execVM "fn_ottageDansVehicule.sqf";

// LOGIQUE GLOBALE DE LA MISSION 
// si hostageVIP est mort àlors c'est la fin de la mission (pas d'échec mais retour à l'hélicoptère)

// mettre tous les BLUFOR et le civil du jeu en voix Françaises :
[] execVM "fn_BLUFORenFR.sqf";

// Mettre des noms et prénoms français aux unités BLUFOR
[] execVM "fn_changementIdentite.sqf";

// Condition de fin de mission 
// [] execVM "fn_conditionsFinMission.sqf";
