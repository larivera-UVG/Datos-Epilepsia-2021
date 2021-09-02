%% Prueba de aprendizaje automático con RN: Generación de los vectores de 
%características de tiempo y etiquetas de señales EEG de 4 tipos
load('Patient_1_interictal_segment_0002.mat')
load('Patient_1_preictal_segment_0002.mat')
load('Bonn_datasets.mat')

features = 1; % 0=tiempo continuo, 1=Wavelet

Fs_ict = 5000; %Fs de las señales de Kaggle*
Fs_Ubonn = 173.61; %Fs de los datos de Ubonn
s_ventana = 1; %Segundos por ventana (iteración 1 =1s, 2 = 0.5s)
s_tiempo_total = 600; %Segundos de duración de las señales

%Se guardan los datos con un nuevo nombre
interict = interictal_segment_2.data(1,:); 
preict = preictal_segment_2.data(1,:);
sanodat = setAdata'; %Se transpone al necesitar que sean vectores fila
sanodat = sanodat(1,1:round(Fs_Ubonn*600));
ictaldat = setEdata'; %Se transpone al necesitar que sean vectores fila
ictaldat = ictaldat(1,1:round(Fs_Ubonn*600));
%Se calculan las muestras por ventana de cada tipo de señal
muestras_ventana = round(s_ventana*Fs_ict); 
muestras_ventana_Ubonn = round(s_ventana*Fs_Ubonn);
 if((s_ventana*Fs_Ubonn-muestras_ventana_Ubonn)<0)
     muestras_ventana_Ubonn = muestras_ventana_Ubonn-1;
 end
%c y canales = 1 al ser sólo 1 canal, op = 1,1,1,1,0,0 para selecionar
%únicamente las características que sí funcionan
c = 1;
canales = 1;
%% Características en tiempo contínuo
if features == 0
    op = [1,1,1,1,1,0];
    tic
    [Matriz_featuresPreictal,~,~] = FeaturesV2(preict,Fs_ict,canales,muestras_ventana,c,op);
    toc
    tic
    [Matriz_featuresInterictal,~,~] = FeaturesV2(interict,Fs_ict,canales,muestras_ventana,c,op);
    toc
    [Matriz_featuresSano,~,~] = FeaturesV2(sanodat,Fs_Ubonn,canales,muestras_ventana_Ubonn,c,op);
    tic
    [Matriz_featuresIctal,~,~] = FeaturesV2(ictaldat,Fs_Ubonn,canales,muestras_ventana_Ubonn,c,op);
    toc   
end
%% Características wavelet
if features == 1
    op = [1,1,1,1,1,1];
    madre = 'db3'; %Opciones: db3,db4,db5,db10
    n = 3;
    tic
    [Matriz_featuresPreictal,~,~,~] = FeaturesV2wavelet(preict,muestras_ventana,c,madre,n,op);
    [Matriz_featuresInterictal,~,~,~] = FeaturesV2wavelet(interict,muestras_ventana,c,madre,n,op);
    [Matriz_featuresSano,~,~,~] = FeaturesV2wavelet(sanodat,muestras_ventana_Ubonn,c,madre,n,op);
    [Matriz_featuresIctal,~,~,~] = FeaturesV2wavelet(ictaldat,muestras_ventana_Ubonn,c,madre,n,op); 
    toc
end
%% Vector de características y etiquetas 
% Orden de etiquetas 
% 1. Preictal
% 2. Interictal
% 3. Sano
% 4. Ictal
Matriz_featuresSano = Matriz_featuresSano(1:length(Matriz_featuresPreictal),:);
Matriz_featuresIctal = Matriz_featuresIctal(1:length(Matriz_featuresPreictal),:);

Vector_Caracteristicas_EEG = [Matriz_featuresPreictal',Matriz_featuresInterictal',...
    Matriz_featuresSano',Matriz_featuresIctal'];

nwmax = length(Matriz_featuresIctal);

%Se emplea encoding One-Hot Para las etiquetas de la RN
Vector_Etiquetas_EEG =[ones(1,nwmax),zeros(1,3*nwmax);...
    zeros(1,nwmax),ones(1,nwmax),zeros(1,2*nwmax);...
    zeros(1,2*nwmax),ones(1,nwmax),zeros(1,nwmax);...
    zeros(1,3*nwmax),ones(1,nwmax)];

%% Entrenamiento y evaluación de la con código+ app RN
Train_Func = ...
'trainscg';
%'trainr';
%'trainrp';
%'traingd';

hiddenLayerSize = 15;
net = patternnet(hiddenLayerSize, Train_Func);

[net,tr] = train(net,Vector_Caracteristicas_EEG,Vector_Etiquetas_EEG);

divitrain = 70;
divitest = 15;
divival = 15;
if divitrain+divitest+divival ~=100
    divitrain= 70;
    divitest = 15;
    divival = 15;
end

net.divideParam.trainRatio = divitrain/100;
net.divideParam.valRatio = divival/100;
net.divideParam.testRatio = divitest/100;
% Testear la red
etiquetas_salida = net(Vector_Caracteristicas_EEG);
confusion(Vector_Etiquetas_EEG,etiquetas_salida);
[~,cm] = confusion(Vector_Etiquetas_EEG,etiquetas_salida);
Pre_11 = cm(1,1);%Preictal correcto
Pre_12 = cm(1,2);%Preictal falso (inter)
Pre_13 = cm(1,3); %Preictal falso (sano)
Pre_14 = cm(1,4);%Preictal falso (ictal)

Inter_21 = cm(2,1);%Interictal falso (preict)
Inter_22 = cm(2,2);%Interictal correcto
Inter_23 = cm(2,3);%Interictal falso (sano)
Inter_24 = cm(2,4);%Interictal falso (ictal)

Sano_31 = cm(3,1);%Sano falso (preict)
Sano_32 = cm(3,2);%Sano falso (inter)
Sano_33 = cm(3,3);%Sano correcto
Sano_34 = cm(3,4);%Sano falso (ictal)

Ictal_41 = cm(4,1);%Ictal falso (preict)
Ictal_42 = cm(4,2);%Ictal falso (inter)
Ictal_43 = cm(4,3);%Ictal falso (sano)
Ictal_44 = cm(4,4);%Ictal correcto

accu = num2str(100*((Pre_11+Inter_22+Sano_33+Ictal_44) / (Pre_11+Pre_12+Pre_13+Pre_14+...
    Inter_21+Inter_22+Inter_23+Inter_24+...
    Sano_31+Sano_32+Sano_33+Sano_34+...
    Ictal_41+Ictal_42+Ictal_43+Ictal_44)))  %Exactitud

%Vector de salida
etiquetas_vector = zeros(1,4*nwmax);
for i=1:4*nwmax
    ventana_interes = etiquetas_salida(:,i);
    indice_max = find(ventana_interes==max(ventana_interes));
    if 1 == indice_max
        etiquetas_vector(1,i) = 1;
    elseif 2 == indice_max
        etiquetas_vector(1,i) = 2;
    elseif 3 == indice_max
        etiquetas_vector(1,i) = 3;
    elseif 4 == indice_max
        etiquetas_vector(1,i) = 4;
    end
end
