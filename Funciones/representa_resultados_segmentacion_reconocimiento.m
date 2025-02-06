function representa_resultados_segmentacion_reconocimiento(I, prediccion, centroides, contornos)

    figure, imshow(I), hold on;
    
    for i = 1:size(centroides,1)
    
        rectangle('Position', contornos(i,:), 'EdgeColor', 'r');
    
        plot(centroides(i,1), centroides(i,2), 'r*');
    
    end
    
    title(prediccion');
    hold off;

end

