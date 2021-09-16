%Funci�n para obtener la primera versi�n de caracter�sticas de morfolog�a. 
%En cada ventana de tiempo, se obtiene el espectro de frecuencias, se
%obtiene la magnitud de cada banda (delta, theta, alpha y beta), se obtiene
%la media de las 4 magnitudes y se cuantifica qu� tanto est� alejada la
%magnitud de la banda respecto de la media obtenida. Si la banda es mayor,
%el valor ser� >1, si es menor, ser� <1.
function [Matriz_FMorfologia] = FeaturesMorf(edf,fs,canales,muestras)
% ARGUMENTOS DE LA FUNCION
%edf:   archivo .edf con se�al EEG a analizar
%canales: n�mero de canales para encontrar features
%muestras: n�mero de muestras para realizar ventanas
%c: canales a encontrar las caracter�sticas
%Se arreglan las dimensiones para que se tengan vectores fila en caso
%la se�al venga en vectores columna.

%Arreglamos el vector para que sea vector columna
if size(edf,1)>size(edf,2)
    edf = edf';
end
%Encontramos el n�mero de canales a analizar, si es 0 se analizan todos:
if (canales(1)==0)
    no_canales = min(size(edf)); %El # de canales total es la dimensi�n m�s peque�a del EDF
    canales = 1:1:no_canales;
else
    no_canales = length(canales);
end
%Encontramos el n�mero entero de ventanas posibles
if(((length(edf)/muestras)-round(length(edf)/muestras))<0)
    size_cint = round(length(edf)/muestras)-1;
else
    size_cint = round(length(edf)/muestras);
end
%Se genera la matriz de salida, llena de ceros
Matriz_FMorfologia = zeros(4*no_canales,size_cint);
wliminf = 1; %�ndice inferior de la primera ventana
wlimsup = muestras; %�ndice superior de la primera ventana
mliminf = 1;%�ndice inferior para colocar en la matriz
mlimsup = 4;%�ndice superior para colocar en la matriz
for i=1:length(Matriz_FMorfologia)
    for j=1:no_canales
        ventana_interes = edf(canales(j),wliminf:wlimsup);        
        %C�lculo de las caracter�sticas de morfolog�a
        WS = fft(ventana_interes);
        WSn = abs(WS/muestras);
        WS1_1=WSn(1:muestras/2+1);
        WS1_1(2:end-1) = 2*WS1_1(2:end-1);
        
        delta = sum(WS1_1(1,1:5));
        theta = sum(WS1_1(1,6:9));
        alpha = sum(WS1_1(1,10:13));
        beta = sum(WS1_1(1,14:31));
        media_onda = mean([delta, theta, alpha, beta]);
        Matriz_FMorfologia(mliminf:mlimsup,i) = [delta/media_onda, theta/media_onda, alpha/media_onda, beta/media_onda]'; 
        %Nos desplazamos al siguiente canal
        mliminf = mlimsup+1;
        mlimsup = mliminf+3;
    end
    wliminf = wlimsup+1;
    wlimsup = wliminf+muestras-1;
    mliminf = 1;
    mlimsup = 4;
end
end