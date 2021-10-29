%% Obtención de la morfología de la ventana
% Selección de signal_test:
% 1 -> Usa un EDF Sano %Morfología asíncronica
% 2 -> Usa un .mat Sano
% 3 -> Usa un .mat Ictal
% 4 -> Usa un .mat Interictal
signal_test = 3;

%% Condicional para la selección de señal
if (signal_test==1)
    [hdr, record] = edfread('S013R13.edf');
    Fs = 160; %Fs 
    x1 = record(60,1:160);
elseif (signal_test==2)
    load('Bonn_datasets.mat');
    Fs = 173.61;
    x1 = setAdata(1:173,1)';
elseif (signal_test==3)
    load('Bonn_datasets.mat');
    Fs = 173.61;
    x1 = setEdata(1:173,1)';
elseif (signal_test==4)
    load('Patient_1_interictal_segment_0001.mat');
    Fs = 5000;
    x1 = interictal_segment_1.data(1,1:5000)';
end
Ts = 1/Fs;     % Período de muestreo
s_ventana = 1; %Segundos por ventana (iteración 1 =1s, 2 = 0.5s)
muestras_ventana = round(s_ventana*Fs); 
%N2 = muestras_ventana;% Longitud de la señal (número de muestras)
%% Pruebas de TFT - Recuperado del Lab10 de Procesamiento de Señales

tic
X1 = fft(x1);
size(X1)
toc
vf2_2 = linspace((0),(Fs/2),muestras_ventana/2+1); 
lowlimF = zeros(1,4);
lowlimF(1,1) = 1;
toplimF = zeros(1,4);
banda_F = 1; %1 delta, 2 theta, 3 beta y 4 alfa, 5 es fuera del rango de interés
class = 1;
for element=1:length(vf2_2)
    if (vf2_2(element)<=4)
        class = 1;
    elseif (vf2_2(element)<=8)
        class = 2;
    elseif (vf2_2(element)<=12)
        class = 3;
    elseif (vf2_2(element)<=30)
        class = 4;
    else 
        class = 5;
    end
    if (banda_F ~=class) %Si ya se cambió de banda, se guarda el último índice
        if(class ~=5)
            disp(append("Valor inferior: ",num2str(vf2_2(element-1)),", index: ",num2str(element-1)))
            disp(append("Valor superior: ",num2str(vf2_2(element)),", index: ",num2str(element)))
            lowlimF(1,class) = element;
            toplimF(1,class-1) = element-1;
            banda_F = banda_F+1;
        else
            toplimF(1,class-1) = element-1;
            
            break
        end
    end
end

X1n = abs(X1/muestras_ventana);

X1_1=X1n(1:muestras_ventana/2+1);
X1_1(2:end-1) = 2*X1_1(2:end-1);

mav = mean(X1_1(1:30));

figure
stem(vf2_2, X1_1);
xlim([0 Fs/2]);
xlabel("Frecuencia (Hz)");
ylabel("Magnitud");
title("Espectro de frecuencia del EEG (inciando en 0) con la señal "+num2str(signal_test));
hold on
yline(mav,'-','MAV');
xline(4,'-r','delta');
xline(8,'-r','theta');
xline(12,'-r','alpha');
xline(30,'-r','beta');
hold off
%Prueba Histograma
delta = sum(X1_1(1,lowlimF(1):toplimF(1)));
theta = sum(X1_1(1,lowlimF(2):toplimF(2)));
alpha = sum(X1_1(1,lowlimF(3):toplimF(3)));
beta = sum(X1_1(1,lowlimF(4):toplimF(4)));
media_onda = mean([delta, theta, alpha, beta]);
figure
bar([delta, theta, alpha, beta])
xticks([1,2,3,4])
xticklabels({'Delta (1-4Hz)','Theta(4-8Hz)','Alfa (8-12Hz)', 'Beta (12-30Hz)'})
title("Magnitud espectro de frecuencia con la señal "+num2str(signal_test));
hold on
yline(media_onda,'-','Media');

figure
bar([delta/media_onda, theta/media_onda, alpha/media_onda, beta/media_onda])
xticks([1,2,3,4])
xticklabels({'Delta (1-4Hz)','Theta(4-8Hz)','Alfa (8-12Hz)', 'Beta (12-30Hz)'})
title("Magnitud espectro de frecuencia con la señal "+num2str(signal_test));