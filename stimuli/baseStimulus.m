% ========================================================================
%> @brief baseStimulus is the superclass for all octicka stimulus objects
%>
%> Superclass providing basic structure for all stimulus classes. This is a dynamic properties
%> descendant, allowing for the temporary run variables used, which get appended "name"Out, i.e.
%> speed is duplicated to a dymanic property called speedOut; it is the dynamic propertiy which is
%> used during runtime, and whose values are converted from definition units like degrees to pixel
%> values that PTB uses. The transient copies are generated on setup and removed on reset.
%>
%> @todo build up animatorManager functions
%>
%> Copyright ©2014-2022 Ian Max Andolina — released: LGPL3, see LICENCE.md
% ========================================================================
classdef baseStimulus < octickaCore

	properties
		%> X Position ± degrees relative to screen center (0,0)
		xPosition		= 0
		%> Y Position ± degrees relative to screen center (0,0)
		yPosition		= 0
		%> Size in degrees
		size			= 4
		%> Colour as a 0-1 range RGB or RGBA vector
		colour			= [1 1 1]
		%> Alpha as a 0-1 range, this gets added to the RGB colour
		alpha			= 1
		%> For moving stimuli do we start "before" our initial position? This allows you to
		%> center a stimulus at a screen location, but then drift it across that location, so
		%> if xyPosition is 0,0 and startPosition is -2 then the stimulus will start at -2 drifing
		%> towards 0.
		startPosition	= 0
		%> speed in degs/s
		speed			= 0
		%> angle in degrees
		angle			= 0
		%> delay time to display relative to stimulus onset, can set upper and lower range
		%> for random interval. This allows for a group of stimuli some to be delayed relative
		%> to others for a global stimulus onset time.
		delayTime		= 0
		%> time to turn stimulus off, relative to stimulus onset
		offTime			= Inf
		%> animation manager: can assign an animationManager() object that handles
		%> more complex animation paths than simple builtin linear motion WIP
		animator		= []
		%> override X and Y position with mouse input? Useful for RF mapping
		mouseOverride	= false
		%> true or false, whether to draw() this object
		isVisible		= true
		%> show the position on the Eyetracker display?
		showOnTracker	= true
		%> Do we print details to the commandline?
		verbose			= false
		%> dynamic properties are kept here as a structure
		dp				= []
	end

	properties (Abstract = true)
		%> general stimulus type, 'flash', 'simple' etc.
		type
	end

	properties (Abstract = true, SetAccess = protected)
		%> the stimulus family (grating, dots etc.)
		family
	end

	properties (SetAccess = protected, GetAccess = public)
		%> final centered X position in pixel coordinates PTB uses: 0,0 top-left
		%> see computePosition();
		xFinal		= []
		%> final centerd Y position in pixel coordinates PTB uses: 0,0 top-left
		%> see computePosition();
		yFinal		= []
		%> initial screen rectangle position [LEFT TOP RIGHT BOTTOM]
		dstRect		= []
		%> current screen rectangle position [LEFT TOP RIGHT BOTTOM]
		mvRect		= []
		%> tick updates +1 on each call of draw (even if delay or off is true and no stimulus is drawn, resets on each update
		tick		= 0
		%> draw tick only updates when a draw command is called, resets on each update
		drawTick	= 0
		%> pixels per degree (normally inhereted from screenManager)
		ppd		= 36
		%> is stimulus position defined as rect [true] or point [false]
		isRect		= true
	end

	properties (Dependent = true, SetAccess = protected, GetAccess = public)
		%> What our per-frame motion delta is
		delta
		%> X update which is computed from our speed and angle
		dX
		%> X update which is computed from our speed and angle
		dY
	end

	properties (Hidden = true, Transient = true)
		%> Our texture pointers for texture-based stimuli
		texture		= []
		buffertex	= []
		%> our screen manager
		sM			= []
		%> screen settings generated by sM on setup
		screenVals	= struct('ifi',1/60,'fps',60,'winRect',[0 0 1920 1080])
		%. is object set up?
		isSetup		= false
		%> is panel constructed?
		isGUI		= false
	end

	properties (Access = protected)
		postSet
		% class fieldnames
		fn
		% dp fieldnames
		fndp
		% object kinds
		doDots			= false
		doMotion		= false
		doDrift			= false
		doFlash			= false
		doAnimator	= false
		%> is mouse position within screen co-ordinates?
		mouseValid  = false
		%> mouse X position
		mouseX  = 0
		%> mouse Y position
		mouseY  = 0
		%> delay ticks to wait until display
		delayTicks  = 0
		%> ticks before stimulus turns off
		offTicks  = Inf
		%>are we setting up?
		inSetup  = false
		%> delta cache
		delta_ = []
		%> dX cache
		dX_ = []
		%> dY cache
		dY_ = []
		% deal with interaction of colour and alpha
		isInSetColour  = false
		setLoop = 0
		%> Which properties to ignore to clone when making transient copies in
		%> the setup method
		ignorePropertiesBase  = {'dp','animator','handles','ppd','sM','name','comment','fullName',''...
			'family','type','dX','dY','delta','verbose','texture','dstRect','xFinal','yFinal',''...
			'isVisible','dateStamp','paths','uuid','tick','mouseOverride','isRect',''...
			'dstRect','mvRect','sM','screenVals','isSetup','isGUI','showOnTracker',''...
			'doDots','doMotion','doDrift','doFlash','doAnimator'}
    	%> properties allowed to be passed on construction
		allowedPropertiesBase  = {'xPosition','yPosition','size','colour','verbose',''...
			'alpha','startPosition','angle','speed','delayTime','mouseOverride','isVisible'...
			'showOnTracker','animator'}
	end


	%=======================================================================
	methods %----------------------------PUBLIC METHODS
	%=======================================================================

		% ===================================================================
		%> @brief Class constructor
		%>
		%> @param varargin are passed as a structure / cell of properties which is
		%> parsed.
		%> @return instance of class.
		% ===================================================================
		function me = baseStimulus(varargin)
			me=me@octickaCore(varargin); %superclass constructor
			me.parseArgs(varargin, me.allowedPropertiesBase);
			me.fn = fieldnames(me);
		end

		% ===================================================================
		function ret = isProperty(me, prop);
			if ~isempty(me.fndp)
				f = [me.fn;me.fndp];
			else
				f = me.fn;
			end
			ret = any(strcmp(f, prop));
		end

		% ===================================================================
		function prop = addProperty(me, prop)
			if nargin < 2 || ~ischar(prop) || isempty(prop) || isempty(me)
				error([ mfilename ': addprop: Parameter must be a string.' ]);
			end
			if isempty(me.dp); me.dp = struct(); end
			prop = prop(:)';
			if ~isvarname(prop)
				error([ mfilename ': addprop: Parameter must be a valid property name.' ]);
			end
			me.dp.(prop)=[];
			me.fndp = fieldnames(me.dp);
		end

		% ===================================================================
		function varargout = subsref(me,S)
			S = subs_added(me, S);
			[varargout{1:nargout}] = builtin('subsref', me, S);
		end

    	% ===================================================================
		function varargout = subsasgn(me, S, v)
			me.postSet = [];
			if ismethod(me, 'setOut')
				v = me.setOut(S, v); % this is a pseudo Set method
			end
			S = subs_added(me,S);
			[varargout{1:nargout}] = builtin('subsasgn', me, S, v);
			if ~isempty(me.postSet); fprintf('!!!POSTSET!!!\n');feval(me.postSet); end
		end

		% ===================================================================
		function S = subs_added(me, S)
			if isempty(S); return; end
			if ischar(S); S=struct('type', '.', 'subs', S); end
			if isempty(me.fndp); return; end
			if strcmp(S(1).type, '.') && ismember(S(1).subs, me.fndp)
				if me.verbose; fprintf('»»»Modified Assign for %s\n',S(1).subs); end
				S0 = struct('type', '.', 'subs', 'dp');
				S = [ S0 S ];
			end
		end

		% ===================================================================
		%> @brief colour set method
		%> Allow 1 (R=G=B) 3 (RGB) or 4 (RGBA) value colour
		% ===================================================================
		function set.colour(me,value)
			if me.isSetup; warning('You should set colourOut to affect drawing...'); end
			me.isInSetColour = true; %#ok<*MCSUP>
			len=length(value);
			switch len
				case 4
					c = value(1:4);
					me.alpha = value(4);
				case 3
					c = [value(1:3) me.alpha]; %force our alpha to override
				case 1
					c = [value value value me.alpha]; %construct RGBA
				otherwise
					if isa(me,'gaborStimulus') || isa(me,'gratingStimulus')
						c = []; %return no colour to procedural gratings
					else
						c = [1 1 1 me.alpha]; %return white for everything else
					end
			end
			c(c<0)=0; c(c>1)=1;
			me.colour = c;
			if isProperty(me,'correctBaseColour') && me.correctBaseColour %#ok<*MCSUP>
				me.baseColour = (me.colour(1:3) + me.colour2(1:3))/2;
			end
			me.isInSetColour = false;
		end

		% ===================================================================
		%> @brief alpha set method
		%>
		% ===================================================================
		function set.alpha(me,value)
			if me.isSetup; warning('You should set alphaOut to affect drawing...'); end
			if value<0; value=0;elseif value>1; value=1; end
			me.alpha = value;
			if ~me.isInSetColour
				me.colour = me.colour(1:3); %force colour to be regenerated
				if isProperty(me,'colour2')
					me.colour2 = me.colour2(1:3);
				end
				if isProperty(me,'baseColour')
					me.baseColour = me.baseColour(1:3);
				end
			end
		end

		% ===================================================================
		%> @brief delta Get method
		%> delta is the normalised number of pixels per frame to move a stimulus
		% ===================================================================
		function value = get.delta(me)
			if isProperty(me,'speedOut')
				value = (me.dp.speedOut * me.ppd) * me.screenVals.ifi;
			else
				value = (me.speed * me.ppd) * me.screenVals.ifi;
			end
		end

		% ===================================================================
		%> @brief dX Get method
		%> X position increment for a given delta and angle
		% ===================================================================
		function value = get.dX(me)
			value = 0;
			if isProperty(me,'directionOut')
				[value,~]=me.updatePosition(me.delta, me.dp.directionOut);
			elseif isProperty(me,'angleOut')
				[value,~]=me.updatePosition(me.delta, me.dp.angleOut);
			end
		end

		% ===================================================================
		%> @brief dY Get method
		%> Y position increment for a given delta and angle
		% ===================================================================
		function value = get.dY(me)
			value = 0;
			if isProperty(me,'directionOut')
				[~,value]=me.updatePosition(me.delta,me.dp.directionOut);
			elseif isProperty(me, 'angleOut')
				[~,value]=me.updatePosition(me.delta,me.dp.angleOut);
			end
		end

		% ===================================================================
		%> @brief Method to set isVisible=true.
		%>
		% ===================================================================
		function show(me)
			me.isVisible = true;
		end

		% ===================================================================
		%> @brief Method to set isVisible=false.
		%>
		% ===================================================================
		function hide(me)
			me.isVisible = false;
		end

		% ===================================================================
		%> @brief reset the various tick counters for our stimulus
		%>
		% ===================================================================
		function resetTicks(me)
			global mouseTick mouseGlobalX mouseGlobalY mouseValid %#ok<*GVMIS> %shared across all stimuli
			if max(me.delayTime) > 0 %delay display a number of frames 
				if length(me.delayTime) == 1
					me.delayTicks = round(me.delayTime/me.screenVals.ifi);
				elseif length(me.delayTime) == 2
					time = randi([me.delayTime(1)*1000 me.delayTime(2)*1000])/1000;
					me.delayTicks = round(time/me.screenVals.ifi);
				end
			else
				me.delayTicks = 0;
			end
			if min(me.offTime) < Inf %delay display a number of frames
				if length(me.offTime) == 1
					me.offTicks = round(me.offTime/me.screenVals.ifi);
				elseif length(me.offTime) == 2
					time = randi([me.offTime(1)*1000 me.offTime(2)*1000])/1000;
					me.offTicks = round(time/me.screenVals.ifi);
				end
			else
				me.offTicks = Inf;
			end
			mouseTick = 0; mouseGlobalX = 0; mouseGlobalY = 0; mouseValid = false;
			me.mouseX = 0; me.mouseY = 0;
			me.tick = 0;
			me.drawTick = 0;
		end

		% ===================================================================
		%> @brief get mouse position
		%> we make sure this is only called once per animation tick to
		%> improve performance and ensure all stimuli that are following
		%> mouse position have consistent X and Y per frame update
		%> This sets mouseX and mouseY and mouseValid if mouse is within
		%> PTB screen (useful for mouse override positioning for stimuli)
		% ===================================================================
		function getMousePosition(me)
			global mouseTick mouseGlobalX mouseGlobalY mouseValid
			if me.tick > mouseTick
				if ~isempty(me.sM) && isa(me.sM,'screenManager') && me.sM.isOpen
					[me.mouseX,me.mouseY] = GetMouse(me.sM.win);
					if me.mouseX > -1 && me.mouseY > -1
						me.mouseValid = true;
					else
						me.mouseValid = false;
					end
				else
					[me.mouseX,me.mouseY] = GetMouse;
				end
				mouseTick = me.tick; %set global so no other object with same tick number can call this again
				mouseValid = me.mouseValid;
				mouseGlobalX = me.mouseX; mouseGlobalY = me.mouseY;
			else
				if ~isempty(mouseGlobalX) && ~isempty(mouseGlobalY)
					me.mouseX = mouseGlobalX; me.mouseY = mouseGlobalY;
					me.mouseValid = mouseValid;
				end
			end
		end

		% ===================================================================
		%> @brief Run Stimulus in a window to preview
		%>
		% ===================================================================
		function run(me, benchmark, runtime, s, forceScreen, showVBL)
		% run(benchmark, runtime, s, forceScreen, showVBL)
			try
				warning off
				if ~exist('benchmark','var') || isempty(benchmark)
					benchmark=false;
				end
				if ~exist('runtime','var') || isempty(runtime)
					runtime = 2; %seconds to run
				end
				if ~exist('s','var') || ~isa(s,'screenManager')
					if isempty(me.sM); me.sM=screenManager; end
					s = me.sM;
					s.blend = true;
					s.disableSyncTests = true;
					s.visualDebug = true;
					s.bitDepth = '8bit';
				end
				if ~exist('forceScreen','var') || isempty(forceScreen); forceScreen = -1; end
				if ~exist('showVBL','var') || isempty(showVBL); showVBL = false; end

				oldscreen = s.screen;
				oldbitdepth = s.bitDepth;
				oldwindowed = s.windowed;
				if forceScreen >= 0
					s.screen = forceScreen;
					if forceScreen == 0
						s.bitDepth = '8bit';
					end
				end
				prepareScreen(s);

				if benchmark
					s.windowed = false;
				elseif forceScreen > -1
					if ~isempty(s.windowed) && (length(s.windowed) == 2 || length(s.windowed) == 4)
						% use existing setting
					else
						s.windowed = [0 0 s.screenVals.screenWidth/2 s.screenVals.screenHeight/2]; %half of screen
					end
				end

				if ~s.isOpen
					sv=open(s); 
				end
				sv = s.screenVals;
				setup(me,s); %setup our stimulus object

				Priority(MaxPriority(s.win)); %bump our priority to maximum allowed

				if benchmark
					drawText(s, 'BENCHMARK: screen won''t update properly, see FPS in command window at end.');
				else
					drawGrid(s); %draw degree dot grid
					drawScreenCenter(s);
					drawText(s, ['Preview ALL with grid = ±1°; static for 1 seconds, then animate for ' num2str(runtime) ' seconds...'])
				end
				if ~any(strcmpi(me.family,{'movie','revcor'})); draw(me); resetTicks(me); end
				if ismethod(me,'resetLog'); resetLog(me); end
				flip(s);
				if ~any(strcmpi(me.family,{'movie','revcor'})); update(me); end
				if benchmark
					WaitSecs('YieldSecs',0.25);
				else
					WaitSecs('YieldSecs',2);
				end
				if runtime < sv.ifi; runtime = sv.ifi; end
				nFrames = 0;
				notFinished = true;
				benchmarkFrames = floor(sv.fps * runtime);
				vbl = zeros(benchmarkFrames+1,1);
				startT = GetSecs; lastvbl = startT;
				while notFinished
					nFrames = nFrames + 1;
					draw(me); %draw stimulus
					if ~benchmark && s.debug; drawGrid(s); end
					finishDrawing(s); %tell PTB/GPU to draw
 					animate(me); %animate stimulus, will be seen on next draw
					if benchmark
						Screen('Flip',s.win,0,2,2);
						notFinished = nFrames < benchmarkFrames;
					else
						vbl(nFrames) = flip(s, lastvbl + sv.halfisi); %flip the buffer
						lastvbl = vbl(nFrames);
						% the calculation needs to take into account the
						% first and last frame times, so we subtract ifi*2
						notFinished = lastvbl < ( vbl(1) + ( runtime - (sv.ifi * 2) ) );
					end
				end
				endT = flip(s);
				if ~benchmark;startT = vbl(1);end
				diffT = endT - startT;
				WaitSecs(0.5);
				vbl = vbl(1:nFrames);
				if showVBL && ~benchmark
					figure;
					plot(diff(vbl)*1e3,'k*');
					line([0 length(vbl)-1],[sv.ifi*1e3 sv.ifi*1e3],'Color',[0 0 0]);
					title(sprintf('VBL Times, should be ~%.4f ms',sv.ifi*1e3));
					ylabel('Time (ms)')
					xlabel('Frame #')
				end
				Priority(0); ShowCursor; ListenChar(0);
				reset(me); %reset our stimulus ready for use again
				close(s); %close screen
				s.screen = oldscreen;
				s.windowed = oldwindowed;
				s.bitDepth = oldbitdepth;
				fps = nFrames / diffT;
				fprintf('\n\n======>>> Stimulus: %s\n',me.fullName);
				fprintf('======>>> <strong>SPEED</strong> (%i frames in %.3f secs) = <strong>%g</strong> fps\n\n',nFrames, diffT, fps);
				if ~benchmark;fprintf('\b======>>> First - Last frame time: %.3f\n\n',vbl(end)-startT);end
				clear s fps benchmark runtime b bb i vbl; %clear up a bit
				warning on
			catch ME
				warning on
				try Priority(0); end
				if exist('s','var') && isa(s,'screenManager')
					try close(s); end
				end
				clear fps benchmark runtime b bb i; %clear up a bit
				reset(me); %reset our stimulus ready for use again
				rethrow(ME)
			end
		end

		% ===================================================================
		%> @brief gets a propery copy or original property
		%>
		%> When stimuli are run, their properties are copied, so e.g. angle
		%> is copied to angleOut and this is used during the task. This
		%> method checks if the copy is available and returns that, otherwise
		%> return the original.
		%>
		%> @param name of property
		%> @param range of property to return
		%> @return value of property
		% ===================================================================
		function [value, name] = getP(me, name, range)
			value = [];
			if isProperty(me, name)
				if isProperty(me, [name 'Out'])
					name = [name 'Out'];
					try value = me.dp.(name); end
				else
					try value = me.(name); end
				end
				if exist('range','var'); value = value(range); end
			else
				warning('Property %s doesn''t exist!!!',name)
				value = [];
			end
		end

		% ===================================================================
		%> @brief gets a propery copy or original property
		%>
		%> When stimuli are run, their properties are copied, so e.g. angle
		%> is copied to angleOut and this is used during the task. This
		%> method checks if the copy is available and returns that, otherwise
		%> return the original.
		%>
		%> @param name of property
		%> @param range of property to return
		%> @return value of property
		% ===================================================================
		function setP(me, name, value)
			if isProperty(me, name)
				if isProperty(me,[name 'Out'])
					name = [name 'Out'];
					try me.dp.(name) = value; end
				else
					try me.(name) = value; end
				end
			else
				warning('Property %s doesn''t exist!!!',name)
			end
		end
		
	end %---END PUBLIC METHODS---%

	%=======================================================================
	methods ( Static ) %----------STATIC METHODS
	%=======================================================================

		% ===================================================================
		%> @brief degrees2radians
		%>
		% ===================================================================
		function r = d2r(degrees)
		% d2r(degrees)
			r=degrees*(pi/180);
		end

		% ===================================================================
		%> @brief radians2degrees
		%>
		% ===================================================================
		function degrees = r2d(r)
		% r2d(radians)
			degrees=r*(180/pi);
		end

		% ===================================================================
		%> @brief findDistance in X and Y coordinates
		%>
		% ===================================================================
		function distance = findDistance(x1, y1, x2, y2)
		% findDistance(x1, y1, x2, y2)
			distance=sqrt((x2 - x1)^2 + (y2 - y1)^2);
		end

		% ===================================================================
		%> @brief updatePosition returns dX and dY given an angle and delta
		%>
		% ===================================================================
		function [dX, dY] = updatePosition(delta,angle)
		% updatePosition(delta, angle)
			dX = delta .* cos(baseStimulus.d2r(angle));
			if abs(dX) < 1e-3; dX = 0; end
			dY = delta .* sin(baseStimulus.d2r(angle));
			if abs(dY) < 1e-3; dY = 0; end
		end

	end%---END STATIC METHODS---%

	%=======================================================================
	methods ( Access = protected ) %-------PRIVATE (protected) METHODS-----%
	%=======================================================================

		% ===================================================================
		%> @brief addRuntimeProperties
		%> these are transient properties that specify actions during runtime
		% ===================================================================
		function addRuntimeProperties(me)
			updateRuntimeProperties(me);
		end

    % ===================================================================
		%> @brief doProperties
		%> these are transient properties that specify actions during runtime
		% ===================================================================
		function updateRuntimeProperties(me)
			me.doDots		  = false;
			me.doMotion		= false;
			me.doDrift		= false;
			me.doFlash		= false;
			me.doAnimator	= false;

			if isProperty(me, 'tf') && me.tf > 0; me.doDrift = true; end
			if me.speed > 0; me.doMotion = true; end
			if strcmpi(me.family,'dots'); me.doDots = true; end
			if strcmpi(me.type,'flash'); me.doFlash = true; end
			if ~isempty(me.animator) && isa(me.animator,'animationManager')
				me.doAnimator = true;
			end
		end

		% ===================================================================
		%> @brief setRect
		%> setRect makes the PsychRect based on the texture and screen
		%> values, you should call computePosition() first to get xFinal and
		%> yFinal.
		% ===================================================================
		function setRect(me)
			if ~isempty(me.texture)
				me.dstRect=Screen('Rect',me.texture);
				if me.mouseOverride && me.mouseValid
					me.dstRect = CenterRectOnPointd(me.dstRect, me.mouseX, me.mouseY);
				else
					me.dstRect=CenterRectOnPointd(me.dstRect, me.xFinal, me.yFinal);
				end
				me.mvRect=me.dstRect;
			end
		end

		% ===================================================================
		%> @brief setAnimationDelta
		%> setAnimationDelta for performance better not to use get methods for dX dY and
		%> delta during animation, so we have to cache these properties to private copies so that
		%> when we call the animate method, it uses the cached versions not the
		%> public versions. This method simply copies the properties to their cached
		%> equivalents.
		% ===================================================================
		function setAnimationDelta(me)
			me.delta_ = me.delta;
			me.dX_ = me.dX;
			me.dY_ = me.dY;
		end

		% ===================================================================
		%> @brief compute xFinal and yFinal
		%>
		% ===================================================================
		function computePosition(me)
			if me.mouseOverride && me.mouseValid
				me.xFinal = me.mouseX; me.yFinal = me.mouseY;
			else
				if me.isSetup
					[dx, dy]=pol2cart(me.d2r(me.dp.angleOut),me.dp.startPositionOut);
					me.xFinal = me.dp.xPositionOut + (dx * me.ppd) + me.sM.xCenter;
					me.yFinal = me.dp.yPositionOut + (dy * me.ppd) + me.sM.yCenter;
				else
					[dx, dy]=pol2cart(me.d2r(me.angle),me.startPosition);
					me.xFinal = me.xPosition*me.ppd + (dx * me.ppd) + me.sM.xCenter;
					me.yFinal = me.yPosition*me.ppd + (dy * me.ppd) + me.sM.yCenter;
				end
				if me.verbose; fprintf('---> computePosition: %s X = %gpx / %gpx / %gdeg | Y = %gpx / %gpx / %gdeg\n',me.fullName, me.xFinal, me.dp.xPositionOut, dx, me.yFinal, me.dp.yPositionOut, dy); end
			end
			setAnimationDelta(me);
		end

		% ===================================================================
		%> @brief Converts properties to a structure
		%>
		%>
		%> @param me this instance object
		%> @param tmp is whether to use the temporary or permanent properties
		%> @return out the structure
		% ===================================================================
		function out=toStructure(me,tmp)
			if ~exist('tmp','var')
				tmp = 0; %copy real properties, not temporary ones
			end
			fn = fieldnames(me);
			for j=1:length(fn)
				if tmp == 0
					out.(fn{j}) = me.(fn{j});
				else
					out.(fn{j}) = me.([fn{j} 'Out']);
				end
			end
		end

		% ===================================================================
		%> @brief Finds and removes dynamic properties
		%>
		%> @param me
		%> @return
		% ===================================================================
		function removeTmpProperties(me)
			if isProperty(me,'dp')
				me.dp = [];
				me.fndp = [];
			end
		end

	end%---END PRIVATE METHODS---%
end
