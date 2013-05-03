function model = model3d_set_layers(modelin,l)

if isa(modelin,'model3d')==0
    error('first argument must be a ''model3d'' class');
end

model = modelin;
model.layers = l;