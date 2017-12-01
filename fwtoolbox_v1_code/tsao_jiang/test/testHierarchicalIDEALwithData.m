% testHierarchicalIDEALwithInvivo.m is a function for load invivo dataset
% to test Hierarchical IDEAL algorithm
% 
% As Hierarchical IDEAL algorithm requires TEs to be optimized echo times
% based on Pineda et al. MRM. 54: 625-635. 2005, 
%        


% Jeff Tsao & Yun Jiang -- Sept 16, 2011
% -- Oct 3, 2011 - Updated with interactive GUI

function [outParams,outParamsMP] = testHierarchicalIDEALwithInvivo(filename, algoParams);
if nargin<1, filename=[]; end
if nargin<2, algoParams=[]; end
%if nargin<2, waterfatppmshift = []; end;
%if isempty(waterfatppmshift), waterfatppmshift = 3.28; end;

[BASEPATH,tmpfile] = fileparts(mfilename('fullpath'));clear tmpfile;
tmp = BASEPATH; addpath(tmp); fprintf('Adding to path: %s\n',tmp); clear tmp;

if isempty(filename),
  p = pwd;
  while 1,
    datapath = fullfile(BASEPATH,'data');
    if exist(datapath,'dir'), cd(datapath); break; end
    datapath = fullfile(BASEPATH,'test','data');
    if exist(datapath,'dir'), cd(datapath); break; end
    break;
  end; clear datapath;
  [tmpfile, tmppath] = uigetfile('*.mat', 'Pick a dataset file to load');
  if isequal(tmpfile,0) | isequal(tmppath,0), cd(p); clear p; return; end
  filename = fullfile(tmppath,tmpfile); clear tmpfile tmppath;
  cd(p); clear p;
end

tic;
fprintf('Loading %s',filename);
load (filename);
if ~exist('imDataParams','var') && exist('data','var'),  % 2011.09.22 in case variable is named data
  imDataParams = data; clear data;
end
fprintf(' (%.2fs)\n',toc);
fprintf('Matrix: %d',size(imDataParams.images,1));
tmpsize = size(imDataParams.images); fprintf(' x %d',tmpsize(2:min(end,3))); 
if numel(tmpsize)>=4,
  if tmpsize(4)>1, fprintf(' x %d coils',tmpsize(4)); else fprintf(' x 1 coil'); end
end
if numel(tmpsize)>=5, fprintf(' x %d TE',tmpsize(5)); end
if numel(tmpsize)>=6, fprintf(' x %d',tmpsize(6:end)); end
fprintf('\n'); clear tmpsize;


% Set algoParams
algoParams.MinFractSizeToDivide = 0.01;
algoParams.MaxNumDiv = 7;
%algoParams.CheckTE_WaterFatPpmDiff = waterfatppmshift;

% run
outParams = fw_i2cm0c_3pluspoint_tsaojiang(imDataParams,algoParams);
if ~isempty(outParams),
  handles.figure = figure; drawnow;
  handles.outParams = outParams;
  if exist('outParamsMP','var'),
    handles.outParamsMP = outParamsMP;
  end
  handles.DataName = filename;
  guidata(handles.figure,handles);
  fw_showresults(handles);
  clear handles;
end
if nargout<2, clear outParamsMP; end
if nargout<1, clear outParams; end
