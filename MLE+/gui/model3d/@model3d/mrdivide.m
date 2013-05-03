function mout = mrdivide(model,val)

if isa(model,'model3d')==0
    error('First argument must be of type ''model3d'' ');
end

mout = model .* (1/val);