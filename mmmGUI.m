function varargout = mmmGUI(varargin)
% MMMGUI MATLAB code for mmmGUI.fig
%      MMMGUI, by itself, creates a new MMMGUI or raises the existing
%      singleton*.
%
%      H = MMMGUI returns the handle to a new MMMGUI or the handle to
%      the existing singleton*.
%
%      MMMGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MMMGUI.M with the given input arguments.
%
%      MMMGUI('Property','Value',...) creates a new MMMGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mmmGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mmmGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mmmGUI

% Last Modified by GUIDE v2.5 04-Oct-2015 15:54:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mmmGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mmmGUI_OutputFcn, ...
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


% --- Executes just before mmmGUI is made visible.
function mmmGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mmmGUI (see VARARGIN)

% Choose default command line output for mmmGUI
handles.output = hObject;

handles.isListening = false;
handles.isRunning = false;

set(handles.txtStatus, 'String', {'[status messages here; first open a movie]'});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mmmGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = mmmGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pshStart.
function pshStart_Callback(hObject, eventdata, handles)
% hObject    handle to pshStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.isRunning
    handles.isRunning = false;
    handles.mmmObj.stop();
    set(handles.pshStart, 'String', 'Start');
else
    handles.isRunning = true;
    handles.mmmObj.mouseName = get(handles.edtMouseName, 'String');
    handles.mmmObj.expNum = str2num(get(handles.edtExpNum, 'String'));
    handles.mmmObj.start();
    set(handles.pshStart, 'String', 'Stop');
    set(handles.edtExpDate, 'String', datestr(handles.mmmObj.expDate, 'yyyy-mm-dd'));
    set(handles.edtExpNum, 'String', num2str(handles.mmmObj.expNum));
end
guidata(hObject, handles);

% --- Executes on button press in pshListen.
function pshListen_Callback(hObject, eventdata, handles)
% hObject    handle to pshListen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.isListening
    try
        for s = 1:length(handles.mmmObj.expServerObj)
            handles.mmmObj.expServerObj{s}.disconnect();
        end
    catch
    end
    handles.mmmObj.expServerObj = [];
    stop(handles.mmmObj.connectTimer)
    handles.isListening = false;
    set(handles.pshListen, 'String', 'Listen');
else
    handles.mmmObj.listenForStart();
    handles.isListening = true;
    set(handles.pshListen, 'String', 'Stop Listening');
end
guidata(hObject, handles);

% --- Executes on selection change in popChooseMovie.
function popChooseMovie_Callback(hObject, eventdata, handles)
% hObject    handle to popChooseMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popChooseMovie contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popChooseMovie
contents = cellstr(get(hObject,'String'));

mmmObj = MouseMovieManager(contents{get(hObject,'Value')});
mmmObj.statusCallback = @mmm.guiStatusCallback;
mmmObj.guiHandle = hObject;
handles.mmmObj = mmmObj;
set(handles.txtVideoID, 'String', contents{get(hObject,'Value')});
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function popChooseMovie_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popChooseMovie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
availableVideos = mmm.openVideoObject('listAll');
set(hObject, 'String', availableVideos);

% --- Executes on button press in pshReset.
function pshReset_Callback(hObject, eventdata, handles)
% hObject    handle to pshReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mmmObj.reset();

% --- Executes on button press in pshSetROI.
function pshSetROI_Callback(hObject, eventdata, handles)
% hObject    handle to pshSetROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mmmObj.setROI();

% --- Executes on button press in pshSetLineROI.
function pshSetLineROI_Callback(hObject, eventdata, handles)
% hObject    handle to pshSetLineROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.mmmObj.setLineROI();

% --- Executes on button press in pshClose.
function pshClose_Callback(hObject, eventdata, handles)
% hObject    handle to pshClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'mmmObj')
    handles.mmmObj.close();
end
close(handles.output);



function edtMouseName_Callback(hObject, eventdata, handles)
% hObject    handle to edtMouseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtMouseName as text
%        str2double(get(hObject,'String')) returns contents of edtMouseName as a double


% --- Executes during object creation, after setting all properties.
function edtMouseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtMouseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtExpNum_Callback(hObject, eventdata, handles)
% hObject    handle to edtExpNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtExpNum as text
%        str2double(get(hObject,'String')) returns contents of edtExpNum as a double


% --- Executes during object creation, after setting all properties.
function edtExpNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtExpNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtExpDate_Callback(hObject, eventdata, handles)
% hObject    handle to edtExpDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtExpDate as text
%        str2double(get(hObject,'String')) returns contents of edtExpDate as a double


% --- Executes during object creation, after setting all properties.
function edtExpDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtExpDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
