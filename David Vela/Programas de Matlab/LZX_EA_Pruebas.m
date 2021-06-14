%% Pruebas de obtención de las características de "Complejidad de Lempel-Ziv"
% y  "energía acumulada de onda". Este script funciona para hacer las pruebas
% correspondientes a la obtención de las dos características mencionadas
% anteriormente. Las funciones "binary_seq_to_string" y
% "calc_lz_complexity" son de la autoría de Quang Thai (qlthai@gmail.com).

%Prueba de complejidad Lempel-Ziv
load Patient_1_interictal_segment_0001.mat
Fs = interictal_segment_1.sampling_frequency;
datos_interes = Fs*1;
datos_EEG = interictal_segment_1.data(4,1:datos_interes);
MAV = mean(abs(datos_EEG));
binlzx = MAV<=datos_EEG;
s = binary_seq_to_string(binlzx);
[C, H] = calc_lz_complexity(s, 'primitive', 1);

%Pruba de energía acumulada
ventanas_energia = 10;
muestras_energia = datos_interes/ventanas_energia;
ventana_e = 1;
energia_datotemporal = zeros(1,500);
energia_acumulada = 0;
while (ventana_e<10)
    energia_datotemporal = datos_EEG(1,(ventana_e*muestras_energia...
                        -muestras_energia)+1:(ventana_e*muestras_energia));
    energia_acumulada = energia_acumulada + var(energia_datotemporal);
    ventana_e = ventana_e+1;
end
