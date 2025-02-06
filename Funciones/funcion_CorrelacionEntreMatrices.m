function valorCorrelacion = funcion_CorrelacionEntreMatrices(Matriz1, Matriz2)
    
    Matriz1 = double(Matriz1);
    Matriz2 = double(Matriz2);
    
    media1 = mean(Matriz1(:));
    media2 = mean(Matriz2(:));
    
    numerador = sum(sum((Matriz1 - media1) .* (Matriz2 - media2)));
    denominador = sqrt(sum(sum((Matriz1 - media1).^2)) * sum(sum((Matriz2 - media2).^2)));
    
    valorCorrelacion = numerador / denominador;
    
end

