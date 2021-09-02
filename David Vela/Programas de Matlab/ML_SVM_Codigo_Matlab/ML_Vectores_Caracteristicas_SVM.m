%% Prueba de aprendizaje automático con SVM:
%Generación de los vectores de características y etiquetas de 
%señales EEG de 4 tipos
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
    op = [1,1,1,1,1,0];
    tic
    [Matriz_featuresPreictal,~,~,Windtest] = FeaturesV2(preict,Fs_ict,canales,muestras_ventana,c,op);
    toc
    tic
    [Matriz_featuresInterictal,~,~] = FeaturesV2(interict,Fs_ict,canales,muestras_ventana,c,op);
    toc
    tic
    [Matriz_featuresSano,~,~] = FeaturesV2(sanodat,Fs_Ubonn,canales,muestras_ventana_Ubonn,c,op);
    toc
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

Vector_Caracteristicas_EEG = [Matriz_featuresPreictal(1:300,:)',Matriz_featuresInterictal(1:300,:)',...
    Matriz_featuresSano(1:300,:)',Matriz_featuresIctal(1:300,:)',...
    Matriz_featuresPreictal(301:600,:)',Matriz_featuresInterictal(301:600,:)',...
    Matriz_featuresSano(301:600,:)',Matriz_featuresIctal(301:600,:)'];

Vector_Caracteristicas_EEG = Vector_Caracteristicas_EEG';
Vector_Etiquetas_EEG = [ones(1,300),2*ones(1,300),3*ones(1,300),4*ones(1,300),...
    ones(1,300),2*ones(1,300),3*ones(1,300),4*ones(1,300)];
Vector_Etiquetas_EEG = Vector_Etiquetas_EEG';
Vector_Etiquetas_EEG_SVM = zeros(2400,1);

for i=1:2400
        if (Vector_Etiquetas_EEG(i) ==1)
            Vector_Etiquetas_EEG_SVM(i,1) = 1; %Preictal
            
        elseif (Vector_Etiquetas_EEG(i) ==2)
            Vector_Etiquetas_EEG_SVM(i,1) = 2; %Interictal
            
        elseif (Vector_Etiquetas_EEG(i) ==3)
           Vector_Etiquetas_EEG_SVM(i,1)= 3; %Sano
           
        elseif (Vector_Etiquetas_EEG(i) ==4)
            Vector_Etiquetas_EEG_SVM(i,1) = 4; %Ictal
        end
end

%%
 k = 10; %Particiones para la validación cruzada
 cvFolds = crossvalind('Kfold',  Vector_Etiquetas_EEG_SVM, k);   
 cp = classperf(Vector_Etiquetas_EEG_SVM);                      %# init performance tracker
 for i = 1:k                                  %# for each fold
     testIdx = (cvFolds == i);                %# get indices of test instances
     trainIdx = ~testIdx; 
     %Obtener conjuntos train (app.train_data/label) y test (app.test_data/label)
     datos_entrenamiento= Vector_Caracteristicas_EEG(trainIdx,:);
     etiquetas_entrenamiento = Vector_Etiquetas_EEG_SVM(trainIdx,:);
     datos_prueba =Vector_Caracteristicas_EEG(testIdx,:);
     etiquetas_prueba = Vector_Etiquetas_EEG_SVM(testIdx,:);
 end
 
%Entrenar SVM
kernel = 'linear';%gaussian,linear, polynomial
t_SVM = templateSVM('Standardize',true,'KernelFunction',kernel);
model_svm = fitcecoc(datos_entrenamiento,etiquetas_entrenamiento,'Learners',t_SVM,'FitPosterior',true,...
    'Verbose',2);

[labelPred,scores] =  predict(model_svm, datos_prueba);
Predicted_labels = labelPred;
test_features = scores;
Prueba_eti = categorical(etiquetas_prueba');
Predict_eti = categorical(labelPred');

%Graficar
plotconfusion(Prueba_eti,Predict_eti);
plotconfusion(Prueba_eti,Predict_eti,{'Matriz de Confusión'});
            set(gca,'xticklabel',{'Ictal' 'Sano' 'Preictal' 'Interictal' 'Exactitud'})
            set(gca,'yticklabel',{'Ictal' 'Sano' 'Preictal' 'Interictal' ''})
matriz = confusionmat(Prueba_eti,Predict_eti);
s = sum(matriz);
exactitud = 100*(matriz(1,1)+matriz(2,2)+matriz(3,3)+matriz(4,4))/(s(1)+s(2)+s(3)+s(4))