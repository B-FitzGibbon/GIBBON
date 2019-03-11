function [varargout]=subTriDual(varargin)

%% Parse input

switch nargin
    case 2
        F=varargin{1};
        V=varargin{2};
        logicFaces=true(size(F,1),1);
        CF=[];
    case 3
        F=varargin{1};
        V=varargin{2};
        logicFaces=varargin{3};
        CF=[];
    case 4
        F=varargin{1};
        V=varargin{2};
        logicFaces=varargin{3};
        CF=varargin{4};
end

if isempty(logicFaces)
    logicFaces=true(size(F,1),1);
end

if isempty(CF)
    CF=ones(size(F,1),1);
end

[CV]=faceToVertexMeasure(F,V,CF);

%% Remove isolated faces

Fs=F(logicFaces,:);
[IND_F,~,~]=tesIND(Fs,V,0);
logicFree=(sum((IND_F>0),2))==1;
logicFree_F=sum(logicFree(Fs),2)==1;
logicFaces(logicFaces)=~logicFree_F;
Fs=F(logicFaces,:);
CFs=CF(logicFaces,:);

%%

[N]=patchNormal(Fs,V); %Get face normals

[Fq,Vq,Cq,indIni]=triPolyDualRefine(Fs,V,0);

Cq=CV(Cq);

Fqs=sort(Fq,2);
logicInvalid=any(diff(Fqs,1,2)==0,2);

Fq=Fq(~logicInvalid,:);

%%

[Nq]=patchNormal(Fq,Vq);

ind1=Fq(:,1);
ind1(ind1>size(Vq,1))=ind1(ind1>size(Vq,1))-size(Vq,1);
logicFlip=dot(Nq,N(ind1,:),2)<0;
Fd=Fq(~logicFlip,:);
Cd=Cq(~logicFlip,:);
Vd=Vq;

[Eb]=patchBoundary(Fs,V);
indFree=unique(Eb(:));
logicFree_FV=false(size(V,1),1);
logicFree_FV(indFree)=1;

[Eb]=patchBoundary(Fd,Vd);
indFree=unique(Eb(:));
logicFree=false(size(Vd,1),1);
logicFree(indFree)=1;

logicFree_FV_Fd=false(size(Vd,1),1);
logicFree_FV_Fd(indIni)=logicFree_FV;

logic_Fd_FV_Fd=logicFree_FV_Fd(Fd);
logic_Fd=logicFree(Fd);
logic_Fd_invalid=logic_Fd_FV_Fd;
logic_Fd_invalid(logic_Fd)=0;
logic_Fd_invalid=any(logic_Fd_invalid,2)&sum(logic_Fd,2)==2;

%%

Cd=Cd(~logic_Fd_invalid,:);
Fd=Fd(~logic_Fd_invalid,:);

[E]=patchBoundary(Fd,Vd);

logicMember=ismember(E,indIni);
indA=unique(E(logicMember));
indB=unique(E(~logicMember));

[~,IND_V,~]=tesIND(Fd,Vd,0);

logicNotMember=~ismember(IND_V,indA(:));
IND_V(logicNotMember)=0;
IND_V=IND_V(indB,:);

logicTwo=sum(IND_V>0,2)==2;

Fn=sort(IND_V(logicTwo,:),2);
Fn=[indB(logicTwo) Fn(:,end-1:end)];

indThree=indB(sum(IND_V>0,2)==3);

if ~isempty(Fn)
    [Nn,~,~]=patchNormal(Fn,Vd);
    ind1=Fn(:,1);
    ind1(ind1>size(Vd,1))=ind1(ind1>size(Vd,1))-size(Vd,1);
    logicFlip=dot(Nn,N(ind1,:),2)<0;
    Fn(logicFlip,:)=fliplr(Fn(logicFlip,:));
end
Cn=CFs(ind1,:);

%%
try
    if ~isempty(indThree)
        Fn3=zeros(numel(indThree),3);
        for q=1:1:numel(indThree)
            L=any(E==indThree(q),2);
            f=unique(E(L,:));
            Fn3(q,:)=f(:);
        end
        [Nn3,~,~]=patchNormal(Fn3,Vd);
        ind1=Fn3(:,1);
        ind1(ind1>size(Vd,1))=ind1(ind1>size(Vd,1))-size(Vd,1);
        logicFlip=dot(Nn3,N(ind1,:),2)<0;
        Fn3(logicFlip,:)=fliplr(Fn3(logicFlip,:));
        Cn3=CFs(ind1,:);
    else
        Fn3=[];
        Cn3=[];
    end
catch
    error('Error. Input mesh may be too coarse for dual based subtriangulation');
end

%%

if ~isempty(CF)
    Ctf=[CF(~logicFaces,:); Cd; Cn; Cn3];
else
    Ctf=[];
end

Ct=[ones(nnz(~logicFaces),1); 2*ones(size(Fd,1),1); 3*ones(size(Fn,1),1); 4*ones(size(Fn3,1),1)];
Ft=[F(~logicFaces,:)+nnz(logicFaces); Fd; Fn; Fn3];
Vt=Vd;

%% Collect output

varargout{1}=Ft;
varargout{2}=Vt;
varargout{3}=Ct;
varargout{4}=indIni;
varargout{5}=Ctf;

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
