

    
    // Créer la source lumineuse
    _lumiere = "#lightpoint" createVehicle [0,0,0];
    
    // Configuration de la lumière orange tamisée
    _lumiere setLightBrightness 0.15;          // Très tamisé
    _lumiere setLightColor [1, 0.5, 0.1];      // Orange chaleureux
    _lumiere setLightAmbient [0.6, 0.3, 0.05]; // Ambiance douce
    _lumiere setLightIntensity 200;            // Portée modérée
    _lumiere setLightAttenuation [1, 0, 1, 1, 0, 5, 8]; // Atténuation douce
    _lumiere setLightDayLight false;            // Visible de jour
    
    // Attacher à l'intérieur de la cabine
    _lumiere attachTo [heliBLUFOR, [0, -1, -0.4]]; // Vers l'arrière, en bas
    
    // Stocker la référence de la lumière sur l'hélicoptère
    heliBLUFOR setVariable ["lumiere_cabine", _lumiere];
    
    _lumiere
