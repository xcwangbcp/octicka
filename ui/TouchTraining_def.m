## -*- texinfo -*-
## @deftypefn  {} {} dummy()
##
## This is a dummy function documentation. This file have a lot functions
## and each one have a little documentation. This text is to avoid a warning when
## install this file as part of package.
## @end deftypefn
##
## Set the graphics toolkit and force read this file as script file (not a function file).
##
graphics_toolkit qt;
##


##
##
## Begin callbacks definitions 
##

## @deftypefn  {} {} TouchTraining_StartButton_doIt (@var{src}, @var{data}, @var{TouchTraining})
##
## Define a callback for default action of StartButton control.
##
## @end deftypefn
function TouchTraining_StartButton_doIt(src, data, TouchTraining)

% This code will be executed when user click the button control.
% As default, all events are deactivated, to activate must set the
% property 'generateCallback' from the properties editor

tr.name = get(TouchTraining.SubjectName,'String');
tr.phase = str2num(get(TouchTraining.Phase,'String'));
tr.bg = str2num(get(TouchTraining.BackgroundColour,'String'));
tr.fg = str2num(get(TouchTraining.TouchColour,'String'));
tr.distance = str2num(get(TouchTraining.Distance,'String'));
tr.density = str2num(get(TouchTraining.Density,'String'));
tr.debug = logical(get(TouchTraining.Debug,'Value'));

startTraining(tr)
end

## @deftypefn  {} {} TouchTraining_Load_doIt (@var{src}, @var{data}, @var{TouchTraining})
##
## Define a callback for default action of Load control.
##
## @end deftypefn
function TouchTraining_Load_doIt(src, data, TouchTraining)

% This code will be executed when user click the button control.
% As default, all events are deactivated, to activate must set the
% property 'generateCallback' from the properties editor

disp('Hello')
end

## @deftypefn  {} {} TouchTraining_startVideo_doIt (@var{src}, @var{data}, @var{TouchTraining})
##
## Define a callback for default action of startVideo control.
##
## @end deftypefn
function TouchTraining_startVideo_doIt(src, data, TouchTraining)

% This code will be executed when user click the button control.
% As default, all events are deactivated, to activate must set the
% property 'generateCallback' from the properties editor

pid = get(TouchTraining.startVideo,'TooltipString');
if ~isempty(pid); warning('Camera running...');return; end

pid = rpistreamer;
if ~isempty(pid);
	fprintf('===> RPi Video stream PID = %i activated!\n',pid);
	set(TouchTraining.startVideo,'String',sprintf('Started [%i]',pid));
	set(TouchTraining.startVideo,'TooltipString',sprintf('%i',pid));
end

end

## @deftypefn  {} {} TouchTraining_stopVideo_doIt (@var{src}, @var{data}, @var{TouchTraining})
##
## Define a callback for default action of stopVideo control.
##
## @end deftypefn
function TouchTraining_stopVideo_doIt(src, data, TouchTraining)

% This code will be executed when user click the button control.
% As default, all events are deactivated, to activate must set the
% property 'generateCallback' from the properties editor

pid = str2num(get(TouchTraining.startVideo,'TooltipString'));

if exist('pid','var') && ~isempty(pid)
	fprintf('===> Try to kill PID = %i\n',pid);	
	try
		system('pkill -9 libcamera-vid');
		system(['kill -9 ' num2str(pid+1)]);
		system(['kill -9 ' num2str(pid)]);
		system('pkill -9 libcamera-vid');
	end
	set(TouchTraining.startVideo,'String',sprintf('Start Video',pid));
	set(TouchTraining.startVideo,'Tooltipstring','');
end
end

 
## @deftypefn  {} {@var{ret} = } show_TouchTraining(varargin)
##
## Create windows controls over a figure, link controls with callbacks and return 
## a window struct representation.
##
## @end deftypefn
function ret = show_TouchTraining(varargin)
  _scrSize = get(0, "screensize");
  _xPos = (_scrSize(3) - 912)/2;
  _yPos = (_scrSize(4) - 602)/2;
   TouchTraining = figure ( ... 
	'Color', [0.937 0.937 0.937], ...
	'Position', [_xPos _yPos 912 602], ...
	'resize', 'off', ...
	'windowstyle', 'normal', ...
	'MenuBar', 'none');
	 set(TouchTraining, 'visible', 'off');
  Settings = uibuttongroup( ...
	'parent',TouchTraining, ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'BorderWidth', 1, ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 16, 'FontUnits', 'points', ... 
	'FontWeight', 'bold', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'Position', [5 17 900 580], ... 
	'title', 'Touch Training Settings', ... 
	'TitlePosition', 'righttop', ... 
	'visible', 'on');
  StartButton = uicontrol( ...
	'parent',Settings, ... 
	'Style','pushbutton', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'bold', ... 
	'ForegroundColor', [0.643 0.000 0.000], ... 
	'Position', [700 8 190 59], ... 
	'String', 'Start!', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  SubjectName = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [10 513 290 47], ... 
	'String', 'Test', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Phase = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [10 453 290 47], ... 
	'String', '1', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  BackgroundColour = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [10 333 290 47], ... 
	'String', '[0.2 0.2 0.2]', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  TouchColour = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [10 273 290 47], ... 
	'String', '[1 1 1]', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Label_1 = uicontrol( ...
	'parent',Settings, ... 
	'Style','text', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 12, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [310 521 93 24], ... 
	'String', 'Subject Name', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Label_2 = uicontrol( ...
	'parent',Settings, ... 
	'Style','text', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 12, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [310 461 140 24], ... 
	'String', 'Training Phase (1-20)', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Label_3 = uicontrol( ...
	'parent',Settings, ... 
	'Style','text', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 12, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [310 341 129 24], ... 
	'String', 'Background Colour', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Label_4 = uicontrol( ...
	'parent',Settings, ... 
	'Style','text', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 12, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [310 281 89 24], ... 
	'String', 'Touch Colour', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Debug = uicontrol( ...
	'parent',Settings, ... 
	'Style','checkbox', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 12, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'Position', [15 155 184 45], ... 
	'String', 'Debug', ... 
	'TooltipString', '', ... 
	'Min', 0, 'Max', 1, 'Value', 0, ... 
	'visible', 'on');
  Load = uicontrol( ...
	'parent',Settings, ... 
	'Style','pushbutton', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'Position', [10 9 180 56], ... 
	'String', 'Load', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  startVideo = uicontrol( ...
	'parent',Settings, ... 
	'Style','pushbutton', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'Position', [240 9 180 56], ... 
	'String', 'Start Video', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  stopVideo = uicontrol( ...
	'parent',Settings, ... 
	'Style','pushbutton', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'Position', [475 9 180 56], ... 
	'String', 'Stop Video', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Density = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [160 213 140 47], ... 
	'String', '80', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Distance = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 14, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [10 213 140 47], ... 
	'String', '57.3', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Label_5 = uicontrol( ...
	'parent',Settings, ... 
	'Style','text', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 12, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [310 226 119 24], ... 
	'String', 'Distance / Density', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Timeout = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 16, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [10 393 290 47], ... 
	'String', '2', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Label_6 = uicontrol( ...
	'parent',Settings, ... 
	'Style','text', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 12, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [310 401 98 24], ... 
	'String', 'Timeout (secs)', ... 
	'TooltipString', '', ... 
	'visible', 'on');

  TouchTraining = struct( ...
      'figure', TouchTraining, ...
      'Settings', Settings, ...
      'StartButton', StartButton, ...
      'SubjectName', SubjectName, ...
      'Phase', Phase, ...
      'BackgroundColour', BackgroundColour, ...
      'TouchColour', TouchColour, ...
      'Label_1', Label_1, ...
      'Label_2', Label_2, ...
      'Label_3', Label_3, ...
      'Label_4', Label_4, ...
      'Debug', Debug, ...
      'Load', Load, ...
      'startVideo', startVideo, ...
      'stopVideo', stopVideo, ...
      'Density', Density, ...
      'Distance', Distance, ...
      'Label_5', Label_5, ...
      'Timeout', Timeout, ...
      'Label_6', Label_6);


  set (StartButton, 'callback', {@TouchTraining_StartButton_doIt, TouchTraining});
  set (Load, 'callback', {@TouchTraining_Load_doIt, TouchTraining});
  set (startVideo, 'callback', {@TouchTraining_startVideo_doIt, TouchTraining});
  set (stopVideo, 'callback', {@TouchTraining_stopVideo_doIt, TouchTraining});
  dlg = struct(TouchTraining);

  set(TouchTraining.figure, 'visible', 'on');

%
% The source code written here will be executed when
% windows load. Works like 'onLoad' event of other languages.
%



  ret = TouchTraining;
end

