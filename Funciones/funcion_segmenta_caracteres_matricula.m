function [ISegEtiq, numCaracteres, centroides, contornos] = funcion_segmenta_caracteres_matricula(I_original, flagFiguras)

    addpath("Material_Imagenes_Plantillas\01_Training\")
    addpath("Funciones\")
    
    if flagFiguras == 1
        figure, imshow(I_original);
        title("Imagen Original");
    end
        
    Iroja = I_original(:,:,1);
    
    if flagFiguras == 1
        figure, imshow(Iroja);
        title("Componente Roja de la imagen");
    end
    
    [F, ~] = size(Iroja);
    
    Wgauss = redondeoImparMasCercano((size(Iroja,1)*size(Iroja,2) * 9) / (175*1092));
    WfiltMaximos = redondeoImparMasCercano((size(Iroja,1)*size(Iroja,2) * 5) / (175*1092));
    
    hGauss = fspecial('gaussian', Wgauss, Wgauss/5);
    I = imfilter(Iroja, hGauss);
    
    if flagFiguras == 1
        figure, imshow(I);
        title("Imagen suavizada");
    end
    
    I = ordfilt2(I, WfiltMaximos^2, ones(WfiltMaximos));
    
    if flagFiguras == 1
        figure, imshow(I);
        title("Imagen filtrada");
    end
            
    % disp("Recorta correctamente una región")
    % figure, ROI = roipoly(I); clc
    % 
    % Dim = redondeoImparMasCercano(sqrt(sum(ROI(:))));
    
    V = ones(65); % Ajustado manuelamente, funciona bien con todas las img
    
    IbSegLocal = funcion_segmentacion_local(I, V, 12);
    
    if flagFiguras == 1
        figure, imshow(IbSegLocal);
        title('Imagen Segmentada Localmente');
    end
        
    margen = round(size(IbSegLocal, 1) * 0.05);
    
    IbSegLocal(1:margen, :) = 0;
    IbSegLocal((F-margen):F, :) = 0;
    
    [IEtiq, N] = bwlabel(IbSegLocal);
    
    lineaCentral = round(F / 2);
    logoUE = 0;
    
    for etiqueta = 1:N
    
        ROI = (IEtiq == etiqueta);
    
        [filas, ~] = find(ROI);
        
        if any(ROI(lineaCentral, :)) && ((max(filas) - min(filas)) > (F * 0.6))
    
            if logoUE == 0
    
                logoUE = etiqueta;
    
            end
    
        else
    
            IbSegLocal(IEtiq == etiqueta) = 0;
    
        end
    
    end
    
    IbSegLocal(IEtiq == logoUE) = 0;

    Ib = ordfilt2(IbSegLocal, WfiltMaximos^2, ones(WfiltMaximos));
    
    if flagFiguras == 1
        figure, imshow(Ib);
        title('Imagen final segmentada');
    end
    
    [ISegEtiq, numCaracteres] = bwlabel(Ib);
    
    contornos = [];
    centroides = [];

    for etiqueta = 1:numCaracteres
    
        ROI = (ISegEtiq == etiqueta);
        [filas, columnas] = find(ROI);
    
        contornos = [contornos; [min(columnas), min(filas), max(columnas) - min(columnas), max(filas) - min(filas)]];
        centroides = [centroides; [mean(columnas), mean(filas)]];
        
    end

end

