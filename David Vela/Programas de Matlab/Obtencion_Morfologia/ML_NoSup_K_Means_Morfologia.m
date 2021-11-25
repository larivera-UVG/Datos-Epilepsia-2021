%% Obtención de la morfología de la ventana
% Selección de signal_test:
% 1 -> Usa un EDF Sano %Morfología asíncronica
% 2 -> Usa un .mat Sano
% 3 -> Usa un .mat Ictal
% 4 -> Usa un .mat Interictal
signal_test = 2;

%% Condicional para la selección de señal
if (signal_test==1)
    [hdr, record] = edfread('S013R13.edf');
    Fs = 160; %Fs 
    x1 = record;
    ch_interes = [12,13,14,15];
elseif (signal_test==2)
    load('Bonn_datasets.mat');
    Fs = 173.61;
    x1 = setAdata';
    ch_interes = [1];
elseif (signal_test==3)
    load('Bonn_datasets.mat');
    Fs = 173.61;
    x1 = setEdata';
    ch_interes = [1];
elseif (signal_test==4)
    load('Patient_1_interictal_segment_0001.mat');
    Fs = 5000;
    x1 = interictal_segment_1.data';
    ch_interes = [12,13,14,15];
end
s_ventana = 1; %Tiempo en s de la ventana
 if((s_ventana*Fs-round(s_ventana*Fs))<0)
     muestras = round(s_ventana*Fs)-1;
 else
     muestras = round(s_ventana*Fs);
 end
%--------------------------------------------------------------------------------------------
%comb = combnk(1:ctot,canales);  %combinaciones para generar mejor respuesta?
%i=1;
%----------------------------------------------------------------------------------------------
%Encontrar matriz de features 
Matriz_featuresMorf = FeaturesMorf(x1,Fs,ch_interes,muestras);
m = 2; %Número de clusters
%Clustering: K-means en función .m
[E, ~] = k_means(Matriz_featuresMorf',m,0);
%K-means Con la función de Matlab:
idx = kmeans(Matriz_featuresMorf',m);
[~,No_ventanas] = size(Matriz_featuresMorf);
Etiquetas_Matriz_Morfologia =  zeros(length(ch_interes),No_ventanas);
for i=1:length(ch_interes)
    [E, ~] = k_means(Matriz_featuresMorf',m,0);
    Etiquetas_Matriz_Morfologia(i,:) = E';
end
%----------------------------------------------------------------------------------------------
% %Graficar Clustering
% j=0;
% for i=1:length(E)
%     Predicted_clusters_km((j*muestras)+1:i*muestras,1) = E(i,1)*ones(muestras,1);
%     j = j+1;
% end
% 
% data = data(1:length(Predicted_clusters_fcm),:);
% t1=1:length(Predicted_clusters_km);
% figure(1);
% 
% for j = 1:m  
%     for i=1:canales
%     subplot(canales,1,i);
%     hold off;
%     scatter(t1,data(:,i), 2, Predicted_clusters_fcm(:,j), 'filled');
%     ylabel('Predicción FCM ')
%     xlabel(['Muestras canal ',num2str(c(i))])
%     end
% end
% figure(2);
% for j = 1:m
%     subplot(canales,1,j);
%     hold off;
%     plot(t1(Predicted_clusters_km==1),data(Predicted_clusters_km==1,j),'color','b' )
%     hold on;
%     plot(t1(Predicted_clusters_km==2),data(Predicted_clusters_km==2,j),'color','y' )
%     hold off;
%     ylabel('Predicción KMeans ')
%     xlabel(['Muestras canal ',num2str(c(i))])
% 
% end
% 
[E,Matriz_featuresMorf(1:4,:)']
