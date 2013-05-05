function varargout = installationUnix(varargin)
% INSTALLATIONUNIX MATLAB code for installationUnix.fig
%      INSTALLATIONUNIX, by itself, creates a new INSTALLATIONUNIX or raises the existing
%      singleton*.
%
%      H = INSTALLATIONUNIX returns the handle to a new INSTALLATIONUNIX or the handle to
%      the existing singleton*.
%
%      INSTALLATIONUNIX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INSTALLATIONUNIX.M with the given input arguments.
%
%      INSTALLATIONUNIX('Property','Value',...) creates a new INSTALLATIONUNIX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before installationUnix_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to installationUnix_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help installationUnix

% Last Modified by GUIDE v2.5 03-May-2013 15:04:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @installationUnix_OpeningFcn, ...
                   'gui_OutputFcn',  @installationUnix_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before installationUnix is made visible.
function installationUnix_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to installationUnix (see VARARGIN)

% Choose default command line output for installationUnix
handles.output = hObject;
handles.instructions =     {'1) Specify the path to EnergyPlus main directory.'};
set(handles.instructionsEdit, 'String', handles.instructions);

handles.data.eplusPathCheck = 0;
handles.data.javaPathCheck = 0;
currPath = mfilename('fullpath');
indexHome = strfind(currPath, 'installation');
currPath = currPath(1:indexHome-1);
handles.data.homePath = currPath;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes installationUnix wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = installationUnix_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------


% --- Executes during object creation, after setting all properties.
function instructionsEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to instructionsEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.textHandle = hObject;
guidata(hObject, handles);


% --------------------------------------------------------------------
function Installation_Callback(hObject, eventdata, handles)
% hObject    handle to installationunix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in replaceEplus.
function replaceEplus_Callback(hObject, eventdata, handles)
% hObject    handle to replaceEplus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles.data,'eplusPathCheck')
    if handles.data.eplusPathCheck
        % Replace RunEPlus
        if ispc
            [status,message,messageid] = copyfile([handles.data.homePath 'gui' filesep 'RunEPlus.bat'] ,[handles.data.eplusPath filesep 'RunEPlus.bat'], 'f');
            if status == 1
                set(handles.replaceEplus, 'Background', 'g');
            end
        else
            [status,message,messageid] = copyfile([handles.data.homePath 'gui' filesep 'runenergyplus'] ,[handles.data.eplusPath filesep 'bin'], 'f');
            if status == 1
                set(handles.replaceEplus, 'Background', 'g');
            end
        end    
    end
end
guidata(hObject, handles);

% --- Executes on button press in selectEplusDir.
function selectEplusDir_Callback(hObject, eventdata, handles)
% hObject    handle to selectEplusDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectEplusDir = hObject;

if ispc
    startPath = 'C:\';
else
    startPath = ['Applications' filesep];
end

[eplusPath] = uigetdir(startPath,'Select EnergyPlus Directory. (e.g. /Applications/EnergyPlusV7-2-0/)');
if ischar(eplusPath)
    handles.data.eplusPath = eplusPath;
    set(handles.EplusDirEdit, 'String', handles.data.eplusPath, 'Background', 'g');
    eplusPath = handles.data.eplusPath;
    % Check Path
    handles.data.eplusPathCheck = 1;
    
    currPath = mfilename('fullpath');
    % Remove
    indexHome = strfind(currPath, 'installFunction');
    currPath = currPath(1:indexHome-1);
    save([currPath 'gui' filesep 'eplusPath.mat'],'eplusPath');
    saveMlepSettings();
end
% Update handles structure
guidata(hObject, handles);

function EplusDirEdit_Callback(hObject, eventdata, handles)
% hObject    handle to EplusDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EplusDirEdit as text
%        str2double(get(hObject,'String')) returns contents of EplusDirEdit as a double


% --- Executes during object creation, after setting all properties.
function EplusDirEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EplusDirEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
guidata(hObject, handles);


% --- Executes on button press in DoneButton.
function DoneButton_Callback(hObject, eventdata, handles)
% hObject    handle to DoneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Close GUI
delete(gcf);


