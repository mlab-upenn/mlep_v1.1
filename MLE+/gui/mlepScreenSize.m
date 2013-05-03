function [mlep] = mlepScreenSize(mlep)
% GET SIZE INFORMATION AND SET DEFAULT FIGURE SIZE

% GET SCREEN SIZES
mlep.screenSize = get(0,'screensize');
mlep.guiLength = 1300;
mlep.guiHeight = 800;
if mlep.screenSize(3) < 1300
    mlep.guiLength = mlep.guiLength*0.95;
    mlep.guiHeight = mlep.guiHeight*0.95;
end
mlep.guiRatio = mlep.guiLength/mlep.guiHeight;

% DETERMINE FIGURE POSITION
mlep.mainPosition(1) = ceil((mlep.screenSize(3)-mlep.guiLength)/2);
mlep.mainPosition(2) = ceil((mlep.screenSize(4)-mlep.guiHeight)/2);
mlep.mainPosition(3) = mlep.guiLength;
mlep.mainPosition(4) = mlep.guiHeight;
mlep.variablePosition = mlep.mainPosition;

% DEFAULT SETTINGS
mlep.defaultSizePixels = mlep.mainPosition;
mlep.defaultSizeNormal = [0.05 0.05 0.9 0.9];

end