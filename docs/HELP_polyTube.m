%% polyTube
% Below is a basic demonstration of the features of the |polyTube| function.

%%
clear; close all; clc;

% PLOT SETTINGS
fig_color='w'; fig_colordef='white';
markerSize=15;
lineWidth=2;
fontSize=10; 

%% 
% Creating example curve
ns=150;
t=linspace(0,-pi,ns);
r=10+7.*sin(8*t);
[x,y] = pol2cart(t,r);
z=7*cos(10.*t);
V=[x(:) y(:) z(:)];

%% BUIDLING THE TUBE

optStruct.r=0.25;
optStruct.nr=12;
optStruct.patchType='tri';
[Fs,Vs,Cs,Cs_rgb,Cs_d]=polyTube(V,optStruct);

%%

cFigure; hold on;
title('A curve tube with color representing curve distance','fontSize',fontSize);
gpatch(Fs,Vs,Cs_d,'none');
camlight headlight; lighting gouraud; 
colormap gjet; 
axisGeom; 
drawnow; 

cFigure; hold on;
title('A curve tube with color representing direction','fontSize',fontSize);
gpatch(Fs,Vs,Cs_rgb,'none');
camlight headlight; lighting gouraud; 
colormap gjet; 
axisGeom; 
drawnow; 

%% 
%
% <<gibbVerySmall.gif>>
% 
% _*GIBBON*_ 
% <www.gibboncode.org>
% 
% _Kevin Mattheus Moerman_, <gibbon.toolbox@gmail.com>
 
%% 
% _*GIBBON footer text*_ 
% 
% License: <https://github.com/gibbonCode/GIBBON/blob/master/LICENSE>
% 
% GIBBON: The Geometry and Image-based Bioengineering add-On. A toolbox for
% image segmentation, image-based modeling, meshing, and finite element
% analysis.
% 
% Copyright (C) 2018  Kevin Mattheus Moerman
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
