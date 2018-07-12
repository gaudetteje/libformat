% file to run batch
%set directory which contains all *.dat files to examined
% this is valid for 12 channels
R = input('What is the directory:  ','s')
numofchannels=input('Enter number of channels ')
%numofchannels=numofchannels-1;
cd(R);
%cd('c:\windows\desktop\witting\syscal\temp')
d=dir('*.dat')
[a b] = size(d)

for i=1:a;
   full_name={getfield(d(i),'name')}
   [path,name,ext,ver] = fileparts(getfield(d(i),'name'))
   short_name={name};
   %freq response
   fCommand=strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.ps /O /A /X /T:D /D:0 /Y:R /R:0-'},num2str(numofchannels-1),{',C'})
   eval(char((fCommand)));
   %input power
   %fCommand=strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.inp /O /A /X /T:D /D:2 /Y:R'})
   %eval(char((fCommand)));
   %output power
   %fCommand=strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.out /O /A /X /T:D /D:3 /Y:R /R:0-'},num2str(numofchannels-1),{',C'})
   %eval(char((fCommand)));
   %cross power
  % fCommand=strcat({ '! SDFTOASC '},full_name,{' '},short_name,{'.xpr /O /A /X /T:D /D:4 /Y:R /R:0-'},num2str(numofchannels-1),{',C'})
   %eval(char((fCommand)));

	%load(char(strcat(short_name,{'.fr'})))   
end  
   
   
   