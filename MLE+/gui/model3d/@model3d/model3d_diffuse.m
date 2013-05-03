function mout = model3d_diffuse(model,color)

if isa(model,'model3d')==0
    error('Input must be a ''model3d'' class');
end

mout = model;
for i1=1:length(mout.layers)
    mout.layers(i1).diffuse = color;
end
