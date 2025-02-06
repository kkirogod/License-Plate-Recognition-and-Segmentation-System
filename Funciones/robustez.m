function [plantillasValidas, diferenciasCorrelacion, caracteresSiguientes] = robustez(prediccion, matrizCorrelaciones)

    plantillasValidas = [];
    diferenciasCorrelacion = [];
    caracteresSiguientes = [];

    caracteres = '0123456789ABCDFGHKLNRSTXYZ';

    for i = 1:length(prediccion) % para cada caracter

        MCorrCaracter = squeeze(matrizCorrelaciones(i, :, :));

        % Obtenemos el valor maximo y lo anulamos
        correlacionMax = max(MCorrCaracter(:));
        [f, c] = find(MCorrCaracter == correlacionMax);
        MCorrCaracter(f, c) = -2;

        % A partir de aqui contamos el numero de plantillas validas 
        % contando la primera
        numPlantillasValidas = 1;

        corrMax = max(MCorrCaracter(:));
        [ff, cc] = find(MCorrCaracter == corrMax);

        while ff == f

            numPlantillasValidas = numPlantillasValidas + 1;

            MCorrCaracter(ff, cc) = -2;

            corrMax = max(MCorrCaracter(:));
            [ff, cc] = find(MCorrCaracter == corrMax);

        end

        plantillasValidas = [plantillasValidas, numPlantillasValidas];
        diferenciasCorrelacion = [diferenciasCorrelacion, (correlacionMax-corrMax)];
        caracteresSiguientes = [caracteresSiguientes, caracteres(ff)];

    end

end
