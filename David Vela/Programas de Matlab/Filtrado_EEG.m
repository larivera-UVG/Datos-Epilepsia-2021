%% Archivo .m para pruebas del filtro de Weiner y Butterworth
% David Alejandro Vela Aguilera - 17075
% Programa para la tesis 2021

%Filtro a verificar:
% 1 = Weiner, 2 = Butterworth
filtro_a_revisar = 2;
%% Carga de datos de prueba, obtenidos en Kaggle
% Procurar hacer 1 vez para un mejor rendimiendo
load Patient_1_interictal_segment_0001.mat
%% Generación ruido y visualización del EEG
close all
Fs = interictal_segment_1.sampling_frequency;
datos_interes = Fs*1;
datos_EEG = interictal_segment_1.data(4,1:datos_interes);
datos_tiempo = ((0:1:datos_interes-1))/Fs;
figure (1)
plot(datos_tiempo, datos_EEG);
xlabel('Segundos');
ylabel('microVoltios');
title('Señal EEG interictal sin ruido');
legend('EEG Original');
% Simulación Ruido de la red a 50Hz
datos_ruido = 10*sin(2*pi*100*datos_tiempo); % Señal de 50Hz
% Suma de ruido de red a la Señal
datos_EEG_ruido = datos_EEG + datos_ruido; 
%Descomentar lo siguiente para obtener la relación signal-to-noise en dB
%SNR_S11_noise_dB = snr(datos_EEG_ruido,sn_50);

%Gráfica de la señal con ruido y la señal original
figure (2)
plot(datos_tiempo, datos_EEG);
hold on
plot(datos_tiempo, datos_EEG_ruido);
xlabel('Segundos');
ylabel('microVoltios');
title('Señal EEG interictal con ruido sinusoidal de 50Hz');
legend('EEG Original','EEG con ruido');

if (filtro_a_revisar == 1)
    %Filtrado Wiener (se requiere el perfil de ruido)
    hw = wienerfilter(datos_EEG_ruido,datos_ruido,100,1);
    S11_wf = filter1(datos_EEG_ruido,hw,1);
    datos_EEG_Filtrado = datos_EEG_ruido-S11_wf; 
    figure (3)
    plot(datos_tiempo, datos_EEG);
    hold on
    plot(datos_tiempo, datos_EEG_Filtrado);
    xlabel('Segundos');
    ylabel('microVoltios');
    ylim([320 520]);
    title('Señal EEG interictal sin ruido y filtrado con Weiner (perfil de ruido)');
    legend('EEG Original', 'EEG Filtrado');
    errores = abs(datos_EEG(1,250:4750)-datos_EEG_Filtrado(1,250:4750));
elseif (filtro_a_revisar == 2)
    % Filtrado con Butterworth (LP)
    Fc = 70;
    W_blp = Fc/(Fs/2); % Normalización de la frecuencia de corte
    [blp,alp]= butter(2,W_blp, 'low'); % Filtro pasa bajo de segundo orden.
    datos_EEG_Filtrado1=filtfilt(blp,alp,datos_EEG);
    datos_EEG_Filtrado=filtfilt(blp,alp,datos_EEG_ruido); % Doble pasada del filtro
    figure (3)
    plot(datos_tiempo, datos_EEG_Filtrado1);
    hold on
    plot(datos_tiempo, datos_EEG_Filtrado);
    plot(datos_tiempo, datos_EEG_ruido, '--');
    xlabel('Segundos');
    ylabel('microVoltios');
    title("Señal EEG interictal sin ruido y filtrado Butterworth LP ("+num2str(Fc)+"Hz de Fc)");
    legend('EEG Original', 'EEG Filtrado', 'EEG ruido');
    errores = abs(datos_EEG(1,250:4750)-datos_EEG_Filtrado(1,250:4750));
end