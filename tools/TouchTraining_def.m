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

tr.name = SubjectName.String
tr.name = get(TouchTraining.SubjectName,'String');
tr.phase = get(TouchTraining.Phase,'String');
tr.bg = get(TouchTraining.BackgroundColour,'String');
tr.fg = get(TouchTraining.TouchColour,'String');
tr.stream = get(TouchTraining.StreamVideo,'Value');

startTraining(tr)
end

 
## @deftypefn  {} {@var{ret} = } show_TouchTraining(varargin)
##
## Create windows controls over a figure, link controls with callbacks and return 
## a window struct representation.
##
## @end deftypefn
function ret = show_TouchTraining(varargin)
  _scrSize = get(0, "screensize");
  _xPos = (_scrSize(3) - 911)/2;
  _yPos = (_scrSize(4) - 591)/2;
   TouchTraining = figure ( ... 
	'Color', [0.937 0.937 0.937], ...
	'Position', [_xPos _yPos 911 591], ...
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
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'Position', [0 5 907 581], ... 
	'title', 'Touch Training Settings', ... 
	'TitlePosition', 'lefttop', ... 
	'visible', 'on');
  StartButton = uicontrol( ...
	'parent',Settings, ... 
	'Style','pushbutton', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.643 0.000 0.000], ... 
	'Position', [710 9 190 59], ... 
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
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [35 479 294 47], ... 
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
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [35 414 294 47], ... 
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
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [35 349 294 47], ... 
	'String', '[0 0 0]', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  TouchColour = uicontrol( ...
	'parent',Settings, ... 
	'Style','edit', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [1.000 1.000 1.000], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'center', ... 
	'Position', [35 284 294 47], ... 
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
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [335 482 157 39], ... 
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
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [335 417 166 39], ... 
	'String', 'Training Phase', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  Label_3 = uicontrol( ...
	'parent',Settings, ... 
	'Style','text', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [335 352 218 39], ... 
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
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'HorizontalAlignment', 'left', ... 
	'Position', [335 287 150 39], ... 
	'String', 'Touch Colour', ... 
	'TooltipString', '', ... 
	'visible', 'on');
  StreamVideo = uicontrol( ...
	'parent',Settings, ... 
	'Style','checkbox', ... 
	'Units', 'pixels', ... 
	'BackgroundColor', [0.937 0.937 0.937], ... 
	'FontAngle', 'normal', ... 
	'FontName', 'Source Sans 3', ... 
	'FontSize', 10, 'FontUnits', 'points', ... 
	'FontWeight', 'normal', ... 
	'ForegroundColor', [0.000 0.000 0.000], ... 
	'Position', [295 216 279 45], ... 
	'String', 'Stream Video', ... 
	'TooltipString', '', ... 
	'Min', 0, 'Max', 1, 'Value', 1, ... 
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
      'StreamVideo', StreamVideo);


  set (StartButton, 'callback', {@TouchTraining_StartButton_doIt, TouchTraining});
  dlg = struct(TouchTraining);

  set(TouchTraining.figure, 'visible', 'on');

%
% The source code written here will be executed when
% windows load. Works like 'onLoad' event of other languages.
%



  ret = TouchTraining;
end

