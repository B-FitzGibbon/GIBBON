function [domNode]=addContactLevel_FEB(domNode,FEB_struct)

% function [domNode]=addContactLevel_FEB(domNode,FEB_struct)
% ------------------------------------------------------------------------
% Adds contact information to the XML object domNode based on
% the FEBio structure FEB_struct. 
% 
% Sticky and sliding contact formulations are supported
%
% Kevin Mattheus Moerman
% gibbon.toolbox@gmail.com
% 
% 2016/06/02
%------------------------------------------------------------------------

disp('Adding Contact field')
rootNode = domNode.getDocumentElement;

contactNode = domNode.createElement('Contact');
contactNode = rootNode.appendChild(contactNode);
    

%% Adding contact components
[domNode]=addContactComponents_FEB(domNode,contactNode,FEB_struct);

 
%% 
% _*GIBBON footer text*_ 
% 
% License: <https://github.com/gibbonCode/GIBBON/blob/master/LICENSE>
% 
% GIBBON: The Geometry and Image-based Bioengineering add-On. A toolbox for
% image segmentation, image-based modeling, meshing, and finite element
% analysis.
% 
% Copyright (C) 2017  Kevin Mattheus Moerman
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
