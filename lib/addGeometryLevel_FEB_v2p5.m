function domNode=addGeometryLevel_FEB_v2p5(domNode,FEB_struct)

% function [domNode]=addGeometryLevel_FEB(domNode,FEB_struct)
% ------------------------------------------------------------------------
% Adds control Geometry to the XML object domNode based on
% the FEBio structure FEB_struct.
%
%
% Kevin Mattheus Moerman
% gibbon.toolbox@gmail.com
%
% 2016/06/02
%------------------------------------------------------------------------

%% Set default display setting if missing
if ~isfield(FEB_struct,'disp_opt')
    FEB_struct.disp_opt=0;
end

%%
disp('Adding Geometry level');

rootNode = domNode.getDocumentElement;
geometryNode = domNode.createElement('Geometry');
geometryNode = rootNode.appendChild(geometryNode);

%% Adding node field
if isfield(FEB_struct.Geometry,'Nodes')
    disp('----> Adding node field');
    
    parent_node = domNode.createElement('Nodes');
    parent_node = geometryNode.appendChild(parent_node);
    
    if FEB_struct.disp_opt==1
        hw = waitbar(0,'Adding node entries....');
    end
    n_steps=size(FEB_struct.Geometry.Nodes,1);
    for q_n=1:1:n_steps
        node_node = domNode.createElement('node'); %create node entry
        node_node = parent_node.appendChild(node_node); %add node entry
        attr = domNode.createAttribute('id'); %Create id attribute
        attr.setNodeValue(sprintf('%u',q_n)); %Set id text
        node_node.setAttributeNode(attr); %Add id attribute
        node_node.appendChild(domNode.createTextNode(sprintf('%6.7e, %6.7e, %6.7e',FEB_struct.Geometry.Nodes(q_n,:)))); %append data text child
        if FEB_struct.disp_opt==1 && rem(q_n,round(n_steps/10))==0
            waitbar(q_n/n_steps);
        end
    end
    
    if FEB_struct.disp_opt==1
        close(hw); drawnow;
    end
end
%% Adding element field

if isfield(FEB_struct.Geometry,'Elements')
    disp('----> Adding element field')
    
    geometryNode = domNode.getElementsByTagName('Geometry').item(0); %Get GEONode
    
    numElementsPerSet=cellfun(@(x) size(x,1),FEB_struct.Geometry.Elements);
    startInds=[0 cumsum(numElementsPerSet(1:end-1))]+1;
    endInds=cumsum(numElementsPerSet);
    
    for q_el=1:1:numel(FEB_struct.Geometry.Elements) %for all element sets
        
        E_type=FEB_struct.Geometry.ElementType{q_el}; %Element type for current set
        partName=FEB_struct.Geometry.ElementsPartName{q_el}; %Element set part name
        
        if FEB_struct.disp_opt==1
            hw = waitbar(0,['Adding ',E_type,' element entries....']);
        end
        disp(['----> Adding ',E_type,' element entries....']);
        
        elementIndices=startInds(q_el):endInds(q_el);
        
        E=FEB_struct.Geometry.Elements{q_el}; %The current element set
        
        t_form=repmat('   %u,',1,size(E,2)); t_form=t_form(1:end-1); %text format for sprintf for current element type
        
        M=FEB_struct.Geometry.ElementMat{q_el}; %Current elements set's material indices
        matIdSet=unique(M(:)); %Set of unique material indices
        numMat=numel(matIdSet);
        
        for q_mat=1:1:numMat
            
            matId=matIdSet(q_mat);
            logicMat=M==matId; %Logic for all elements for matId
            E_mat=E(logicMat,:);
            elementIndices_mat=elementIndices(logicMat);
            
            if numMat>1
                partNameSet=[partName,'_',sprintf('%u',matId)];
            else
                partNameSet=partName;
            end
            
            %Add Elements field
            parent_node = domNode.createElement('Elements');
            parent_node = geometryNode.appendChild(parent_node);
            
            %Set type attribute
            attr = domNode.createAttribute('type'); %Create id attribute
            attr.setNodeValue(E_type); %Set id text
            parent_node.setAttributeNode(attr); %Add id attribute
            
            %Set mat attribute
            attr = domNode.createAttribute('mat'); %Create id attribute
            attr.setNodeValue(sprintf('%u',matId)); %Set id text
            parent_node.setAttributeNode(attr); %Add id attribute
            
            %Set mat attribute
            attr = domNode.createAttribute('name'); %Create id attribute
            attr.setNodeValue(partNameSet); %Set id text
            parent_node.setAttributeNode(attr); %Add id attribute
            
            n_steps=size(E_mat,1);
            for q_e2=1:1:n_steps
                e_ind=elementIndices_mat(q_e2);
                
                element_node= domNode.createElement('elem');
                element_node = parent_node.appendChild(element_node);
                
                attr = domNode.createAttribute('id'); %Create id attribute
                attr.setNodeValue(sprintf('%u',e_ind)); %Set id text
                element_node.setAttributeNode(attr); %Add id attribute
                
                element_node.appendChild(domNode.createTextNode(sprintf(t_form,E_mat(q_e2,:)))); %append data text child
                
                if FEB_struct.disp_opt==1 && rem(q_e2,round(n_steps/10))==0
                    waitbar(q_e2/n_steps);
                end
            end
            
        end
        
        if FEB_struct.disp_opt==1
            close(hw); drawnow;
        end
    end
end

%% MeshData field

% <MeshData>
%       <ElementData var="shell thickness" elem_set="part1">
%           <elem lid="1">1.0, 1.0, 1.0, 1.0</elem>
%           <elem lid="2">1.0, 1.0, 1.0, 1.0</elem>
%       </ElementData >
%       <ElementData var="pre_stretch" elem_set="part2">
%           <elem lid="1">1.05</elem>
%           <elem lid="2">1.05</elem>
%       </ElementData >
% </MeshData>

if isfield(FEB_struct.Geometry,'MeshData')
    
    geometryNode = domNode.getElementsByTagName('Geometry').item(0); %Get geometry node
    
    %Add MeshData level
    meshDataNode = domNode.createElement('MeshData');
    meshDataNode = geometryNode.appendChild(meshDataNode);
    
    %ElementData for thickness
    if isfield(FEB_struct.Geometry.MeshData,'ElementData')
        
        for q_set=1:1:numel(FEB_struct.Geometry.MeshData.ElementData)
            
            %Add ElemenData level
            parent_node1 = domNode.createElement('ElementData');
            parent_node1 = meshDataNode.appendChild(parent_node1);
            
            attr = domNode.createAttribute('var');
            attr.setNodeValue(FEB_struct.Geometry.MeshData.ElementData{q_set}.Var);
            parent_node1.setAttributeNode(attr);
            
            attr = domNode.createAttribute('elem_set');
            attr.setNodeValue(FEB_struct.Geometry.MeshData.ElementData{q_set}.SetName);
            parent_node1.setAttributeNode(attr);
            
            %Creating ElementData entries
            for q_el=1:1:size(FEB_struct.Geometry.MeshData.ElementData{q_set}.Val,1)
                
                element_node = domNode.createElement('elem');
                element_node = parent_node1.appendChild(element_node);
                attr = domNode.createAttribute('lid');
                attr.setNodeValue(sprintf('%u',q_el));
                element_node.setAttributeNode(attr);
                
                t_form=repmat(' %6.7e,',1,size(FEB_struct.Geometry.MeshData.ElementData{q_set}.Val,2)); t_form=t_form(1:end-1); %text format for sprintf for current element type
                v_text=sprintf(t_form,FEB_struct.Geometry.MeshData.ElementData{q_set}.Val(q_el,:));
                element_node.appendChild(domNode.createTextNode(v_text)); %Adding thickness data text
            end
            
        end
    end
end

%
%
%                 elementIndices=startInds(q_e1):endInds(q_e1);
%                 logicThicknessSet=ismember(elementIndices,FEB_struct.Geometry.ElementData.IndicesForThickness);
%
%                 if any(logicThicknessSet) %If any thicknesses are to be set for the current element group
%
%                     E=FEB_struct.Geometry.Elements{q_e1};
%                     E_type=FEB_struct.Geometry.ElementType{q_e1};
%
%                     if FEB_struct.disp_opt==1
%                         hw = waitbar(0,['Adding ',E_type,' element thickness data entries....']);
%                     end
%                     c=1;
%
%                     disp(['----> Adding ',E_type,' element thickness data entries....']);
%                     n_steps=nnz(logicThicknessSet);
%                     for e_ind=elementIndices(logicThicknessSet)
%
%                         if addedElementDataField==0
%                             parent_node1 = domNode.createElement('ElementData');
%                             parent_node1 = geometryNode.appendChild(parent_node1);
%                             addedElementDataField=1;
%                         end
%
%                         %Creating ElementData entries
%                         element_node = domNode.createElement('elem');
%                         element_node = parent_node1.appendChild(element_node);
%                         attr = domNode.createAttribute('id');
%                         attr.setNodeValue(sprintf('%u',e_ind));
%                         element_node.setAttributeNode(attr);
%
%                         %Adding thickness level
%                         t_form=repmat(' %6.7e,',1,size(E,2)); t_form=t_form(1:end-1); %text format for sprintf for current element type
%
%                         v_text=sprintf(t_form,FEB_struct.Geometry.ElementData.Thickness(FEB_struct.Geometry.ElementData.IndicesForThickness==e_ind)*ones(1,size(E,2)));
%                         thickness_node = domNode.createElement('thickness');
%                         element_node.appendChild(thickness_node);
%                         thickness_node.appendChild(domNode.createTextNode(v_text)); %Adding thickness data text
%
%                         if FEB_struct.disp_opt==1 && rem(c,round(n_steps/10))==0
%                             waitbar(c/n_steps);
%
%                         end
%                         c=c+1;
%                     end
%                     if FEB_struct.disp_opt==1
%                         close(hw); drawnow;
%                     end
%                 end
%             end
%         end
%     end
% end


%% Adding edge field
% TO DO

%% Adding discreteSet field

% <DiscreteSet name="springs">
%     <delem>1,2</delem>
%     <delem>3,4</delem>
% </DiscreteSet>

if isfield(FEB_struct.Geometry,'DiscreteSet')
    disp('----> Adding DiscreteSet field');
    
    for q_set=1:1:numel(FEB_struct.Geometry.DiscreteSet)
        
        discreteSetElements=FEB_struct.Geometry.DiscreteSet{q_set}.Elements; %The elements set
        
        %Create discreteSet level
        parent_node = domNode.createElement('DiscreteSet');
        parent_node = geometryNode.appendChild(parent_node);
        
        if ~isfield(FEB_struct.Geometry.DiscreteSet{q_set},'Name')
            FEB_struct.Geometry.DiscreteSet{q_set}.Name=['DiscreteSet_',sprintf('%u',q_set)]; %Set default name
        end
        discreteSetName=FEB_struct.Geometry.DiscreteSet{q_set}.Name; %Node set name
        
        attr = domNode.createAttribute('name'); %Create id attribute
        attr.setNodeValue(discreteSetName); %Set id text
        parent_node.setAttributeNode(attr); %Add id attribute
        
        t_form=repmat('   %u,',1,size(discreteSetElements,2)); t_form=t_form(1:end-1); %text format for sprintf for current element type
        
        numDiscreteElements=size(discreteSetElements,1);
        for q_element=1:1:numDiscreteElements %For all entries
            
            %Add element entry
            
            element_node= domNode.createElement('delem');
            element_node = parent_node.appendChild(element_node);
            
            %             attr = domNode.createAttribute('id'); %Create id attribute
            %             attr.setNodeValue(sprintf('%u',e_ind)); %Set id text
            %             element_node.setAttributeNode(attr); %Add id attribute
            
            element_node.appendChild(domNode.createTextNode(sprintf(t_form,discreteSetElements(q_element,:)))); %append data text child
            
        end
    end
end

%% ElementData for fibre directions and MatAxis

% Checking for fiber / mat_axis information
if isfield(FEB_struct.Geometry,'ElementData') %If ElementData exists
    if isfield(FEB_struct.Geometry.ElementData,'MatAxis') %If MatAxis data exists
        domNode=addMatAxisFibreElementData_FEB(domNode,FEB_struct);
    end
end

%% Adding surface field
if isfield(FEB_struct.Geometry,'Surface')
    disp('----> Adding surface field');
    
    for q_set=1:1:numel(FEB_struct.Geometry.Surface)
        
        F=FEB_struct.Geometry.Surface{q_set}.Set; %Faces
        surfaceType=FEB_struct.Geometry.Surface{q_set}.Type; %Surface type
        
        %Create surface level
        parent_node = domNode.createElement('Surface');
        parent_node = geometryNode.appendChild(parent_node);
        
        if ~isfield(FEB_struct.Geometry.Surface{q_set},'Name')
            FEB_struct.Geometry.Surface{q_set}.Name=['Surface_',sprintf('%u',q_set)]; %Surface type
        end
        surfaceName=FEB_struct.Geometry.Surface{q_set}.Name; %Surface type
        
        attr = domNode.createAttribute('name'); %Create id attribute
        attr.setNodeValue(surfaceName); %Set id text
        parent_node.setAttributeNode(attr); %Add id attribute
        
        numFaces=size(F,1);
        for q_face=1:1:numFaces %For all faces
            
            %Add element entry
            element_node = domNode.createElement(surfaceType);
            element_node = parent_node.appendChild(element_node);
            
            %Add id attribute
            attr = domNode.createAttribute('id'); %Create id attribute
            attr.setNodeValue(sprintf('%u',q_face)); %Set id text
            element_node.setAttributeNode(attr); %Add id attribute
            
            %Add node indices for surface element
            t_form=repmat('   %u,',1,size(F,2)); t_form=t_form(1:end-1); %text format for sprintf for current element type
            element_node.appendChild(domNode.createTextNode(sprintf(t_form,F(q_face,:)))); %append data text child
            
        end
    end
end

%% Adding NodeSet section

% <NodeSet name="nodeset1">
%       <node id="1"/>
%       <node id="2"/>
%       <node id="101"/>
%       <node id="102"/>
% </NodeSet>

if isfield(FEB_struct.Geometry,'NodeSet')
    disp('----> Adding NodeSet field');
    
    for q_set=1:1:numel(FEB_struct.Geometry.NodeSet)
        
        nodeSetIndices=FEB_struct.Geometry.NodeSet{q_set}.Set; %Node indices
        nodeSetIndices=nodeSetIndices(:)'; %Row vector
        
        %Create NodeSet level
        parent_node = domNode.createElement('NodeSet');
        parent_node = geometryNode.appendChild(parent_node);
        
        if ~isfield(FEB_struct.Geometry.NodeSet{q_set},'Name')
            FEB_struct.Geometry.NodeSet{q_set}.Name=['NodeSet_',sprintf('%u',q_set)]; %Surface type
        end
        nodeSetName=FEB_struct.Geometry.NodeSet{q_set}.Name; %Node set name
        
        attr = domNode.createAttribute('name'); %Create id attribute
        attr.setNodeValue(nodeSetName); %Set id text
        parent_node.setAttributeNode(attr); %Add id attribute
        
        numNodes=numel(nodeSetIndices);
        for q_node=1:1:numNodes %For all nodes
            
            %Add element entry
            element_node = domNode.createElement('node');
            element_node = parent_node.appendChild(element_node);
            
            %Add id attribute
            attr = domNode.createAttribute('id'); %Create id attribute
            attr.setNodeValue(sprintf('%u',q_node)); %Set id text
            element_node.setAttributeNode(attr); %Add id attribute
        end
        
    end
end

%% Adding ElementSet section

% <ElementSet name="nodeset1">
%       <elem id="1"/>
%       <elem id="2"/>
%       <elem id="101"/>
%       <elem id="102"/>
% </ElementSet>


if isfield(FEB_struct.Geometry,'ElementSet')
    disp('----> Adding ElementSet field');
    
    for q_set=1:1:numel(FEB_struct.Geometry.ElementSet)
        
        elementSetIndices=FEB_struct.Geometry.ElementSet{q_set}.Set; %Node indices
        elementSetIndices=elementSetIndices(:)'; %Row vector
        
        %Create ElementSet level
        parent_node = domNode.createElement('ElementSet');
        parent_node = geometryNode.appendChild(parent_node);
        
        if ~isfield(FEB_struct.Geometry.ElementSet{q_set},'Name')
            FEB_struct.Geometry.ElementSet{q_set}.Name=['ElementSet_',sprintf('%u',q_set)]; %Surface type
        end
        elementSetName=FEB_struct.Geometry.ElementSet{q_set}.Name; %Node set name
        
        attr = domNode.createAttribute('name'); %Create id attribute
        attr.setNodeValue(elementSetName); %Set id text
        parent_node.setAttributeNode(attr); %Add id attribute
        
        numNodes=numel(elementSetIndices);
        for q_node=1:1:numNodes %For all nodes
            
            %Add element entry
            element_node = domNode.createElement('elem');
            element_node = parent_node.appendChild(element_node);
            
            %Add id attribute
            attr = domNode.createAttribute('id'); %Create id attribute
            attr.setNodeValue(sprintf('%u',q_node)); %Set id text
            element_node.setAttributeNode(attr); %Add id attribute
        end
        
    end
end

%% Adding SurfacePair section

% <SurfacePair name="contact1">
%       <master surface="surface1"/>
%       <slave surface="surface2"/>
% </SurfacePair>


if isfield(FEB_struct.Geometry,'SurfacePair')
    disp('----> Adding SurfacePair field');
    
    for q_set=1:1:numel(FEB_struct.Geometry.SurfacePair)
        
        %Create SurfacePair level
        parent_node = domNode.createElement('SurfacePair');
        parent_node = geometryNode.appendChild(parent_node);
        
        if ~isfield(FEB_struct.Geometry.SurfacePair{q_set},'Name')
            FEB_struct.Geometry.SurfacePair{q_set}.Name=['SurfacePair_',sprintf('%u',q_set)]; %Surface type
        end
        surfacePairName=FEB_struct.Geometry.SurfacePair{q_set}.Name; %Node set name
        
        attr = domNode.createAttribute('name'); %Create id attribute
        attr.setNodeValue(surfacePairName); %Set id text
        parent_node.setAttributeNode(attr); %Add id attribute
        
        %Add element entry
        element_node = domNode.createElement('master');
        element_node = parent_node.appendChild(element_node);
        
        %Add id attribute
        attr = domNode.createAttribute('surface'); %Create id attribute
        attr.setNodeValue(FEB_struct.Geometry.SurfacePair{q_set}.Master); %Set text
        element_node.setAttributeNode(attr); %Add id attribute
        
        %Add element entry
        element_node = domNode.createElement('slave');
        element_node = parent_node.appendChild(element_node);
        
        %Add id attribute
        attr = domNode.createAttribute('surface'); %Create id attribute
        attr.setNodeValue(FEB_struct.Geometry.SurfacePair{q_set}.Slave); %Set text
        element_node.setAttributeNode(attr); %Add id attribute
        
    end
end


end

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
