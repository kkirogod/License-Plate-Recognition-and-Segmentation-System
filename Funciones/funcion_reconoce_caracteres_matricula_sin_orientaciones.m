function prediccion = funcion_reconoce_caracteres_matricula_sin_orientaciones(ISegEtiq, numCaracteres, contornos)

    addpath("Material_Imagenes_Plantillas\00_Plantillas\");

    load Plantillas.mat;

    caracteres = '0123456789ABCDFGHKLNRSTXYZ';
    prediccion = [];

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

            sentencia = ['IPlantilla = Objeto' num2str(j,"%02d") 'Angulo' num2str(4,"%02d") ';'];
            eval(sentencia);

            ICaracter = imresize(ICaracter, size(IPlantilla));

            valorCorrelacion = funcion_CorrelacionEntreMatrices(ICaracter, IPlantilla);

            if valorCorrelacion > valorMax

                valorMax = valorCorrelacion;
                caracterPred = caracter;

            end

        end

        prediccion = [prediccion; caracterPred];

    end

end