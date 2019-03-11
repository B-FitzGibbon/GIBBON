function [domNode]=addLoadsLevel_FEB(domNode,FEB_struct)

% function [docNode]=addLoadsLevel_FEB(docNode,FEB_struct)
% ------------------------------------------------------------------------
%
% This function adds the loads information to the docNode for an FEBio .feb
% file.
%
%
%
% Kevin Mattheus Moerman
% gibbon.toolbox@gmail.com
% 
% 2014/05/27: Updated for GIBBON
% 2015/06/09: Added body loads, user request jschabs
%------------------------------------------------------------------------
%%

disp('Adding Loads level');

rootNode = domNode.getDocumentElement;

loadsNode = domNode.createElement('Loads');
loadsNode = rootNode.appendChild(loadsNode);

%% Adding surface loads
if isfield(FEB_struct.Loads,'Surface_load')
    disp('----> Defining surface loads')
    for q_sl=1:1:numel(FEB_struct.Loads.Surface_load) %For all surface_loads
                
        
        %Create surface_load level
        surfaceLoadNode = domNode.createElement('surface_load');
        surfaceLoadNode = loadsNode.appendChild(surfaceLoadNode);
        
        %Set load type attribute
        currentLoadType=FEB_struct.Loads.Surface_load{q_sl}.Type;
        attr = domNode.createAttribute('type'); %Create id attribute
        attr.setNodeValue(currentLoadType); %Set attribute text
        surfaceLoadNode.setAttributeNode(attr); %Add id attribute
        
        %Set surface attribute
        currentSurfaceName=FEB_struct.Loads.Surface_load{q_sl}.Surface;
        attr = domNode.createAttribute('surface'); %Create id attribute
        attr.setNodeValue(currentSurfaceName); %Set attribute text
        surfaceLoadNode.setAttributeNode(attr); %Add id attribute
        
        %Create lcPar level
        currentLcParType=FEB_struct.Loads.Surface_load{q_sl}.lcPar;
        lcParNode = domNode.createElement(currentLcParType);
        lcParNode = surfaceLoadNode.appendChild(lcParNode);
        
        %Set lcPar value (sometimes scale)
        lcParNode.appendChild(domNode.createTextNode(sprintf('%10.6e',FEB_struct.Loads.Surface_load{q_sl}.lcParValue))); %append data text child
        
        %Set lcPar lc attribute
        if isfield(FEB_struct.Loads.Surface_load{q_sl},'lc')
            attr = domNode.createAttribute('lc'); %Create id attribute
            attr.setNodeValue(sprintf('%u',FEB_struct.Loads.Surface_load{q_sl}.lc)); %Set attribute text
            lcParNode.setAttributeNode(attr); %Add id attribute
        end
        
        %Set other properties if present
        if isfield(FEB_struct.Loads.Surface_load{q_sl},'Properties')
            surfaceLoadProperties=FEB_struct.Loads.Surface_load{q_sl}.Properties;
            surfaceLoadValues=FEB_struct.Loads.Surface_load{q_sl}.Values;
            
            for q=1:1:numel(surfaceLoadProperties)
                prop_node = domNode.createElement(surfaceLoadProperties{q}); %create entry
                prop_node = surfaceLoadNode.appendChild(prop_node); %add entry
                t_form=repmat('%10.6e, ',1,size(surfaceLoadValues{q},2)); t_form=t_form(1:end-2);
                prop_node.appendChild(domNode.createTextNode(sprintf(t_form,surfaceLoadValues{q}))); %append data text child
            end
        end
        
        %Create surface_load level
% %         disp('----> Adding loaded surface');
%         surfaceNode = domNode.createElement('surface');
%         surfaceNode = surfaceLoadNode.appendChild(surfaceNode);
%         if isfield(FEB_struct.Loads.Surface_load{q_sl},'SetName') && ~isfield(FEB_struct.Loads.Surface_load{q_sl},'Set')
%             %Define set name attribute
%             attr = domNode.createAttribute('set'); %Create id attribute
%             attr.setNodeValue(FEB_struct.Loads.Surface_load{q_sl}.SetName); %Set attribute text
%             surfaceNode.setAttributeNode(attr); %Add id attribute
%         elseif isfield(FEB_struct.Loads.Surface_load{q_sl},'Set') && ~isfield(FEB_struct.Loads.Surface_load{q_sl},'SetName')
%             
%             %Specifying the surface elements
%             E=FEB_struct.Loads.Surface_load{q_sl}.Set; %The set of surface elements
%             n_steps=size(E,1); %Number of surface elements
%             
%             %Define waitbar
%             if FEB_struct.disp_opt==1
%                 hw = waitbar(0,'Adding contact element entries....');
%             end
%             for q_e=1:1:n_steps
%                 
%                 %Set surface type based on number of nodes
%                 switch size(E,2)
%                     case 4 %quad4
%                         E_type='quad4';
%                     case 3 %tri3
%                         E_type='tri3';
%                     case 6 %tri6
%                         E_type='tri6';
%                 end
%                 
%                 %Create surface type entry
%                 element_node = domNode.createElement(E_type); %create element entry
%                 element_node = surfaceNode.appendChild(element_node); %add element entry
%                 
%                 %Set id
%                 attr = domNode.createAttribute('id'); %Create id attribute
%                 attr.setNodeValue(num2str(q_e)); %Set id text
%                 element_node.setAttributeNode(attr); %Add id attribute
%                 t_form=repmat('%u, ',1,size(E,2)); t_form=t_form(1:end-2); %Text form
%                 element_node.appendChild(domNode.createTextNode(sprintf(t_form,E(q_e,:)))); %append data text child
%                 
%                 %Increment waitbar
%                 if FEB_struct.disp_opt==1 && rem(q_e,round(n_steps/10))==0
%                     waitbar(q_e/n_steps);
%                 end
%             end
%             
%             if FEB_struct.disp_opt==1
%                 close(hw); drawnow;
%             end
%             
%         else
%             error('Specify either SetName or Set not both');
%         end
    end
end

%% Adding nodal loads

if  isfield(FEB_struct.Loads,'Nodal_load')
    
    disp('----> Defining node loads')
    
    for q1=1:1:numel(FEB_struct.Loads.Nodal_load) %For all Nodal_loads
        
        %Create nodal_load level
        nodal_load_node = domNode.createElement('nodal_load'); %create entry
        nodal_load_node = loadsNode.appendChild(nodal_load_node); %add entry
        
        %Add bc attribute
        currentBC=FEB_struct.Loads.Nodal_load{q1}.bc;
        attr = domNode.createAttribute('bc'); %Create id attribute
        attr.setNodeValue(currentBC); %Set id text
        nodal_load_node.setAttributeNode(attr); %Add id attribute
        
        %Set lc attribute
        if isfield(FEB_struct.Loads.Nodal_load{q1},'lc')
            attr = domNode.createAttribute('lc'); %Create id attribute
            attr.setNodeValue(sprintf('%u',FEB_struct.Loads.Nodal_load{q1}.lc)); %Set attribute text
            nodal_load_node.setAttributeNode(attr); %Add id attribute
        end
        
        %Create node entries
        nodeIdSet=FEB_struct.Loads.Nodal_load{q1}.Set;
        nodeValues=FEB_struct.Loads.Nodal_load{q1}.nodeScale;
        
        if FEB_struct.disp_opt==1
            hw = waitbar(0,'Adding nodal loads....');
        end
        n_steps=size(nodeIdSet,1);
        
        disp('----> Adding nodal loads');
        
        for q2=1:1:n_steps
            
            node_node = domNode.createElement('node'); %create node entry
            node_node = nodal_load_node.appendChild(node_node); %add node entry
            
            attr = domNode.createAttribute('id'); %Create id attribute
            attr.setNodeValue(sprintf('%u',nodeIdSet(q2))); %Set id text
            node_node.setAttributeNode(attr); %Add id attribute
            
            node_node.appendChild(domNode.createTextNode(sprintf('%6.7e',nodeValues(q2)))); %append data text child
            
            if FEB_struct.disp_opt==1 && rem(q2,round(n_steps/10))==0;
                waitbar(q2/n_steps);
            end
        end
        if FEB_struct.disp_opt==1;
            close(hw); drawnow;
        end
        
    end
end

%% Adding body loads

if  isfield(FEB_struct.Loads,'Body_load')
    
    disp('----> Defining body loads')
    
    for q1=1:1:numel(FEB_struct.Loads.Body_load) %For all Body_loads
        
        %Create body_load level
        body_load_node = domNode.createElement('body_load'); %create entry
        body_load_node = loadsNode.appendChild(body_load_node); %add entry
        
        %Add type attribute
        currentType=FEB_struct.Loads.Body_load{q1}.Type;
        attr = domNode.createAttribute('type'); %Create attribute
        attr.setNodeValue(currentType); %Set text
        body_load_node.setAttributeNode(attr); %Add attribute        
        
        switch FEB_struct.Loads.Body_load{q1}.Type
            case 'const'
                %Check load curves, add if missing
                if ~isfield(FEB_struct.Loads.Body_load{q1},'lc')     
                    FEB_struct.Loads.Body_load{q1}.lc=[1 1 1];
                end
        end
                
        for q2=1:numel(FEB_struct.Loads.Body_load{q1}.Properties)
            %Add property node
            node_node = domNode.createElement(FEB_struct.Loads.Body_load{q1}.Properties{q2}); %create node entry
            node_node = body_load_node.appendChild(node_node); %add node entry
            
            switch FEB_struct.Loads.Body_load{q1}.Type
                case 'const'
                    %Add lc attribute
                    attr = domNode.createAttribute('lc'); %Create id attribute
                    attr.setNodeValue(sprintf('%u',FEB_struct.Loads.Body_load{q1}.lc(q2))); %Set id text
                    node_node.setAttributeNode(attr); %Add id attribute
                case 'non-const'                                        

                case 'centrifugal'

            end
            
            %Set value
            if ischar(FEB_struct.Loads.Body_load{q1}.Values{q2}) %text
                node_node.appendChild(domNode.createTextNode(FEB_struct.Loads.Body_load{q1}.Values{q2})); %append data text child
            else %Assume numeric
                node_node.appendChild(domNode.createTextNode(sprintf('%6.7e',FEB_struct.Loads.Body_load{q1}.Values{q2}))); %append data text child
            end
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
