
%Read THAMES Binary File
%file='22k.bin'
dir *.bin
file_pre = input ('Input file name:   ','s');

file = [file_pre '.bin'];


fil = fopen(file, 'r', 'ieee-be');

temp = fread(fil,6,'float32');
data = fread(fil, [6,Inf], 'float32');
data = data'

% data(:,5) contains the time data values
% data (:,6) contains the response data values
figure(1)
plot(data(:,5), data(:,6));
title (file)

saved_data = [data(:,5) data(:,6)];
outputname =[ file_pre '.asc'];
dlmwrite(outputname,saved_data,'\t')

fclose(fil);





