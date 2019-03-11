%% addGeometryLevel_FEB
% Below is a demonstration of the features of the |addGeometryLevel_FEB| function

%%
clear; close all; clc;

%% Syntax
% |[domNode]=addGeometryLevel_FEB(domNode,FEB_struct);|

%% Description
% This function adds the geometry information to the input XML
% data (domNode) based on the input febio structure (FEB_struct).

%% Examples

%% Example: Defining geometry section
% 

%Example data 
F1=[1 2 3]; %A surface
V=rand(8,3); %Nodes (vertices)
E_hex=[1 2 3 4 5 6 7 8]; %hex8 elements
E_tet=[1 2 3 4]; %tet4 elements
E_quad=[1 2 3 4]; %quad4 elements
elementMaterialIndices=[1]; %material indices for the elements
V_fib=[0 0 1]; %Fibre directions for each element
nodeList=[1 5 7]; %List of nodes, e.g. for boundary conditions specification

%Geometry section
FEB_struct.Geometry.Nodes=V;
FEB_struct.Geometry.Elements={E_hex,E_tet,E_quad}; %The element sets
FEB_struct.Geometry.ElementType={'hex8','tet4','quad4'}; %The element types
FEB_struct.Geometry.ElementMat={elementMaterialIndices,elementMaterialIndices,elementMaterialIndices};
FEB_struct.Geometry.ElementsPartName={'Block','tet','surf'};

%Adding fibre direction, construct local orthonormal basis vectors
[a,d]=vectorOrthogonalPair(V_fib);

VF_E=zeros(size(V_fib,1),size(V_fib,2),2);
VF_E(:,:,1)=a; %a1 ~ e1 ~ X or first direction
VF_E(:,:,2)=d; %a2 ~ e2 ~ Y or second direction
%Vf_E %a3 ~ e3 ~ Z, third direction, or fibre direction

%ElementData
FEB_struct.Geometry.ElementData.MatAxis.ElementIndices=1:1:size(E_hex,1);
FEB_struct.Geometry.ElementData.MatAxis.Basis=VF_E;

%Defining node sets
FEB_struct.Geometry.NodeSet{1}.Set=nodeList;

%Defining surfaces
FEB_struct.Geometry.Surface{1}.Set=F1;
FEB_struct.Geometry.Surface{1}.Type='tri3';
FEB_struct.Geometry.Surface{1}.Name='Contact_master_indentor';


%Initialize docNode object
domNode = com.mathworks.xml.XMLUtils.createDocument('febio_spec');

%Add boundary condition information
domNode=addGeometryLevel_FEB(domNode,FEB_struct);

%%
%  View example XML string
XML_str = xmlwrite(domNode);
disp(XML_str);

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
% Copyright (C) 2019  Kevin Mattheus Moerman
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
