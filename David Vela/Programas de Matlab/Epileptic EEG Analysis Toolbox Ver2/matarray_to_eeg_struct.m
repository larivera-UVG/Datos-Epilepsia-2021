%Esta funci�n permite que un array de datos pueda guardarse como un .mat
%con una estructura con el nombre requerido para poder ser utilizado en la
%Epileptic EEG Analysis Toolbox Ver2

function matarray_to_eeg_struct(savename,data_array,slength,fs,inchannels,autod)
    %savename = Nombre del .mat donde se guardar� la estructura 
    %data_array = array con las se�ales EEG
    %slength = duraci�n de la se�al en segundos, dejar vac�o si desea que
    %   la funci�n establesta este dato por el usuario
    %fs = frecuencia de muestreo
    %channels = array de caracteres con los nombres de los canales
    %autod = si es 0 toma slength como la duraci�n en segundos de las
    %   se�ales, si es 1, las calcula aproximadamente (se dice en caso la
    %   frecuencia de muestreo est� en decimales)
    if autod == 0
        tiempoduracion = slength;
    else
        tiempoduracion = length(data_array)/fs;
    end
    %Se procura que el arreglo sea vectores fila
    array_dim = size(data_array);
    if array_dim(1)>array_dim(2)
        data_array = data_array';
    end
    eeg_struct.data = data_array;
    eeg_struct.data_length_sec = tiempoduracion;
    eeg_struct.sampling_frequency = fs;
    eeg_struct.channels = inchannels;
    save(savename,'eeg_struct');
end