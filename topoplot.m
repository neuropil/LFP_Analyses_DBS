% topoplot() - plot a topographic map of an EEG field as a 2-D
%              circular view (looking down at the top of the head) 
%              using cointerpolation on a fine cartesian grid.
% Usage:
%        >>  topoplot(datavector, chan_locs);
%        >>  topoplot(datavector, chan_locs, 'Param1','Value1', ...)
%
% Inputs:
%    		datavector - vector of values at the corresponding locations.
%   		chan_locs  - name of an EEG electrode position file (See
%                             >> topoplot example   for format.
% Optional Parameters:
%                'colormap'         -  any sized colormap
%                'interplimits'     - 'electrodes' to furthest electrode
%                                     'head' to edge of head
%                                        {default 'head'}
%                'gridscale'        -  scaling grid size {default 67}
%                'maplimits'        - 'absmax' +/- the absolute-max 
%                                     'maxmin' scale to data range
%                                     [clim1,clim2] user-definined lo/hi
%                                        {default = 'absmax'}
%                'style'            - 'straight' colormap only
%                                     'contour' contour lines only
%                                     'both' - both colormap and contour lines
%                                     'fill' - constant color between lines
%                                     'blank' - just plot electrode locations
%                                     {default = 'both'}
%                'numcontour'       - number of contour lines
%                                        {default = 6}
%                'shading'          - 'flat','interp'  {default = 'flat'}
%                'headcolor'        - Color of head cartoon {default black}
%                'electrodes'       - 'on','off','labels','numbers', 
%                                     'labelpoint', 'numpoint'
%                'efontsize'        - detail
%                'electcolor'       - detail
%                'emarker'          - detail
%                'emarkersize'      - detail
%  
% Eloc_file format:
%    chan_number degrees radius reject_level amp_gain channel_name
%    (Angle-0 =Cz-to-Fz; C3-angle =-90; Radius at edge of image = 0.5)
%    For a sample eloc file: >> topoplot example
%
% Note: 1) topoplot only works when map limits are >= the max and min 
%                                     interpolated data values.
%       2) topoplot will ignore any electrode with a position outside 
%       the head (radius > 0.5). To make the head round, >> axis square
%
% Authors: Andy Spydell & Colin Humphries, CNL / Salk Institute, Aug, 1996
%
% See also: timtopo(), envtopo()

% Copyright (C) Colin Humphries & Scott Makeig, CNL / Salk Institute, Aug, 1996
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: topoplot.m,v $
% Revision 1.1  2002/04/05 17:36:45  jorn
% Initial revision
%

% Topoplot Version 2.1

% Begun by Andy Spydell and Scott Makeig, NHRC,  7-23-96
% 8-96 Revised by Colin Humphries, CNL / Salk Institute, La Jolla CA
%   -changed surf command to imagesc (faster)
%   -can now handle arbitrary scaling of electrode distances
%   -can now handle non integer angles in chan_locs
% 4-4-97 Revised again by Colin Humphries, reformat by SM
%   -added parameters
%   -changed chan_locs format
% 2-26-98 Revised by Colin
%   -changed image back to surface command
%   -added fill and blank styles
%   -removed extra background colormap entry (now use any colormap)
%   -added parameters for electrode colors and labels
%   -now each topoplot axes use the caxis command again.
%   -removed OUTPUT parameter
% 3-11-98 changed default emarkersize, improve help msg -sm
% 5-24-01 made default emarkersize vary with number of channels -sm
% 01-25-02 reformated help & license, added link -ad 
% 03-15-02 added readlocs and the use of eloc input structure -ad 
% 03-25-02 added 'labelpoint' options and allow Vl=[] -ad &sm

% 03-25-02 added details to "Unknown parameter" warning -sm & ad
function handle = topoplot(Vl,loc_file,p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7,p8,v8,p9,v9)

% User Defined Defaults:
icadefs % read defaults:  MAXTOPOPLOTCHANS, DEFAULT_ELOC
INTERPLIMITS = 'head';  % head, electrodes
MAPLIMITS = 'absmax';   % absmax, maxmin, [values]
GRID_SCALE = 67;
CONTOURNUM = 6;
STYLE = 'both';       % both,straight,fill,contour,blank
HCOLOR = [0 0 0];
ECOLOR = [0 0 0];
CONTCOLOR = [0 0 0];
ELECTROD = 'on';      % ON OFF LABEL
EMARKER = '.';
EMARKERSIZE = [];     % DEFAULTS SET IN CODE 
EFSIZE = get(0,'DefaultAxesFontSize');
HLINEWIDTH = 2;
SHADING = 'flat';     % flat or interp

%%%%%%%%%%%%%%%%%%%%%%%
if nargin< 1
   help topoplot;
   return
end

nargs = nargin;
if nargs < 2
  loc_file = DEFAULT_ELOC;
end
if nargs == 1
  if isstr(Vl)
    if any(strcmp(lower(Vl),{'example','demo'}))
      fprintf(['This is an example of an electrode location file,\n',...
               'an ascii file consisting of the following four columns:\n',...
               ' channel_number degrees arc_length channel_name\n\n',...
               'Example:\n',...
               ' 1               -18    .352       Fp1.\n',...
               ' 2                18    .352       Fp2.\n',...
               ' 5               -90    .181       C3..\n',...
               ' 6                90    .181       C4..\n',...
               ' 7               -90    .500       A1..\n',...
               ' 8                90    .500       A2..\n',...
               ' 9              -142    .231       P3..\n',...
               '10               142    .231       P4..\n',...
               '11                 0    .181       Fz..\n',...
               '12                 0    0          Cz..\n',...
               '13               180    .181       Pz..\n\n',...
               'The model head sphere has a diameter of 1.\n',...
               'The vertex (Cz) has arc length 0. Channels with arc \n',...
               'lengths > 0.5 are not plotted nor used for interpolation.\n'...
               'Zero degrees is towards the nasion. Positive angles\n',...
               'point to the right hemisphere; negative to the left.\n',...
               'Channel names should each be four chars, padded with\n',...
               'periods (in place of spaces).\n'])
      return

    end
  end
end
if isempty(loc_file)
  loc_file = 0;
end
if isnumeric(loc_file) & loc_file == 0
  loc_file = DEFAULT_ELOC;
end

if nargs > 2
  if ~(round(nargs/2) == nargs/2)
    error('topoplot(): Odd number of inputs?')
  end
  for i = 3:2:nargs
    Param = eval(['p',int2str((i-3)/2 +1)]);
    Value = eval(['v',int2str((i-3)/2 +1)]);
    if ~isstr(Param)
      error('topoplot(): Parameter must be a string')
    end
    Param = lower(Param);
    switch lower(Param)
      case 'colormap'
        if size(Value,2)~=3
          error('topoplot(): Colormap must be a n x 3 matrix')
        end
        colormap(Value)
      case {'interplimits','headlimits'}
        if ~isstr(Value)
          error('topoplot(): interplimits value must be a string')
        end
        Value = lower(Value);
        if ~strcmp(Value,'electrodes') & ~strcmp(Value,'head')
          error('topoplot(): Incorrect value for interplimits')
        end
        INTERPLIMITS = Value;
      case 'maplimits'
        MAPLIMITS = Value;
      case 'gridscale'
        GRID_SCALE = Value;
      case 'style'
	STYLE = lower(Value);
      case 'numcontour'
        CONTOURNUM = Value;
      case 'electrodes'
	ELECTROD = lower(Value);
      case 'emarker'
	EMARKER = Value;
      case {'headcolor','hcolor'}
	HCOLOR = Value;
      case {'electcolor','ecolor'}
	ECOLOR = Value;
      case {'emarkersize','emsize'}
	EMARKERSIZE = Value;
      case {'efontsize','efsize'}
	EFSIZE = Value;
      case 'shading'
	SHADING = lower(Value);
	if ~any(strcmp(SHADING,{'flat','interp'}))
	  error('Invalid Shading Parameter')
	end
      otherwise
	error(['topoplot(): Unknown input parameter ''' Param ''' ???'])
    end
  end
end

[r,c] = size(Vl);
if r>1 & c>1,
  error('topoplot(): data should be a single vector\n');
end

%fid = fopen(loc_file);
%if fid<1,
%  fprintf('topoplot(): cannot open chan_locs file (%s).\n',loc_file);
%  return
%end
%A = fscanf(fid,'%d %f %f %s',[7 MAXTOPOPLOTCHANS]);
%fclose(fid);

%A = A';
%labels = setstr(A(:,4:7));
%idx = find(labels == '.');                       % some labels have dots
%labels(idx) = setstr(abs(' ')*ones(size(idx)));  % replace them with spaces

%Th = pi/180*A(:,2);                              % convert degrees to radians
%Rd = A(:,3);

% read the channel location file
% ------------------------------
[tmpeloc labels Th Rd] = readlocs(loc_file);
labels = strvcat(labels);
Th = pi/180*Th;                              % convert degrees to radians
    
if length(Vl) ~= length(Th),
 fprintf(...
   'topoplot(): data vector length (%d) must be the same as chan_locs file rows (%d)\n',...
               length(Vl),length(Th));
end

ii = find(Rd <= 0.5);                     % interpolate on-head channels only
Th = Th(ii);
Rd = Rd(ii);
if ~strcmp(STYLE,'blank')
    Vl = Vl(ii);
end;
labels = labels(ii,:);

[x,y] = pol2cart(Th,Rd);      % transform from polar to cartesian coordinates
rmax = 0.5;

ha = gca;
cla
hold on

if ~strcmp(STYLE,'blank')
  % find limits for interpolation
  if strcmp(INTERPLIMITS,'head')
    xmin = min(-.5,min(x)); xmax = max(0.5,max(x));
    ymin = min(-.5,min(y)); ymax = max(0.5,max(y));
  else
    xmin = max(-.5,min(x)); xmax = min(0.5,max(x));
    ymin = max(-.5,min(y)); ymax = min(0.5,max(y));
  end
  
  xi = linspace(xmin,xmax,GRID_SCALE);   % x-axis description (row vector)
  yi = linspace(ymin,ymax,GRID_SCALE);   % y-axis description (row vector)
  
  [Xi,Yi,Zi] = griddata(y,x,Vl,yi',xi,'invdist'); % Interpolate data
  
  % Take data within head
  mask = (sqrt(Xi.^2+Yi.^2) <= rmax);
  ii = find(mask == 0);
  Zi(ii) = NaN;
  
  % calculate colormap limits
  m = size(colormap,1);
  if isstr(MAPLIMITS)
    if strcmp(MAPLIMITS,'absmax')
      amin = -max(max(abs(Zi)));
      amax = max(max(abs(Zi)));
    elseif strcmp(MAPLIMITS,'maxmin') | strcmp(MAPLIMITS,'minmax')
      amin = min(min(Zi));
      amax = max(max(Zi));
    end
  else
    amin = MAPLIMITS(1);
    amax = MAPLIMITS(2);
  end
  delta = xi(2)-xi(1); % length of grid entry
  
  % Draw topoplot on head
  if strcmp(STYLE,'contour')
    contour(Xi,Yi,Zi,CONTOURNUM,'k');
  elseif strcmp(STYLE,'both')
    surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none',...
	'FaceColor',SHADING);
    contour(Xi,Yi,Zi,CONTOURNUM,'k');
  elseif strcmp(STYLE,'straight')
    surface(Xi-delta/2,Yi-delta/2,zeros(size(Zi)),Zi,'EdgeColor','none',...
	'FaceColor',SHADING);
  elseif strcmp(STYLE,'fill')
    contourf(Xi,Yi,Zi,CONTOURNUM,'k');
  else
    error('Invalid style')
  end
  caxis([amin amax]) % set coloraxis

else % style 'blank'

    text(-0.6,-0.6, ...
    [ int2str(length(Rd)) ' of ' int2str(length(tmpeloc)) ' electrode locations shown']);
    text(-0.6,-0.65, ...
    [ 'Click on electrodes to toggle name/number']);
    a = textsc('Channel locations', 'title');
    set(a, 'fontweight', 'bold');
end

set(ha,'Xlim',[-rmax*1.3 rmax*1.3],'Ylim',[-rmax*1.3 rmax*1.3])

% %%% Draw Head %%%%
l = 0:2*pi/100:2*pi;
basex = .18*rmax;  
tip = rmax*1.15; base = rmax-.004;
EarX = [.497 .510 .518 .5299 .5419 .54 .547 .532 .510 .489];
EarY = [.0555 .0775 .0783 .0746 .0555 -.0055 -.0932 -.1313 -.1384 -.1199];

% Plot Electrodes
if strcmp(ELECTROD,'on') 
  if isempty(EMARKERSIZE)
   EMARKERSIZE = 10;
   if length(y)>=32 
    EMARKERSIZE = 8;
   elseif length(y)>=64
    EMARKERSIZE = 6;
   elseif length(y)>=100
    EMARKERSIZE = 3;
   elseif length(y)>=200
    EMARKERSIZE = 1;
   end
  end
  hp2 = plot(y,x,EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE);
elseif strcmp(ELECTROD,'labels')
  for i = 1:size(labels,1)
    text(y(i),x(i),labels(i,:),'HorizontalAlignment','center',...
	'VerticalAlignment','middle','Color',ECOLOR,...
	'FontSize',EFSIZE)
  end
elseif strcmp(ELECTROD,'labelpoint')
 if isempty(EMARKERSIZE)
   EMARKERSIZE = 10;
   if length(y)>=32 
    EMARKERSIZE = 8;
   elseif length(y)>=64
    EMARKERSIZE = 6;
   elseif length(y)>=100
    EMARKERSIZE = 3;
   elseif length(y)>=200
    EMARKERSIZE = 1;
   end
  end
  hp2 = plot(y,x,EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE);
  for i = 1:size(labels,1)
    hh(i) = text(y(i)+0.01,x(i),labels(i,:),'HorizontalAlignment','left',...
	'VerticalAlignment','middle','Color', ECOLOR,'userdata', num2str(i), ...
	'FontSize',EFSIZE, 'buttondownfcn', ...
	    ['tmpstr = get(gco, ''userdata'');'...
	     'set(gco, ''userdata'', get(gco, ''string''));' ...
	     'set(gco, ''string'', tmpstr); clear tmpstr;'] );
  end
elseif strcmp(ELECTROD,'numpoint')
 if isempty(EMARKERSIZE)
   EMARKERSIZE = 10;
   if length(y)>=32 
    EMARKERSIZE = 8;
   elseif length(y)>=64
    EMARKERSIZE = 6;
   elseif length(y)>=100
    EMARKERSIZE = 3;
   elseif length(y)>=200
    EMARKERSIZE = 1;
   end
  end
  hp2 = plot(y,x,EMARKER,'Color',ECOLOR,'markersize',EMARKERSIZE);
  for i = 1:size(labels,1)
    hh(i) = text(y(i)+0.01,x(i),num2str(i),'HorizontalAlignment','left',...
	'VerticalAlignment','middle','Color', ECOLOR,'userdata', labels(i,:) , ...
	'FontSize',EFSIZE, 'buttondownfcn', ...
	    ['tmpstr = get(gco, ''userdata'');'...
	     'set(gco, ''userdata'', get(gco, ''string''));' ...
	     'set(gco, ''string'', tmpstr); clear tmpstr;'] );
  end
elseif strcmp(ELECTROD,'numbers')
  for i = 1:size(labels,1)
    text(y(i),x(i),int2str(i),'HorizontalAlignment','center',...
	'VerticalAlignment','middle','Color',ECOLOR,...
	'FontSize',EFSIZE)
  end
end

% Plot Head, Ears, Nose
plot(cos(l).*rmax,sin(l).*rmax,...
    'color',HCOLOR,'Linestyle','-','LineWidth',HLINEWIDTH);

plot([.18*rmax;0;-.18*rmax],[base;tip;base],...
    'Color',HCOLOR,'LineWidth',HLINEWIDTH);
   
plot(EarX,EarY,'color',HCOLOR,'LineWidth',HLINEWIDTH)
plot(-EarX,EarY,'color',HCOLOR,'LineWidth',HLINEWIDTH)   

hold off
axis off

