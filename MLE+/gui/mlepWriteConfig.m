function [mlep] = mlepWriteConfig(mlep) % mlep.data.inputTableData,mlep.data.outputTableData,

docType = com.mathworks.xml.XMLUtils.createDocumentType('SYSTEM', [],'variables.dtd');
docNode = com.mathworks.xml.XMLUtils.createDocument([], 'BCVTB-variables', docType);
docNode.setEncoding('ISO-8859-1');
docNode.setVersion('1.0')

docRootNode = docNode.getDocumentElement;
%docRootNode.setAttribute('SYSTEM','variables.dtd');
docRootNode.appendChild(docNode.createComment('INPUT'));

% INPUT
for i=1:size(mlep.data.inputTableData,1)
    thisElement = docNode.createElement('variable'); 
    thisElement.setAttribute('source','Ptolemy');
    newElement = docNode.createElement('EnergyPlus');
    newElement.setAttribute(mlep.data.inputTableData(i,2),mlep.data.inputTableData(i,3));
    thisElement.appendChild(newElement);
    docRootNode.appendChild(thisElement);
end
docRootNode.appendChild(docNode.createComment('OUTPUT'));

% OUTPUT
for i=1:size(mlep.data.outputTableData,1)
    thisElement = docNode.createElement('variable'); 
    thisElement.setAttribute('source','EnergyPlus');
    newElement = docNode.createElement('EnergyPlus');
    newElement.setAttribute('name',mlep.data.outputTableData(i,2));
    newElement.setAttribute('type',mlep.data.outputTableData(i,3));
    thisElement.appendChild(newElement);
    docRootNode.appendChild(thisElement);
end

mlep.data.xmlFileName = ['variables.cfg'];
mlep.data.xmlFileNamePath = [mlep.data.projectPath mlep.data.xmlFileName];
xmlwrite(mlep.data.xmlFileNamePath,docNode);
type(mlep.data.xmlFileNamePath);
disp(['variables.cfg has been written in ' mlep.data.xmlFileNamePath]);
end