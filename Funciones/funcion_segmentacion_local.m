function Ib = funcion_segmentacion_local(I, V, C)

    IMediasLocales = imfilter(I, (1/(size(V, 1)^2))*V);
    %imshow(IMediasLocales)
    Ib = I < IMediasLocales - C;

end