%auto_anlys_gui is a GUI used to run all our automated analysis. It can
%handle both automated post processing analysis and the automated
%contingency updates separately. Both these analyses are run every 24
%hours. While the times can be anything, it probably makes the most sense
%to have contingency updates run shortly after post processing so that
%contingency updates will not lag too far behind processed data of rodent
%behavior.
%
%GENERAL DESIGN
%Most functions in auto_anlys_gui are a few lines long, and all are
%under 30 lines. All intensive GUI interaction as well as contingency
%computation are handled by helper functions.
%
% matlabmail :: (not matlabmailcpy, check documentation) is necessary to
%       allow mail notifications
% 
% Post Processing Analysis
%   
%   init_automated_analysis :: sets up an automatic timer that will
%       conduct post processing analysis on all unprocessed files in
%       the experiment directory.
%   scheduled_analysis :: this is the function that runs on timer
%       callback - it calls our standard multi day processing scripts
%       (mult_doAll) edit this function to modify general post 
%       processing analysis procedure (how logging, mail notifications,
%       reports, etc. are handled. specific analysis changes
%       should be called in multi_doAll or doAllpp (i.e. adding in
%       a function that saves velocity distributions would be done
%       in doAllpp).
%   directories_to_do :: simple utility that returns a standard
%       directory list of which directories need to be post
%       processed.
%   behavior_report :: generates a cell array (n x 1) summary of
%       mouse behavior
% 
% Automated Contingency Updates
%
%   init_auto_contingency_update :: like init_automated_analysis, sets
%       up an automatic timer that on callbacks calls a helper function
%       (in the same file) that handles contingency updates through the
%       GUI. Unlike init_automated_analysis, this function will not
%       work independently of the GUI.
%   update_all_boxes_anlys_gui :: a helper function that attempts
%       to find contingency/stats information for all boxes, and
%       updates the GUI to display these
%   write_out_all_contingencies_anlys_gui :: a helper function that
%       writes out the contingency information, and also archives the
%       old contingency.
%   recommend_contingencies :: called by update_all_boxes_anlys_gui to
%       output recommendations for new contingencies. THIS file is the
%       one that should be edited if you want to make changes to the
%       computation of new contingencies. In order to avoid making this
%       too large, avoid putting long intensive computations in this
%       file. (See how center hold threshold is computed by calling
%       multi_js_touch_dist);
% 
% Design Details:
% Most of the GUI is various text boxes, some uneditable to just display
% information about current contingencies, others are editable because they
% change future contingencies. 

function varargout = auto_anlys_gui(varargin)
% AUTO_ANLYS_GUI MATLAB code for auto_anlys_gui.fig
%      AUTO_ANLYS_GUI, by itself, creates a new AUTO_ANLYS_GUI or raises the existing
%      singleton*.
%
%      H = AUTO_ANLYS_GUI returns the handle to a new AUTO_ANLYS_GUI or the handle to
%      the existing singleton*.
%
%      AUTO_ANLYS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTO_ANLYS_GUI.M with the given input arguments.
%
%      AUTO_ANLYS_GUI('Property','Value',...) creates a new AUTO_ANLYS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before auto_anlys_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to auto_anlys_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help auto_anlys_gui

% Last Modified by GUIDE v2.5 03-Dec-2016 15:53:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @auto_anlys_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @auto_anlys_gui_OutputFcn, ...
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


% --- Executes just before auto_anlys_gui is made visible.
function auto_anlys_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to auto_anlys_gui (see VARARGIN)

% Choose default command line output for auto_anlys_gui
handles.output = hObject;

set(handles.SplitSel1,'Value',1);
set(handles.SplitSel2,'Value',1);
set(handles.SplitSel3,'Value',1);
set(handles.SplitSel4,'Value',1);

set(handles.MovDir1,'Value',1);
set(handles.MovDir2,'Value',1);
set(handles.MovDir3,'Value',1);
set(handles.MovDir4,'Value',1);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes auto_anlys_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = auto_anlys_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in setexptdir.
function setexptdir_Callback(hObject, eventdata, handles)
% hObject    handle to setexptdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exptdir = uipickfiles('output', 'char', 'numFiles', 1);
if ~isempty(exptdir)
    set(handles.exptdirlabel, 'String', exptdir);
    try
        oldtimer = handles.automated_ppanalysis_timer;
        stop(oldtimer);
        delete(oldtimer);
        handles.automated_ppanalysis_timer = [];
    catch
    end
    try
        othertimer = handles.automated_contingency_timer;
        stop(othertimer);
        delete(othertimer);
        handles.automated_contingency_timer = [];
    catch
    end;
end
guidata(hObject, handles);

function ppschedtime_Callback(hObject, eventdata, handles)
% hObject    handle to ppschedtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function ppschedtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ppschedtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function [hours, min] = get_time(textbox)
starttime = get(textbox, 'String');
try
    starttime = strsplit(starttime, ':');
    hours = str2num(starttime{1});
    min = str2num(starttime{2}); %#ok<*ST2NM>
    if length(starttime) ~= 2; 
        error('Bad Time format'); 
    end;
catch e
    disp(getReport(e));
    msgbox('Bad time format in automated analysis start time box. Must be HH:MM (24 hr format)',...
        'Error','error');
    hours = 01; min = 00;
end


% --- Executes on button press in ppstartstop.
function ppstartstop_Callback(hObject, eventdata, handles)
% hObject    handle to ppstartstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

onoff = get(hObject, 'String');
if strcmp(onoff, 'Start')
    [hours, min] = get_time(handles.ppschedtime);    
    exptdir = get(handles.exptdirlabel, 'String');
    if length(exptdir)<3
        msgbox(['Select an experiment data directory before attempting to ',...
                'start automated analysis.'], 'Error', 'error');
        error('No experiment directory selected.');
    else
        handles.automated_ppanalysis_timer = init_automated_analysis(exptdir, [hours min]);  
        set(hObject, 'String', 'Stop');
    end
elseif strcmp(onoff, 'Stop')
    oldtimer = handles.automated_ppanalysis_timer;
    stop(oldtimer);
    delete(oldtimer);
    handles.automated_ppanalysis_timer = [];
    set(hObject, 'String', 'Start');

else
    error('timer nonexistent, despite having started');
end
guidata(hObject, handles);

% --- Executes on button press in contstartstop. Does all error handling as
% well, and intended to be called by a timer as well when necessary.
function contstartstop_Callback(hObject, eventdata, handles)
% hObject    handle to contstartstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
state = get(handles.contstartstop, 'String');
exptdir = get(handles.exptdirlabel, 'String');
if strcmp(state, 'Recommend')
    handles = update_all_boxes_anlys_gui(handles);
elseif strcmp(state, 'Start')    
    if length(exptdir)<3
        msgbox(['Select an experiment data directory before attempting to ',...
                'start automated analysis.'], 'Error', 'error');
        error('No experiment directory selected.');
    end
    [hours, min] = get_time(handles.contingencyschedtime);
    handles.automated_contingency_timer = ...
        init_auto_contingency_update(handles, [hours min]);
    set(hObject, 'String', 'Stop');
elseif strcmp(state, 'Stop')
    oldtimer = handles.automated_contingency_timer;
    stop(oldtimer); delete(oldtimer);
    handles.automated_contingency_timer;
    set(hObject, 'String', 'Start');
end
guidata(hObject, handles);


function contingencyschedtime_Callback(hObject, eventdata, handles)
% hObject    handle to contingencyschedtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contingencyschedtime as text
%        str2double(get(hObject,'String')) returns contents of contingencyschedtime as a double


% --- Executes during object creation, after setting all properties.
function contingencyschedtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contingencyschedtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in contautoenable.
function contautoenable_Callback(hObject, eventdata, handles)
% hObject    handle to contautoenable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of contautoenable
if get(hObject, 'Value')
   set(handles.updatecont, 'Visible', 'off');
   set(handles.text4, 'Visible', 'on');
   set(handles.contingencyschedtime, 'Visible', 'on');
   set(handles.contstartstop, 'String', 'Start');
else
   set(handles.updatecont, 'Visible', 'on');
   set(handles.text4, 'Visible', 'off');
   set(handles.contingencyschedtime, 'Visible', 'off');
   set(handles.contstartstop, 'String', 'Recommend');
   try
       oldtimer = handles.automated_contingency_timer;
       stop(oldtimer); delete(oldtimer);
       handles.automated_contingency_timer;
   catch
   end
end


% --- Executes on selection change in contdayselect.
function contdayselect_Callback(hObject, eventdata, handles)
% hObject    handle to contdayselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns contdayselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from contdayselect


% --- Executes during object creation, after setting all properties.
function contdayselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contdayselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rewardrate_Callback(hObject, eventdata, handles)
% hObject    handle to rewardrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rewardrate as text
%        str2double(get(hObject,'String')) returns contents of rewardrate as a double
rewrate = get(hObject, 'String');
rewrate = str2num(rewrate);
if rewrate<=0 || rewrate>1.0
    msgbox('Invalid range for reward rate. Enter a new value.');
    set(hObject, 'String', '0.25');
    guidata(hObject, handles);
end



% --- Executes during object creation, after setting all properties.
function rewardrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rewardrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in updatecont.
function updatecont_Callback(hObject, eventdata, handles)
% hObject    handle to updatecont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
write_out_all_contingencies_anlys_gui(handles, 1);

% --- Executes on button press in helpbutton.
function helpbutton_Callback(hObject, eventdata, handles)
% hObject    handle to helpbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pcoverride.
function pcoverride_Callback(hObject, eventdata, handles)
% hObject    handle to pcoverride (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pcoverride

function newthresh1_Callback(hObject, eventdata, handles)
% hObject    handle to newthresh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newthresh1 as text
%        str2double(get(hObject,'String')) returns contents of newthresh1 as a double


% --- Executes during object creation, after setting all properties.
function newthresh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newthresh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function newht1_Callback(hObject, eventdata, handles)
% hObject    handle to newht1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newht1 as text
%        str2double(get(hObject,'String')) returns contents of newht1 as a double


% --- Executes during object creation, after setting all properties.
function newht1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newht1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newminangle1_l_Callback(hObject, eventdata, handles)
% hObject    handle to newminangle1_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newminangle1_l as text
%        str2double(get(hObject,'String')) returns contents of newminangle1_l as a double


% --- Executes during object creation, after setting all properties.
function newminangle1_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle1_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newholdthresh1_Callback(hObject, eventdata, handles)
% hObject    handle to newholdthresh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newholdthresh1 as text
%        str2double(get(hObject,'String')) returns contents of newholdthresh1 as a double


% --- Executes during object creation, after setting all properties.
function newholdthresh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newholdthresh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newmaxangle1_l_Callback(hObject, eventdata, handles)
% hObject    handle to newmaxangle1_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newmaxangle1_l as text
%        str2double(get(hObject,'String')) returns contents of newmaxangle1_l as a double


% --- Executes during object creation, after setting all properties.
function newmaxangle1_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle1_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function newthresh2_Callback(hObject, eventdata, handles)
% hObject    handle to newthresh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newthresh2 as text
%        str2double(get(hObject,'String')) returns contents of newthresh2 as a double


% --- Executes during object creation, after setting all properties.
function newthresh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newthresh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function newht2_Callback(hObject, eventdata, handles)
% hObject    handle to newht2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newht2 as text
%        str2double(get(hObject,'String')) returns contents of newht2 as a double


% --- Executes during object creation, after setting all properties.
function newht2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newht2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newminangle2_l_Callback(hObject, eventdata, handles)
% hObject    handle to newminangle2_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newminangle2_l as text
%        str2double(get(hObject,'String')) returns contents of newminangle2_l as a double


% --- Executes during object creation, after setting all properties.
function newminangle2_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle2_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newholdthresh2_Callback(hObject, eventdata, handles)
% hObject    handle to newholdthresh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newholdthresh2 as text
%        str2double(get(hObject,'String')) returns contents of newholdthresh2 as a double


% --- Executes during object creation, after setting all properties.
function newholdthresh2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newholdthresh2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newmaxangle2_l_Callback(hObject, eventdata, handles)
% hObject    handle to newmaxangle2_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newmaxangle2_l as text
%        str2double(get(hObject,'String')) returns contents of newmaxangle2_l as a double


% --- Executes during object creation, after setting all properties.
function newmaxangle2_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle2_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function newthresh3_Callback(hObject, eventdata, handles)
% hObject    handle to newthresh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newthresh3 as text
%        str2double(get(hObject,'String')) returns contents of newthresh3 as a double


% --- Executes during object creation, after setting all properties.
function newthresh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newthresh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newht3_Callback(hObject, eventdata, handles)
% hObject    handle to newht3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newht3 as text
%        str2double(get(hObject,'String')) returns contents of newht3 as a double


% --- Executes during object creation, after setting all properties.
function newht3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newht3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newminangle3_l_Callback(hObject, eventdata, handles)
% hObject    handle to newminangle3_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newminangle3_l as text
%        str2double(get(hObject,'String')) returns contents of newminangle3_l as a double


% --- Executes during object creation, after setting all properties.
function newminangle3_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle3_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newholdthresh3_Callback(hObject, eventdata, handles)
% hObject    handle to newholdthresh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newholdthresh3 as text
%        str2double(get(hObject,'String')) returns contents of newholdthresh3 as a double


% --- Executes during object creation, after setting all properties.
function newholdthresh3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newholdthresh3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newmaxangle3_l_Callback(hObject, eventdata, handles)
% hObject    handle to newmaxangle3_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newmaxangle3_l as text
%        str2double(get(hObject,'String')) returns contents of newmaxangle3_l as a double


% --- Executes during object creation, after setting all properties.
function newmaxangle3_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle3_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function newthresh4_Callback(hObject, eventdata, handles)
% hObject    handle to newthresh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newthresh4 as text
%        str2double(get(hObject,'String')) returns contents of newthresh4 as a double


% --- Executes during object creation, after setting all properties.
function newthresh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newthresh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newht4_Callback(hObject, eventdata, handles)
% hObject    handle to newht4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newht4 as text
%        str2double(get(hObject,'String')) returns contents of newht4 as a double


% --- Executes during object creation, after setting all properties.
function newht4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newht4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newminangle4_l_Callback(hObject, eventdata, handles)
% hObject    handle to newminangle4_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newminangle4_l as text
%        str2double(get(hObject,'String')) returns contents of newminangle4_l as a double


% --- Executes during object creation, after setting all properties.
function newminangle4_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle4_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newholdthresh4_Callback(hObject, eventdata, handles)
% hObject    handle to newholdthresh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newholdthresh4 as text
%        str2double(get(hObject,'String')) returns contents of newholdthresh4 as a double


% --- Executes during object creation, after setting all properties.
function newholdthresh4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newholdthresh4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function newmaxangle4_l_Callback(hObject, eventdata, handles)
% hObject    handle to newmaxangle4_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of newmaxangle4_l as text
%        str2double(get(hObject,'String')) returns contents of newmaxangle4_l as a double


% --- Executes during object creation, after setting all properties.
function newmaxangle4_l_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle4_l (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function oldthresh1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldthresh1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function scrollbar_Callback(hObject, eventdata, handles)
% hObject    handle to scrollbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
percent = get(hObject, 'Value');
pos = get(handles.scrollpanel, 'Position');
pos(2) = percent*1060*(-1);
set(handles.scrollpanel, 'Position', pos);

% --- Executes during object creation, after setting all properties.
function scrollbar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scrollbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
    set(hObject, 'Value', 1);
end


% --- Executes during object creation, after setting all properties.
function oldmaxangle3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldmaxangle3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function oldminangle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldminangle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function oldmaxangle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldmaxangle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function newminangle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function newmaxangle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function newminangle3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function newmaxangle3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function oldminangle2_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to oldminangle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function oldminangle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldminangle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function oldmaxangle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldmaxangle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function oldminangle4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldminangle4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function oldmaxangle4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oldmaxangle4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function newminangle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function newmaxangle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function newminangle4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newminangle4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function newmaxangle4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to newmaxangle4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SplitSel1.
function SplitSel1_Callback(hObject, eventdata, handles)
% hObject    handle to SplitSel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SplitSel1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SplitSel1


% --- Executes during object creation, after setting all properties.
function SplitSel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SplitSel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MovDir1.
function MovDir1_Callback(hObject, eventdata, handles)
% hObject    handle to MovDir1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovDir1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovDir1


% --- Executes during object creation, after setting all properties.
function MovDir1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovDir1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SplitSel2.
function SplitSel2_Callback(hObject, eventdata, handles)
% hObject    handle to SplitSel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SplitSel2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SplitSel2


% --- Executes during object creation, after setting all properties.
function SplitSel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SplitSel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MovDir2.
function MovDir2_Callback(hObject, eventdata, handles)
% hObject    handle to MovDir2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovDir2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovDir2


% --- Executes during object creation, after setting all properties.
function MovDir2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovDir2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SplitSel3.
function SplitSel3_Callback(hObject, eventdata, handles)
% hObject    handle to SplitSel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SplitSel3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SplitSel3


% --- Executes during object creation, after setting all properties.
function SplitSel3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SplitSel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MovDir3.
function MovDir3_Callback(hObject, eventdata, handles)
% hObject    handle to MovDir3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovDir3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovDir3


% --- Executes during object creation, after setting all properties.
function MovDir3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovDir3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SplitSel4.
function SplitSel4_Callback(hObject, eventdata, handles)
% hObject    handle to SplitSel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SplitSel4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SplitSel4


% --- Executes during object creation, after setting all properties.
function SplitSel4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SplitSel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MovDir4.
function MovDir4_Callback(hObject, eventdata, handles)
% hObject    handle to MovDir4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MovDir4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MovDir4

function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% do nothing

% --- Executes during object creation, after setting all properties.
function MovDir4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MovDir4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
