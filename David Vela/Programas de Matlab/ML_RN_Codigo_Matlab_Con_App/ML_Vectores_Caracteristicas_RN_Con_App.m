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
interict = interictal_segment_2.data; 
preict = preictal_segment_2.data;
sanodat = setAdata'; %Se transpone al necesitar que sean vectores fila
sanodat = sanodat(1,1:round(Fs_Ubonn*602));
ictaldat = setEdata'; %Se transpone al necesitar que sean vectores fila
ictaldat = ictaldat(1,1:round(Fs_Ubonn*602));
%Se calculan las muestras por ventana de cada tipo de señal
muestras_ventana = round(s_ventana*Fs_ict); 
muestras_ventana_Ubonn = round(s_ventana*Fs_Ubonn);
%c y canales = 1 al ser sólo 1 canal, op = 1,1,1,1,0,0 para selecionar
%únicamente las características que sí funcionan bien
c = 1;
canales = 1;
%% Características en tiempo contínuo
if features == 0
    op = [1,1,1,1,0,0];
    [Matriz_featuresPreictal,~,~] = FeaturesV2(preict,Fs_ict,canales,muestras_ventana,c,op);
    [Matriz_featuresInterictal,~,~] = FeaturesV2(interict,Fs_ict,canales,muestras_ventana,c,op);
    [Matriz_featuresSano,~,~] = FeaturesV2(sanodat,Fs_Ubonn,canales,muestras_ventana_Ubonn,c,op);
    [Matriz_featuresIctal,~,~] = FeaturesV2(ictaldat,Fs_Ubonn,canales,muestras_ventana_Ubonn,c,op);
end
%% Características wavelet
if features == 1
    op = [1,1,1,1,1,1];
    madre = 'db3'; %Opciones: db3,db4,db5,db10
    n = 8;
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

Vector_Caracteristicas_EEG = [Matriz_featuresPreictal',Matriz_featuresInterictal',...
    Matriz_featuresSano',Matriz_featuresIctal'];

Vector_Etiquetas_EEG =[ones(1,600),zeros(1,600*3);...
    zeros(1,600),ones(1,600),zeros(1,600*2);...
    zeros(1,600*2),ones(1,600),zeros(1,600);...
    zeros(1,600*3),ones(1,600)];
%%
%model_svm = fitcsvm(app.train_data, app.train_label,'KernelFunction',kernel,'Standardize',true,...
%                'BoxConstraint',1,'ClassNames',[0,1]);