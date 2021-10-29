%% Gráficas de los resultados del K-means, usando plot
% Se dividen los distintos bloques de las señales, según las etiquetas dadas por K-means
% Por: Luis Alberto Rivera

%load('grafica.mat')

%% En esta sección se encuentran los distintos bloques de cada clase, y se almacenan en celdas

% Lo siguiente se hace porque no coincide el número de columnas de edf y el número de
% filas de Predicted_clusters_km. Revisar en el código que crea Predicted_clusters_km,
% porque los tamaños deberían coincidir.
N = min([size(edf,2),size(Predicted_clusters_km,1)]);

ind1 = Predicted_clusters_km == 1;  % variable lógica, con unos donde la clase es 1
dind1 = diff(ind1); % este es un vector con 1 ó -1 donde hay cambios de clase
indCambios = find(dind1 == 1 | dind1 == -1);    % los índices donde hay cambios.
NrCambios = length(indCambios); % cuántos cambios de clase hay

if(mod(NrCambios,2) == 1) % número impar significa que hay el mismo número de bloques de cada clase
    NrC1 = (NrCambios+1)/2;
    NrC2 = (NrCambios+1)/2;
else % número par significa que hay un bloque más de la primera clase que aparece
    NrC1 = 1 + NrCambios/2;
    NrC2 = NrCambios/2;
end

% En lo que sigue, clase 1 se refiere a la primera que aparece, no necesariamente a la que
% tenga la etiqueta 1.
Clase1 = cell(NrC1, 1); % Inicializa celdas para guardar los bloques de cada clase.
Clase2 = cell(NrC2, 1);

% Cada elemento de las celdas será una matriz, cuya primera fila tiene los índices, y las
% siguientes filas son los datos de todos los canales, correspondientes a los índices.

n1 = 1;
n2 = 1;
for c = 1:length(indCambios)
    if(c == 1)  % Primer bloque
        Clase1{n1} = [1:indCambios(c); edf(:,1:indCambios(c))];
        n1 = n1 + 1;
    else
        if(mod(c,2) == 0)
            Clase2{n2} = [indCambios(c-1):indCambios(c); edf(:,indCambios(c-1):indCambios(c))];
            n2 = n2 + 1;
        else
            Clase1{n1} = [indCambios(c-1):indCambios(c); edf(:,indCambios(c-1):indCambios(c))];
            n1 = n1 + 1;
        end
    end
end

% Último bloque
if(mod(NrCambios,2) == 1) % número impar significa que el último bloque es de la 2da clase
    Clase2{n2} = [indCambios(c):N; edf(:,indCambios(c):N)];
else % número par significa que el último bloque es de la 1a clase
    Clase1{n1} = [indCambios(c):N; edf(:,indCambios(c):N)];
end


%% Gráficas de todos los segmentos (1 canal)
% Lo siguiente es para usar siempre los mismos colores para las clases 1 y 2. No se sabe
% si la primera clase que aparece en Predicted_clusters_km tiene la etiqueta 1 ó 2.
if(Predicted_clusters_km(1) == 1)
    Color1 = 'b';
    Color2 = 'r';
else
    Color1 = 'r';
    Color2 = 'b';
end

Canal = 1;  % Seleccionar canal. Modificar el código para mostrar más canales al mismo tiempo
figure(1); clf;
hold on;
for n = 1:NrC1
    plot(Clase1{n}(1,:), Clase1{n}(Canal+1,:), Color1);
end

for n = 1:NrC2
    plot(Clase2{n}(1,:), Clase2{n}(Canal+1,:), Color2);
end


% %% Gráficas usando scatter, para comparación
% % El código es mucho más simple, pero no se ve tan bien como con plot, especialmente al
% % hacer zoom, o si se grafican señales más cortas.
% 
% colores = zeros(length(Predicted_clusters_km),3);
% ind1 = Predicted_clusters_km == 1;
% ind2 = Predicted_clusters_km == 2;
% colores(ind1,:) = repmat([0,0,1],sum(ind1),1);  % vector rgb con el color que se desee
% colores(ind2,:) = repmat([1,0,0],sum(ind2),1);  % vector rgb con el color que se desee
% 
% figure(2); clf;
% scatter(1:N, edf(Canal,1:N), [], colores, '.');
% 
