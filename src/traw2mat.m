function traw2mat(phefile,genofile,outfile,n,p,ny,methods)
% Load the genotype matrix stored in a text file, and save it in a format 
% that is more convenient for loading into MATLAB.
%all data type both transfor to the matlab file .mat...using plink and vcftools  
%plink --vcf pop.recode.vcf --make-bed --out pop --allow-extra-chr
%vcftools --vcf pop.recode.vcf --plink --out pop
%plink --bfile pop --recode A-transpose --out poptraw
% SCRIPT PARAMETERS
% -----------------
% This is a .fam file 
%famfile = famfile;
% This is a .traw file storing the genotype data. For details on this
% file format, see http://www.cog-genomics.org/plink2/formats#traw.
%genofile =genofile;
% Save the genotype data to this MATLAB binary file.
%outfile = outfile;
% Number of genotyped samples.
%n = n;
% Number of genotyped SNPs.
%p=p;

% READ SAMPLE INFORMATION
% -----------------------
fprintf('Reading sample information.\n');
f      = fopen(phefile,'r');
format = repmat('%s ',1,ny + 6);
%format = '%s %s %f %f %f %f';
data   = textscan(f,format);
id     = data{1,2};
y=str2double(string(table2array(cell2table([data{5 + (1:ny)}]))));
fclose(f);

% READ GENOTYPE MATRIX
% --------------------
% deal with the small number of missing genotypes in an ad hoc way by
% populating the missing entries with the mean genotype value.

fprintf('Reading genotype matrix from .traw file.\n');
marker = string([]);chr=zeros(p,1);pos=zeros(p,1);
X      = zeros(n,p);
f      = fopen(genofile,'r');
format = repmat('%s ',1,n + 6);
fgetl(f);
tic
for i = 1:p
  fprintf('line #%06d ',i);%change the reading formt to read all data inside 
  fprintf(repmat('\b',1,13));
  %note the tram file format...
  data      = textscan(f,format,1,'Delimiter','	');%only scan ones, note the delimiter format was the most important
  marker(i) = string(table2array(cell2table([data{2}])));
  chr(i)=str2double(string(table2array(cell2table([data{1}]))));
  pos(i)=str2double(string(table2array(cell2table([data{4}]))));
  data      = [data{6 + (1:n)}];%deleted the former six data only keep the genotype

  %impute the genotype data for the ith marker.
  X(:,i) = -1;%the before all was the zero ,so changed to the others
  X(strcmp(data,'0'),i) = 0; %read the data to the right format to the mat 
  X(strcmp(data,'1'),i) = 1;
  X(strcmp(data,'2'),i) = 2;

  % impute the missing genotypes by the mean or medain genotype value.
  j      = strcmp(data,'NA');
  if methods ==1 
    X(j,i) = mean(X(~j,i));
  else
    X(i,j)=median(X(~j,i));
  end
end
marker=marker';
toc
fprintf('\n');
fclose(f);
x=X;clear X;
% SAVE GENOTYPE MATRIX
% --------------------
fprintf('Saving genotype matrix to .mat file.\n');
save(outfile,'id','marker','x','chr','pos','y','-v7.3');
end
