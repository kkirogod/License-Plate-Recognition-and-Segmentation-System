function resultado = redondeoImparMasCercano(x)

    r = round(x);
    
    if mod(r, 2) == 0
        if x > r
            resultado = r + 1;
        else
            resultado = r - 1;
        end
    else
        resultado = r;
    end
    
end


