function playMovies(folder)
	
	subjectName = '13';
	rewardPort = '/dev/ttyACM0';
	debug = true;
	if debug
		if max(Screen('Screens'))==0; windowed = [0 0 1400 800]; end
		sf = kPsychGUIWindow;
		dummy = true;
		colour1 = [1 0.5 0 0.75];
		colour2 = [0 1 1 0.75];
	else
		windowed = []; sf = [];
		dummy = false;
		colour1 = [1 0.5 0 0.75];
		colour2 = [1 0.5 0 0.75];
	end
	
	if IsOctave; try pkg load instrument-control; end; end
	
	% ============================movie / position list
	movieList = {'~/Videos/testcage/ball3-0120.mkv','~/Videos/testcage/ball2-0120.mkv',...
	'~/Videos/testcage/ball-0120.mkv','~/Videos/testcage/throw-0120.mkv','~/Videos/testcage/throw2-0120.mkv',...
	'~/Videos/testcage/throw3-0120.mkv'};
	positionList ={...
		[-20 -14 -13 -3 -20 4 -13 15.2],...
		[-20 -14 -13 -3 -20 4 -13 15.2],...
		[-20 -14 -13 -3 -20 4 -13 15.2],...
		[-19 0.5 -12.5 5 -19 6.3 -12.5 10.7],...
		[-19 1.2 -12.3 5.5 -19.5 7.2 -13 11.5],...
		[-19.5 -1 -12.5 3.5 -19.5 7 -13 12]};
	%movieList = {'~/Code/octicka/tests/ball.mkv','~/Code/octicka/tests/ball.mkv'};
	%positionList = {-5, 5};
	for i = 1 : length(movieList)
		movieList{i} = regexprep(movieList{i}, '^~\/', [getenv('HOME') filesep]);
	end
	
	try
		% ============================screen
		s = screenManager('blend',true,'pixelsPerCm',36,'windowed',windowed,'specialFlags',sf);
		
		% s============================stimuli
		rn = 1;
		m = movieStimulus('fileName',movieList{rn},'angle',90);
		c1 = discStimulus('size',5);
		c2 = discStimulus('xPosition',-5,'yPosition',positionList{rn},'size',5,'colour',colour1);
		c3 = discStimulus('xPosition',-5,'yPosition',-positionList{rn},'size',5,'colour',colour2);

		% t============================ouch
		t = touchManager('isDummy',dummy);
		t.window.doNegation = true;
		t.negationBuffer = 2;
		
		% ============================reward
		rM = arduinoManager('port',rewardPort,'shield','new','verbose',false);
		try open(rM); end
		
		% ============================setup
		sv = open(s);
		setup(m, s);
		setup(c1, s);
		setup(c2, s);
		setup(c3, s);
		setup(t,s);
		createQueue(t);
		start(t);

		% ============================exclusion zones
		topdeg = s.screenVals.topInDegrees;
		leftdeg = s.screenVals.leftInDegrees;
		bottomdeg = -topdeg; rightdeg = -leftdeg;
		ez1(1,:) = [leftdeg, topdeg, 0 - c1.size, bottomdeg];
		ez1(2,:) = [0 + c1.size, topdeg, rightdeg, bottomdeg];
		ez2(1,:) = [leftdeg, topdeg, 0 + c2.xPosition - c2.size, bottomdeg];
		ez2(2,:) = [0 + c2.xPosition + c2.size, topdeg, rightdeg, bottomdeg];
		ez2(3,:) = [ez2(1,2), topdeg, ez2(2,1), bottomdeg];
		
		% ==============================save file name
		svn = initialiseSaveFile(s);
		saveName = [ s.paths.savedData filesep 'IntPhys-' subjectName '-' svn '.mat'];
		
		% ============================settings
		quitKey = KbName('escape');
		RestrictKeysForKbCheck([quitKey]);
		try ListenChar(0);
		try Priority(1); end
		txt = 'Waiting for touch...';
		keepRunning = true
		trialN = 0;
		presentationTime=m.duration;
		responseTime = 2;
		timeOut = 2;
		trials = struct;
		
		while keepRunning	
			%make our touch window around stimulus c1
			t.window.X = c1.xPosition;
			t.window.Y = c1.yPosition;
			t.window.radius = [c1.size / 2, c1.size / 2];
			%t.window.doNegation = true;
			t.exclusionZone = ez1;
			x = []; y = []; touched = false; touchedResponse = false;
			trialN = trialN + 1;
			trials(trialN).movieName = m.fileName;
			trials(trialN).targetPosition = c2.yPositionOut;
			touchStart = false;
			fprintf('\n===> START TRIAL: %i\n', trialN);
			flush(t);
			
			%=======================================================wait for an initiate touch
			vbl = flip(s); vblInit = vbl;
			while ~touchStart
				draw(c1);
				if debug && ~isempty(x) && ~isempty(y)
					drawText(s, txt);
					[xy] = s.toPixels([x y]);
					Screen('glPoint', s.win, [1 0 0], xy(1), xy(2), 10);
				end
				vbl = flip(s);
				[touched, x, y] = checkTouchWindow(t);
				txt = sprintf('Touch = %i x=%.2f y=%.2f',touched,x,y);
				flush(t);
				if touched == 1
					touchStart = true;
				elseif touched == -100;
					drawBackground(s,[1 0 0]);
					drawTextNow(s,'EXCLUSION!');
					WaitSecs(2);
					drawBackground(s);
					flip(s);
					continue;
				end
				[~,~,c] = KbCheck(-1);
				if c(quitKey); keepRunning=false; break; end
			end
			trials(trialN).initTime = vbl - vblInit;
			flip(s);
			WaitSecs(0.5);
			if keepRunning == false; break; end
			
			%================================================show movie
			vbl = flip(s);
			vblInit = vbl;
			while vbl <= vblInit + presentationTime
				draw(m);
				vbl = flip(s);
			end
			
			trials(trialN).presentationTime = vbl - vblInit;
			
			WaitSecs(0.5);
			flip(s);
			WaitSecs(0.5);
			
			x = s.toDegrees(c2.xFinal,'x');
			y = s.toDegrees(c2.yFinal,'y');
			t.window.X = x;
			t.window.Y = y;
			t.window.radius = [c2.size / 2 + t.negationBuffer, c2.size / 2 + t.negationBuffer];
			t.window.doNegation = false;
			t.exclusionZone = ez2;
			fprintf('===> Choice window: X = %.1f Y = %.1f\n',x,y);
			flush(t);
			x = []; y = []; touchedResponse = false; txt = '';
			
			%=============================================get response
			vbl = flip(s);
			vblInit = vbl;
			while vbl <= vblInit + responseTime
				draw(c2); draw(c3);
				if debug && ~isempty(x) && ~isempty(y)
					drawText(s, txt);
					[xy] = s.toPixels([x y]);
					Screen('glPoint', s.win, [1 0 0], xy(1), xy(2), 10);
				end
				vbl = flip(s);
				[touchedResponse, x, y] = checkTouchWindow(t);
				txt = sprintf('x=%.2f y=%.2f', x, y);
				flush(t);
				if touchedResponse == true || touchedResponse == -100
					break;
				end
			end
			flip(s);
			trials(trialN).responseTime = vbl - vblInit;
			trials(trialN).correct = touchedResponse;
			
			% get a new movie from the list
			rn = randi(length(movieList));
			reset(m);
			m.fileName = movieList{rn};
			setup(m,s);
			presentationTime = m.duration;
			
			% update our response targets
			c2.yPositionOut = positionList{rn};
			c3.yPositionOut = -positionList{rn};
			update(c2); update(c3);
			
			fprintf('===> Choosing Movie %i = %s\n',rn, m.fileName);
			fprintf('===> S:%i c2 Y = %.1f | c3 Y = %.1f\n',rn,c2.yPositionOut,c3.yPositionOut);
			
			% save trial data
			save('-v7', saveName, 'trials')
			
			%===========================================time out
			if touchedResponse == true
				fprintf('===> CORRECT :-)\n');
				drawTextNow(s,'CORRECT!');
				rM.stepper(46);
				WaitSecs(0.25);
			elseif ~touchedResponse || touchedResponse == -100
				drawBackground(s,[1 0 0]);
				if touchedResponse == -100 
					drawTextNow(s,'EXCLUDE!');
					fprintf('===> EXCLUDE :-(\n');
				else
					drawTextNow(s,'TIMEOUT!');
					fprintf('===> INCORRECT :-(\n');
				end
				WaitSecs(2);
				drawBackground(s);
				flip(s);
			end
		end % while keepRunning	

		drawText(s, 'FINISHED!');
		flip(s);
		
		% save trial data
		disp('=======================================');
		fprintf('===> Saving data to %s\n',saveName)
		disp('=======================================');
		save('-v7', saveName, 'trials')
			
		try Listenchar(0); end
		try Priority(0); end
		WaitSecs(0.5);
		try Priority(0); end
		try reset(m); reset(c1); reset(c2); reset(c3); end
		close(s);
		close(t);
		close(rM);
		sca;
		
	catch ME
		try reset(m); reset(c1); reset(c2); reset(c3); end
		try close(s); end
		try close(t); end
		try close(rM); end
		try Priority(0); end
		try ListenChar(0); end
		sca;
		disp(ME);
	end

end