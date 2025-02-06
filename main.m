clear, clc, close all

addpath("Material_Imagenes_Plantillas\01_Training\")
addpath("Material_Imagenes_Plantillas\02_Test\")
addpath("Funciones\")


usaTest = 0;


if usaTest == 1

    numImagenes = 20;
    nombreBase = 'Test_';

else

    numImagenes = 5;
    nombreBase = 'Training_';

end

flagFiguras = 0;

for i = 1:numImagenes

    I = imread([nombreBase num2str(i,'%02d') '.jpg']);

    [ISegEtiq, numCaracteres, centroides, contornos] = funcion_segmenta_caracteres_matricula(I, flagFiguras);

    prediccion = funcion_reconoce_caracteres_matricula(ISegEtiq, numCaracteres, contornos);

    representa_resultados_segmentacion_reconocimiento(I, prediccion, centroides, contornos);

    pause
    close all

end