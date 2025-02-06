clear, clc, close all

addpath("Material_Imagenes_Plantillas\01_Training\")
addpath("Funciones\")

I_original = imread("Training_05.jpg");
figure, imshow(I_original);
title("Imagen Original (Training_05.jpg)");

%% Procesamiento de la imagen

Iroja = I_original(:,:,1);

figure, imshow(Iroja);
title("Componente Roja de la imagen");

[F, C] = size(Iroja);

% Adaptamos las vecindades de los filtros a las dimensiones de la imagen
Wgauss = redondeoImparMasCercano((size(Iroja,1)*size(Iroja,2) * 9) / (175*1092));
WfiltMaximos = redondeoImparMasCercano((size(Iroja,1)*size(Iroja,2) * 5) / (175*1092));

hGauss = fspecial('gaussian', Wgauss, Wgauss/5);
I = imfilter(Iroja, hGauss);

figure, imshow(I);
title("Imagen suavizada");

I = ordfilt2(I, WfiltMaximos^2, ones(WfiltMaximos));

figure, imshow(I);
title("Imagen filtrada");


%% Binarización de la imagen

% SEGMENTACIÓN LOCAL

% usamos roipoly para determinar V1, para que siempre coja una vecindad que
% tenga pixeles de número y de fondo

disp("Recorta correctamente una región")
figure, ROI = roipoly(I); clc

Dim = redondeoImparMasCercano(sqrt(sum(ROI(:))));

V = ones(Dim);

% (12 = umbral para la diferencia de medias)
IbSegLocal = funcion_segmentacion_local(I, V, 12);

figure, imshow(IbSegLocal);
title('Imagen Segmentada Localmente');


% CORRECCIÓN DE FONDO + SEGMENTACIÓN GLOBAL

V = ones(Dim*2);

% Filtramos el fondo usando un filtro de medias
I_fondo = imfilter(I, (1/(size(V, 1)^2))*V, "replicate");

figure, imshow(I_fondo);
title('Imagen de Fondo');

% Restamos el fondo de la imagen original
I_corr = uint8(double(I_fondo) - double(I));

figure, imshow(I_corr);
title('Imagen con Corrección de Fondo');

% Umbral global utilizando Otsu
umbralOtsu = graythresh(I_corr) * 255;

% Binarización global
IbSegGlobal = I_corr > umbralOtsu - 5;

figure, imshow(IbSegGlobal);
title('Imagen Segmentada Globalmente con Corrección de Fondo');

%% Segmentación de los caracteres a partir de la imagen binaria resultante

% Eliminamos los píxeles de los bordes superiores e inferiores
margen = round(size(IbSegLocal, 1) * 0.05);

IbSegLocal(1:margen, :) = 0;
IbSegLocal((F-margen):F, :) = 0;

imshow(IbSegLocal)
title('Imagen binaria con bordes limpios');

% Etiquetamos la imagen binaria
[IEtiq, N] = bwlabel(IbSegLocal);

lineaCentral = round(F / 2);
logoUE = 0;

for etiqueta = 1:N

    ROI = (IEtiq == etiqueta);

    [filas, columnas] = find(ROI);
    
    % Si la agrupación pisa la línea central y cumple con una altura mínima
    if any(ROI(lineaCentral, :)) && ((max(filas) - min(filas)) > (F * 0.6))

        % Si es la primera agrupación encontrada, es el logo de la UE
        if logoUE == 0

            logoUE = etiqueta;

        end

    else

        % Sino eliminamos la agrupación
        IbSegLocal(IEtiq == etiqueta) = 0;

    end

end

IbSegLocal(IEtiq == logoUE) = 0;

figure, imshow(IbSegLocal);
title('Imagen (no definitiva) segmentada');

% Rellenamos los posibles huecos entre los caracteres y revertimos el
% adelgazamiento previo
Ib = ordfilt2(IbSegLocal, WfiltMaximos^2, ones(WfiltMaximos));

figure, imshow(Ib);
title('Imagen definitiva segmentada');

% Reetiquetamos
[IEtiq, N] = bwlabel(Ib);

contornos = [];
centroides = [];

for etiqueta = 1:N

    ROI = (IEtiq == etiqueta);
    [filas, columnas] = find(ROI);

    contornos = [contornos; [min(columnas), min(filas), max(columnas) - min(columnas), max(filas) - min(filas)]];
    centroides = [centroides; [mean(columnas), mean(filas)]];

end

% Visualizamos los resultados
figure, imshow(I_original), hold on;

for i = 1:size(centroides,1)
    
        rectangle('Position', contornos(i,:), 'EdgeColor', 'r');
    
        plot(centroides(i,1), centroides(i,2), 'r*');
    
end

title('Segmentación de la matrícula');
hold off;