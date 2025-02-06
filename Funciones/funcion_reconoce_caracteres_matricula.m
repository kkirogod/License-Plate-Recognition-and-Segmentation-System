function [prediccion, matrizCorrelaciones] = funcion_reconoce_caracteres_matricula(ISegEtiq, numCaracteres, contornos)

    addpath("Material_Imagenes_Plantillas\00_Plantillas\");

    load Plantillas.mat;

    caracteres = '0123456789ABCDFGHKLNRSTXYZ';
    prediccion = [];

    matrizCorrelaciones = zeros(numCaracteres, 26, 7);

    for i = 1:numCaracteres

        contorno = contornos(i,:);
        Ic = ISegEtiq == i;

        columnaMin = contorno(1);
        filaMin = contorno(2);
        ancho = contorno(3);
        alto = contorno(4);

        ICaracter = Ic(filaMin:(filaMin+alto), columnaMin:(columnaMin+ancho));

        valorMax = -2;

        for j = 1:26

            caracter = caracteres(j);

            for angulo = 1:7

                sentencia = ['IPlantilla = Objeto' num2str(j,"%02d") 'Angulo' num2str(angulo,"%02d") ';'];
                eval(sentencia);

                ICaracter = imresize(ICaracter, size(IPlantilla));

                valorCorrelacion = funcion_CorrelacionEntreMatrices(ICaracter, IPlantilla);

                matrizCorrelaciones(i,j,angulo) = valorCorrelacion;

                if valorCorrelacion > valorMax

                    valorMax = valorCorrelacion;
                    caracterPred = caracter;

                end

            end

        end

        prediccion = [prediccion; caracterPred];

    end

end