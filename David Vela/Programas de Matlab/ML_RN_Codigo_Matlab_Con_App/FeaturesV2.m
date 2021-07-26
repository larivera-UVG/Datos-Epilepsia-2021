%% NOTA: ESTA VERSIÓN CONTIENE CAMBIOS REALIZADOS POR DAVID VELA-17075 
%Cambio de una Fs fija a una introducida a la función, colocar en el 
% comentario de "op" del orden de los parámetros en la "Matriz_features", 
%implementar el filtrado Butterworth con la función "butter" y remover 
%el filtrado de la frecuencia eléctrica. Adición de la característica 
%de LZX (en progreso)

function [Matriz_features,channel_ventana,c] = FeaturesV2(edf,fs,canales,muestras,c,op)
% ARGUMENTOS DE LA FUNCION
%edf:   archivo .edf con señal EEG a analizar
%canales: número de canales para encontrar features (de 1 a 4 canales)
%muestras: número de muestras para realizar ventanas
%op: vector de opciones

%Se arreglan las dimensiones para que se tengan vectores fila en caso
%la señal venga en vectores columna.
if size(edf,1)>size(edf,2)
    edf = edf';
end
ctot = size(edf,1);
eeg = zeros(length(edf),canales);
if c==0
%Definir canales a analizar
    canales = ctot;
    eeg = edf';
else
    for i=1:canales
        eeg(:,i)= edf(c(i),:)';
    end
end

%Preprocesamiento: FILTROS
%Se crea un filtro pasa bandas con un filtro Butterworth pasa bajas
%y otro pasa altas.
Fclp = 70; %Frequencia de corte para el pasa bajas
Fchp = 0.5; %Frequencia de corte para el pasa altas
W_blp = Fclp/(fs/2); % Normalización de la frecuencia de corte pasa bajas
W_bhp = Fchp/(fs/2); % Normalización de la frecuencia de corte pasa altas
[blp,alp]= butter(2,W_blp, 'low'); % Filtro pasa bajo de segundo orden.
[bhp,ahp]= butter(2,W_bhp, 'high'); % Filtro pasa bajo de segundo orden.
%Se pasan ambos filtros 2 veces
channelsf1 = filtfilt(blp,alp,eeg); 
channels = filtfilt(bhp,ahp,channelsf1);

%Realizar ventana
k=1;        %recorrer canales
i=1;        %recorrer muestras
j=0;
flag=0;
size_c = length(channels);
channel_ventana = zeros(size_c,canales);
if mod(size_c/muestras,1)~=0 %si es decimal
    size_cint = round(size_c/muestras)-1;
else
   size_cint = size_c/muestras; 
end
z = zeros(length(eeg),canales);
zc = zeros(size_cint,canales);
mav = zeros(size_cint,canales);
desviacion = zeros(size_cint,canales);
curtosis = zeros(size_cint,canales);
lzx = zeros(size_cint,canales);
eac = zeros(size_cint,canales);

%Zero Crossing index function
max_amplitud = max(abs(channels))*0.02; % 2% de la amplitud de la señal 
umbral = max(max_amplitud);
for i=1:canales
   z(:,i) =  ZC(channels(:,i),umbral)'; %Calcular todos los ZC de la señal
end
while(1)
     
    channel_ventana(i,k) = channels(i,k); 
    i = i+1;     
    if(mod(i,(muestras))==0)      %Calcular caracteristicas de cada ventana
        flag = flag+1;
        mav(flag,k) = mean(abs(channel_ventana((j*muestras)+1:i,k)));
        desviacion(flag,k) = std(channel_ventana(:,k));
        curtosis(flag,k) = kurtosis(channel_ventana(:,k));
        
        
        %FUNCIÓN DESHABILITADA POR SU REQUERIMIENTO DE TIEMPO
        %binlzx = (mean(abs(channel_ventana((j*muestras)+1:i,k))))<=channel_ventana(:,k);
        %s = binary_seq_to_string(binlzx);
        %[lzx(flag,k), ~] = calc_lz_complexity(s, 'primitive', 1);
        if(j>0) %contar ZC por cada ventana
            for o=1:canales
                zc(flag,o) = sum(z(j*muestras:i,o) == 1);
            end  
        else
            for o=1:canales
                 zc(flag,o) = sum(z(1:(i-1),o) == 1);
            end 
        end
        j= j+1;   
        %fmax(flag,k)=max(picos);
    end
     if (i==size_c) 
            k=k+1;
            flag=0;
            i=1; 
            j=0;   
     end  
     if(k>canales)
            break;
     end
end
%Concatenar vector de características
a=0;
for i=1:canales
  totfeatures(:,i+a:((i+a)+5)) = [desviacion(:,i),curtosis(:,i),zc(:,i),mav(:,i),eac(:,i),lzx(:,i)];
  a=a+5;
end
resta=1;
%Se establece vfeatures antes para mejorar rendimiento
%vfeatures = zeros(1,4);
for j=1:canales
for i=1:6
   if op(i)==1 
       vfeatures(:,resta) = totfeatures(:,i); %eliminar columna no deseada
       resta=resta+1;  
   end
end

end
Matriz_features = vfeatures;
end

