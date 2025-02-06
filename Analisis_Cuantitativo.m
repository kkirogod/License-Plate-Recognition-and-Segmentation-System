clear, clc, close all

addpath("Material_Imagenes_Plantillas\01_Training\")
addpath("Material_Imagenes_Plantillas\02_Test\")
addpath("Funciones\")

load("matriculas.mat")

numAciertos = 0;
numAciertosSinOrientaciones = 0;
tiempoTotal = 0;

plantillasValidas = [];
diferenciasCorrelacion = [];
caracteresFallidos = [];
caracteresReales = [];
caracteresSiguientes = [];
indiceImagenes = [];
imagenesFallidas = {};

nombreBase = 'Training_';

j = 1;
k = 1;

for i = 1:25

    I = imread([nombreBase num2str(j,'%02d') '.jpg']);

    tic

    [ISegEtiq, numCaracteres, centroides, contornos] = funcion_segmenta_caracteres_matricula(I, 0);

    [prediccion, matrizCorrelaciones] = funcion_reconoce_caracteres_matricula(ISegEtiq, numCaracteres, contornos);

    tiempoTotal = tiempoTotal + toc;

    if matriculas{i} == prediccion'
        numAciertos = numAciertos + 1;
    end


    % Obtenemos los datos para averiguar la Robustez
    [pValidas, difCorrelacion, caracteresSig] = robustez(prediccion', matrizCorrelaciones);

    plantillasValidas = [plantillasValidas, pValidas];
    diferenciasCorrelacion =  [diferenciasCorrelacion, difCorrelacion];

    caracteresReales = [caracteresReales, prediccion'];
    caracteresSiguientes = [caracteresSiguientes, caracteresSig];

    % para saber a qué img pertenece un valor det. de 'caracteresReales'
    indiceImagenes = [indiceImagenes, ones(1, length(prediccion))*i];


    % Evaluamos el efecto de no usar varias orientaciones de cada carcater
    prediccionSinOrientaciones = funcion_reconoce_caracteres_matricula_sin_orientaciones(ISegEtiq, numCaracteres, contornos);
    prediccionSinOrientaciones = prediccionSinOrientaciones';

    if matriculas{i} == prediccionSinOrientaciones
        numAciertosSinOrientaciones = numAciertosSinOrientaciones + 1;
    else
        posFallos = matriculas{i} ~= prediccionSinOrientaciones;
        caracteresFallidos = [caracteresFallidos; matriculas{i}(posFallos), prediccionSinOrientaciones(posFallos)];
        imagenesFallidas{k} = [nombreBase num2str(j,'%02d') '.jpg'];
        k = k+1;
    end


    if i == 5
        nombreBase = 'Test_';
        j = 0;
    end

    j = j+1;

end

disp(['Tiempo de computación (segmentación + reconocimiento): ' num2str(tiempoTotal) ' segundos'])
disp(['Tasa de acierto: ' num2str((numAciertos*100)/25) '%'])

disp('___________________________________________________________________')
fprintf('\n')

disp(['Tasa de acierto sin usar distintas orientaciones: ' num2str((numAciertosSinOrientaciones*100)/25) '%'])

fprintf('\n')

disp('Predicciones erróneas:')

for i = 1:size(caracteresFallidos,1)

    disp(['Real: ' caracteresFallidos(i,1) ' | Predicción: ' caracteresFallidos(i,2) ' -> ' imagenesFallidas{i}])

end

disp('___________________________________________________________________')
fprintf('\n')

disp(['Promedio del número de plantillas válidas del carácter real: ' num2str(mean(plantillasValidas))])
disp(['Desviación del número de plantillas válidas del carácter real: ' num2str(std(plantillasValidas))])

fprintf('\n')

disp(['Promedio de la diferencia de la correlación máxima y de la del siguiente carácter: ' num2str(mean(diferenciasCorrelacion))])
disp(['Desviación de la diferencia de la correlación máxima y de la del siguiente carácter: ' num2str(std(diferenciasCorrelacion))])

disp('___________________________________________________________________')
fprintf('\n')

disp('Identificación de los 5 casos más conflictivos:')

fprintf('\n')

disp('Según el número de plantillas válidas:')

[valores_ordenados, indices_ordenados] = sort(plantillasValidas);

minValores = valores_ordenados(1:5);
posiciones = indices_ordenados(1:5);

for i = 1:5

    numImagen = indiceImagenes(posiciones(i));

    if numImagen < 6
        nombreBase = 'Training_';
        j = numImagen;
    else
        nombreBase = 'Test_';
        j = numImagen - 5;
    end

    disp(['Caracter real: ' num2str(caracteresReales(posiciones(i))) ' | Caracter siguiente: ' num2str(caracteresSiguientes(posiciones(i))) ' -> ' num2str(minValores(i)) ' plantilla (' [nombreBase num2str(j,'%02d') '.jpg)']])

end

fprintf('\n')

disp('Según valores de correlación:')

[valores_ordenados, indices_ordenados] = sort(diferenciasCorrelacion);

minValores = valores_ordenados(1:5);
posiciones = indices_ordenados(1:5);

for i = 1:5

    numImagen = indiceImagenes(posiciones(i));

    if numImagen < 6
        nombreBase = 'Training_';
        j = numImagen;
    else
        nombreBase = 'Test_';
        j = numImagen - 5;
    end

    disp(['Caracter real: ' num2str(caracteresReales(posiciones(i))) ' | Caracter siguiente: ' num2str(caracteresSiguientes(posiciones(i))) ' -> Diferencia de correlación: ' num2str(minValores(i)) ' (' [nombreBase num2str(j,'%02d') '.jpg)']])

end

fprintf('\n')